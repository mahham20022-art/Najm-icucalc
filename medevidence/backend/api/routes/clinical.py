"""Clinical routes: query, voice-upload passthrough, history."""
from __future__ import annotations

import time
from typing import Any, Dict, Literal, Optional

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile, status
from pydantic import BaseModel, Field
from sqlalchemy import desc
from sqlalchemy.orm import Session

from core.audit import AuditLog, record_audit
from core.config import get_settings
from core.logging import get_logger
from core.security import get_current_user
from db.database import get_db
from models.user import User
from rag import pipeline as rag_pipeline
from safety import safety_guard
from safety.hallucination_guard import validate as validate_response
from services import cache_service, llm_service

logger = get_logger("clinical")
router = APIRouter(prefix="/clinical", tags=["clinical"])
_settings = get_settings()


Mode = Literal["general", "neurology", "icu", "emergency"]


class QueryRequest(BaseModel):
    query: str = Field(min_length=3, max_length=4000)
    mode: Mode = "general"
    patient_context: Optional[Dict[str, Any]] = None


class ClinicalResponse(BaseModel):
    answer: str
    reasoning: str
    differential: list
    red_flags: list
    management_plan: list
    references: list
    confidence_level: float
    evidence_grade: str
    explainability: str
    safety: Optional[Dict[str, Any]] = None
    rag: Optional[Dict[str, Any]] = None
    insufficient_evidence: bool = False
    emergency: bool = False
    mode: Mode = "general"
    latency_ms: int = 0
    model: Optional[str] = None


def _client_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def _summary(payload: Dict[str, Any]) -> str:
    return str(payload.get("answer", ""))[:400]


@router.post("/query", response_model=ClinicalResponse)
async def clinical_query(
    body: QueryRequest,
    request: Request,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
) -> ClinicalResponse:
    start = time.perf_counter()
    query = body.query.strip()
    mode = body.mode
    client_ip = _client_ip(request)

    # 1) safety
    safety_result = safety_guard.evaluate(query)

    if safety_result.level == safety_guard.SafetyLevel.EMERGENCY:
        payload = safety_guard.emergency_payload(safety_result, query)
        latency = int((time.perf_counter() - start) * 1000)
        payload.update({"emergency": True, "mode": mode, "latency_ms": latency, "model": None})
        record_audit(
            user_id=current.id,
            query=query,
            mode=mode,
            response_summary=_summary(payload),
            safety_triggered=True,
            safety_level=safety_result.level.value,
            confidence=payload.get("confidence_level"),
            evidence_grade=payload.get("evidence_grade"),
            client_ip=client_ip,
            latency_ms=latency,
            details={"category": safety_result.category, "matched": safety_result.matched_terms},
            db=db,
        )
        return ClinicalResponse(**payload)

    # 2) cache
    cache_key = cache_service.make_key("clinical", mode, query.lower())
    cached = await cache_service.get_json(cache_key)
    if cached:
        latency = int((time.perf_counter() - start) * 1000)
        cached["latency_ms"] = latency
        cached["mode"] = mode
        return ClinicalResponse(**cached)

    # 3) RAG
    rag_result = await rag_pipeline.run(query)

    if rag_result.insufficient:
        payload = rag_pipeline.insufficient_response(query, rag_result)
        payload["safety"] = safety_result.as_banner()
        payload["mode"] = mode
        payload["emergency"] = False
        payload["latency_ms"] = int((time.perf_counter() - start) * 1000)
        payload["model"] = None
        record_audit(
            user_id=current.id,
            query=query,
            mode=mode,
            response_summary=_summary(payload),
            safety_triggered=safety_result.level != safety_guard.SafetyLevel.SAFE,
            safety_level=safety_result.level.value,
            confidence=payload.get("confidence_level"),
            evidence_grade=payload.get("evidence_grade"),
            client_ip=client_ip,
            latency_ms=payload["latency_ms"],
            details={"rag": rag_result.as_dict()},
            db=db,
        )
        return ClinicalResponse(**payload)

    # 4) LLM
    try:
        llm_payload = await llm_service.generate_clinical_response(
            query=query,
            mode=mode,
            evidence=rag_result.evidence,
            safety_banner=safety_result.as_banner(),
        )
    except Exception as exc:
        logger.error("llm_generation_failed", extra={"error": str(exc)})
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Upstream LLM error.") from exc

    # 5) hallucination guard
    llm_payload, warnings = validate_response(llm_payload, rag_result.evidence)

    latency = int((time.perf_counter() - start) * 1000)
    response = {
        **llm_payload,
        "safety": safety_result.as_banner(),
        "rag": rag_result.as_dict(),
        "mode": mode,
        "emergency": False,
        "insufficient_evidence": False,
        "latency_ms": latency,
        "model": llm_payload.get("_model"),
    }
    # strip internal keys before returning
    for key in ("_model", "_usage"):
        response.pop(key, None)

    await cache_service.set_json(cache_key, response, ttl_seconds=1800)

    record_audit(
        user_id=current.id,
        query=query,
        mode=mode,
        response_summary=_summary(response),
        safety_triggered=safety_result.level != safety_guard.SafetyLevel.SAFE,
        safety_level=safety_result.level.value,
        confidence=response.get("confidence_level"),
        evidence_grade=response.get("evidence_grade"),
        client_ip=client_ip,
        latency_ms=latency,
        details={"warnings": warnings, "rag": rag_result.as_dict()},
        db=db,
    )

    return ClinicalResponse(**response)


@router.post("/voice", response_model=ClinicalResponse)
async def clinical_voice(
    request: Request,
    audio: UploadFile = File(..., description="Audio recording of the clinical question"),
    mode: Mode = "general",
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
) -> ClinicalResponse:
    if audio.content_type not in {
        "audio/webm", "audio/ogg", "audio/mp4", "audio/mpeg", "audio/wav", "audio/x-wav", "audio/m4a",
    }:
        raise HTTPException(status_code=400, detail=f"Unsupported audio type: {audio.content_type}")

    data = await audio.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty audio upload")
    if len(data) > 25 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Audio payload exceeds 25 MB")

    transcript = await _transcribe(data, audio.filename or "audio.webm", audio.content_type or "audio/webm")
    if not transcript:
        raise HTTPException(status_code=422, detail="Could not transcribe audio")

    body = QueryRequest(query=transcript, mode=mode)
    return await clinical_query(body, request, db=db, current=current)


async def _transcribe(data: bytes, filename: str, content_type: str) -> str:
    if not _settings.OPENAI_API_KEY:
        raise HTTPException(status_code=503, detail="Transcription unavailable (OPENAI_API_KEY not set)")
    from openai import AsyncOpenAI

    client = AsyncOpenAI(api_key=_settings.OPENAI_API_KEY, timeout=60.0)
    try:
        result = await client.audio.transcriptions.create(
            model="whisper-1",
            file=(filename, data, content_type),
        )
    except Exception as exc:
        logger.error("transcription_failed", extra={"error": str(exc)})
        raise HTTPException(status_code=502, detail="Transcription upstream failed") from exc
    return (result.text or "").strip()


class HistoryItem(BaseModel):
    id: int
    created_at: str
    query: str
    mode: str
    response_summary: Optional[str]
    confidence: Optional[float]
    evidence_grade: Optional[str]
    safety_triggered: bool
    safety_level: Optional[str]


@router.get("/history", response_model=list[HistoryItem])
def history(
    limit: int = 25,
    db: Session = Depends(get_db),
    current: User = Depends(get_current_user),
) -> list[HistoryItem]:
    limit = max(1, min(200, limit))
    rows = (
        db.query(AuditLog)
        .filter(AuditLog.user_id == current.id)
        .order_by(desc(AuditLog.created_at))
        .limit(limit)
        .all()
    )
    return [
        HistoryItem(
            id=row.id,
            created_at=row.created_at.isoformat(),
            query=row.query,
            mode=row.mode,
            response_summary=row.response_summary,
            confidence=row.confidence,
            evidence_grade=row.evidence_grade,
            safety_triggered=row.safety_triggered,
            safety_level=row.safety_level,
        )
        for row in rows
    ]
