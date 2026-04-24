"""OpenAI embedding client wrapped for RAG use."""
from __future__ import annotations

import asyncio
from typing import List, Sequence

from openai import AsyncOpenAI

from core.config import get_settings
from core.logging import get_logger

logger = get_logger("embedding")
_settings = get_settings()
_client: AsyncOpenAI | None = None


def _get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        if not _settings.OPENAI_API_KEY:
            raise RuntimeError("OPENAI_API_KEY is not configured.")
        _client = AsyncOpenAI(api_key=_settings.OPENAI_API_KEY, timeout=20.0)
    return _client


async def embed_query(query: str) -> List[float]:
    return (await embed_batch([query]))[0]


async def embed_batch(texts: Sequence[str]) -> List[List[float]]:
    if not texts:
        return []
    client = _get_client()
    try:
        response = await client.embeddings.create(
            model=_settings.EMBEDDING_MODEL,
            input=list(texts),
        )
    except Exception as exc:
        logger.error("embedding_failed", extra={"error": str(exc), "count": len(texts)})
        raise
    return [item.embedding for item in response.data]


async def maybe_embed_batch(texts: Sequence[str]) -> List[List[float]]:
    """Embed if key is configured, otherwise return empty vectors (used for graceful degradation)."""
    if not _settings.OPENAI_API_KEY:
        return []
    try:
        return await embed_batch(texts)
    except Exception:
        await asyncio.sleep(0)
        return []
