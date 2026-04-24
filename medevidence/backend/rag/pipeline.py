"""End-to-end RAG pipeline for clinical queries.

Steps:
    1. Embed the query via OpenAI
    2. Weaviate top-K vector search (in parallel with PubMed)
    3. Live PubMed search (in parallel with Weaviate)
    4. Deduplicate + rerank
    5. Grade evidence (Oxford CEBM)
    6. If aggregate score < threshold -> Insufficient Evidence, skip LLM
    7. Otherwise return the evidence bundle and aggregate score
"""
from __future__ import annotations

import asyncio
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

from core.config import get_settings
from core.logging import get_logger
from services import embedding_service, pubmed_service, vector_store

logger = get_logger("rag")
_settings = get_settings()


GRADE_WEIGHTS = {
    "1a": 1.00, "1b": 0.95,
    "2a": 0.80, "2b": 0.70,
    "3a": 0.60, "3b": 0.50,
    "4": 0.35,  "5": 0.20,
}


@dataclass
class RAGResult:
    evidence: List[Dict[str, Any]]
    aggregate_score: float
    best_grade: str
    used_vector_store: bool
    used_pubmed: bool
    insufficient: bool
    warnings: List[str] = field(default_factory=list)

    def as_dict(self) -> Dict[str, Any]:
        return {
            "evidence": self.evidence,
            "aggregate_score": round(self.aggregate_score, 3),
            "best_grade": self.best_grade,
            "used_vector_store": self.used_vector_store,
            "used_pubmed": self.used_pubmed,
            "insufficient": self.insufficient,
            "warnings": self.warnings,
        }


def _dedupe_key(item: Dict[str, Any]) -> str:
    for key in ("pmid", "doi", "url", "title"):
        value = item.get(key)
        if value:
            return f"{key}:{str(value).strip().lower()}"
    return f"obj:{id(item)}"


def _grade(item: Dict[str, Any]) -> str:
    grade = (item.get("grade") or "").lower().strip()
    return grade if grade in GRADE_WEIGHTS else "3a"


def _score(item: Dict[str, Any]) -> float:
    grade_w = GRADE_WEIGHTS.get(_grade(item), 0.5)
    vec_score = float(item.get("score", 0.0) or 0.0)
    source_boost = 0.15 if item.get("source") == "vector_store" else 0.0
    recency = 0.0
    year = item.get("year")
    if isinstance(year, int) and year >= 2015:
        recency = 0.05
    if isinstance(year, int) and year >= 2020:
        recency = 0.10
    combined = 0.55 * grade_w + 0.30 * vec_score + source_boost + recency
    return max(0.0, min(1.0, combined))


def _rerank(items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    seen: Dict[str, Dict[str, Any]] = {}
    for item in items:
        key = _dedupe_key(item)
        if key in seen:
            existing = seen[key]
            existing["score"] = max(float(existing.get("score", 0.0) or 0.0), float(item.get("score", 0.0) or 0.0))
            for field_name in ("abstract", "doi", "url", "pmid", "journal", "year", "grade"):
                if not existing.get(field_name) and item.get(field_name):
                    existing[field_name] = item[field_name]
            continue
        item = dict(item)
        item["grade"] = _grade(item)
        seen[key] = item

    ranked = list(seen.values())
    for item in ranked:
        item["combined_score"] = _score(item)
    ranked.sort(key=lambda x: x["combined_score"], reverse=True)
    return ranked


def _aggregate_score(items: List[Dict[str, Any]], top: int = 5) -> float:
    if not items:
        return 0.0
    top_items = items[:top]
    weights = [max(0.0, 1.0 - 0.15 * i) for i in range(len(top_items))]
    weighted = sum(item["combined_score"] * w for item, w in zip(top_items, weights))
    return weighted / sum(weights)


def _best_grade(items: List[Dict[str, Any]]) -> str:
    order = ["1a", "1b", "2a", "2b", "3a", "3b", "4", "5"]
    present = {item["grade"] for item in items if item.get("grade") in order}
    for g in order:
        if g in present:
            return g
    return "5"


async def run(query: str, top_k: Optional[int] = None) -> RAGResult:
    q = (query or "").strip()
    if not q:
        return RAGResult([], 0.0, "5", False, False, True, ["empty_query"])

    top_k = top_k or _settings.RAG_TOP_K
    warnings: List[str] = []

    # Step 1: embed
    try:
        query_vector = await embedding_service.embed_query(q)
    except Exception as exc:
        logger.warning("embedding_unavailable", extra={"error": str(exc)})
        warnings.append("embedding_unavailable")
        query_vector = []

    # Steps 2 + 3 in parallel
    vector_task = vector_store.search(query_vector, top_k=top_k) if query_vector else _empty()
    pubmed_task = pubmed_service.search(q, retmax=_settings.RAG_PUBMED_K)

    vector_hits, pubmed_hits = await asyncio.gather(
        vector_task,
        pubmed_task,
        return_exceptions=False,
    )

    if not vector_hits:
        warnings.append("no_vector_hits")
    if not pubmed_hits:
        warnings.append("no_pubmed_hits")

    merged = _rerank([*(vector_hits or []), *(pubmed_hits or [])])
    trimmed = merged[: max(top_k, 8)]

    aggregate = _aggregate_score(trimmed)
    best = _best_grade(trimmed)
    insufficient = (not trimmed) or aggregate < _settings.RAG_MIN_SCORE

    return RAGResult(
        evidence=trimmed,
        aggregate_score=aggregate,
        best_grade=best,
        used_vector_store=bool(vector_hits),
        used_pubmed=bool(pubmed_hits),
        insufficient=insufficient,
        warnings=warnings,
    )


async def _empty() -> List[Dict[str, Any]]:
    return []


def insufficient_response(query: str, result: RAGResult) -> Dict[str, Any]:
    return {
        "answer": (
            "Insufficient Evidence. The literature retrieved does not meet the minimum evidentiary "
            "threshold for a safe recommendation. Consult primary sources, specialty guidelines, or a "
            "subject-matter expert before acting."
        ),
        "reasoning": (
            f"Aggregate evidence score {result.aggregate_score:.2f} is below threshold "
            f"{_settings.RAG_MIN_SCORE:.2f}. LLM generation was skipped to prevent low-confidence output."
        ),
        "differential": [],
        "red_flags": [],
        "management_plan": [
            "Review specialty guidelines directly (e.g., UpToDate, ACCP, AHA, IDSA).",
            "Consult colleague or subspecialist.",
            "Consider refining the clinical question with more specific terms.",
        ],
        "references": [
            {
                "title": item.get("title"),
                "pmid": item.get("pmid"),
                "url": item.get("url"),
                "grade": item.get("grade"),
            }
            for item in result.evidence[:5]
        ],
        "confidence_level": 0.0,
        "evidence_grade": result.best_grade,
        "explainability": (
            "Deterministic insufficient-evidence branch. "
            f"Vector store: {'used' if result.used_vector_store else 'unused'}, "
            f"PubMed: {'used' if result.used_pubmed else 'unused'}."
        ),
        "rag": result.as_dict(),
        "query": query,
        "insufficient_evidence": True,
    }
