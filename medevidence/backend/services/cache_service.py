"""Thin async-friendly Redis cache wrapper. Gracefully degrades when Redis is unavailable."""
from __future__ import annotations

import asyncio
import hashlib
import json
from typing import Any, Optional

import redis

from core.config import get_settings
from core.logging import get_logger

logger = get_logger("cache")
_settings = get_settings()
_client: Optional[redis.Redis] = None


def _get_client() -> Optional[redis.Redis]:
    global _client
    if _client is not None:
        return _client
    try:
        _client = redis.Redis.from_url(_settings.REDIS_URL, socket_timeout=2, decode_responses=True)
        _client.ping()
        return _client
    except Exception as exc:
        logger.warning("redis_unavailable", extra={"error": str(exc)})
        _client = None
        return None


def make_key(*parts: str) -> str:
    joined = "|".join(parts)
    digest = hashlib.sha256(joined.encode("utf-8")).hexdigest()[:32]
    return f"medevidence:{digest}"


async def get_json(key: str) -> Optional[Any]:
    client = _get_client()
    if client is None:
        return None

    def _do() -> Optional[str]:
        try:
            return client.get(key)
        except Exception:
            return None

    raw = await asyncio.to_thread(_do)
    if not raw:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


async def set_json(key: str, value: Any, ttl_seconds: int = 3600) -> None:
    client = _get_client()
    if client is None:
        return

    payload = json.dumps(value, ensure_ascii=False)

    def _do() -> None:
        try:
            client.set(key, payload, ex=ttl_seconds)
        except Exception:
            pass

    await asyncio.to_thread(_do)


def ping() -> bool:
    client = _get_client()
    if client is None:
        return False
    try:
        return bool(client.ping())
    except Exception:
        return False
