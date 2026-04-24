from datetime import datetime, timezone
from typing import Any, Optional

from sqlalchemy import JSON, Boolean, DateTime, Float, Integer, String, Text
from sqlalchemy.orm import Mapped, Session, mapped_column

from core.logging import get_logger
from db.database import Base, session_scope

logger = get_logger("audit")


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
        index=True,
    )
    user_id: Mapped[Optional[int]] = mapped_column(Integer, nullable=True, index=True)
    query: Mapped[str] = mapped_column(Text, nullable=False)
    mode: Mapped[str] = mapped_column(String(32), nullable=False)
    response_summary: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    safety_triggered: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    safety_level: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    confidence: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    evidence_grade: Mapped[Optional[str]] = mapped_column(String(8), nullable=True)
    client_ip: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    latency_ms: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    details: Mapped[Optional[dict[str, Any]]] = mapped_column(JSON, nullable=True)


def record_audit(
    *,
    user_id: Optional[int],
    query: str,
    mode: str,
    response_summary: Optional[str],
    safety_triggered: bool,
    safety_level: Optional[str],
    confidence: Optional[float],
    evidence_grade: Optional[str],
    client_ip: Optional[str],
    latency_ms: Optional[int] = None,
    details: Optional[dict[str, Any]] = None,
    db: Optional[Session] = None,
) -> None:
    row = AuditLog(
        user_id=user_id,
        query=query[:4000],
        mode=mode,
        response_summary=(response_summary or "")[:4000] or None,
        safety_triggered=safety_triggered,
        safety_level=safety_level,
        confidence=confidence,
        evidence_grade=evidence_grade,
        client_ip=client_ip,
        latency_ms=latency_ms,
        details=details,
    )
    try:
        if db is not None:
            db.add(row)
            db.commit()
        else:
            with session_scope() as scoped:
                scoped.add(row)
    except Exception as exc:  # pragma: no cover - audit must never break request
        logger.error("audit_write_failed", extra={"error": str(exc)})
