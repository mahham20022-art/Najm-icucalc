"""Weaviate vector store wrapper for clinical evidence.

The class `ClinicalEvidence` is created on boot if missing. Documents are
stored with fields: title, abstract, source, pmid, doi, url, grade, year.
"""
from __future__ import annotations

import asyncio
from typing import Any, Dict, List, Optional

import weaviate
from weaviate.classes.config import Configure, DataType, Property
from weaviate.classes.query import MetadataQuery
from weaviate.exceptions import WeaviateBaseError

from core.config import get_settings
from core.logging import get_logger

logger = get_logger("vector_store")
_settings = get_settings()

_client: Optional[weaviate.WeaviateClient] = None


def _parse_url(url: str) -> tuple[str, int, bool]:
    from urllib.parse import urlparse

    parsed = urlparse(url)
    secure = parsed.scheme == "https"
    host = parsed.hostname or "weaviate"
    port = parsed.port or (443 if secure else 8080)
    return host, port, secure


def _connect() -> Optional[weaviate.WeaviateClient]:
    global _client
    if _client is not None:
        return _client
    try:
        host, port, secure = _parse_url(_settings.WEAVIATE_URL)
        client = weaviate.connect_to_custom(
            http_host=host,
            http_port=port,
            http_secure=secure,
            grpc_host=host,
            grpc_port=50051,
            grpc_secure=secure,
        )
        if not client.is_ready():
            logger.warning("weaviate_not_ready")
            client.close()
            return None
        _ensure_schema(client)
        _client = client
        return _client
    except WeaviateBaseError as exc:
        logger.warning("weaviate_connect_failed", extra={"error": str(exc)})
        return None
    except Exception as exc:  # pragma: no cover
        logger.warning("weaviate_connect_error", extra={"error": str(exc)})
        return None


def _ensure_schema(client: weaviate.WeaviateClient) -> None:
    collection_name = _settings.WEAVIATE_CLASS
    if client.collections.exists(collection_name):
        return
    client.collections.create(
        name=collection_name,
        vectorizer_config=Configure.Vectorizer.none(),
        properties=[
            Property(name="title", data_type=DataType.TEXT),
            Property(name="abstract", data_type=DataType.TEXT),
            Property(name="source", data_type=DataType.TEXT),
            Property(name="pmid", data_type=DataType.TEXT),
            Property(name="doi", data_type=DataType.TEXT),
            Property(name="url", data_type=DataType.TEXT),
            Property(name="grade", data_type=DataType.TEXT),
            Property(name="year", data_type=DataType.INT),
        ],
    )
    logger.info("weaviate_collection_created", extra={"collection": collection_name})


def close() -> None:
    global _client
    if _client is not None:
        try:
            _client.close()
        except Exception:
            pass
        _client = None


async def search(query_vector: List[float], top_k: int = 10) -> List[Dict[str, Any]]:
    if not query_vector:
        return []

    def _run() -> List[Dict[str, Any]]:
        client = _connect()
        if client is None:
            return []
        try:
            collection = client.collections.get(_settings.WEAVIATE_CLASS)
            response = collection.query.near_vector(
                near_vector=query_vector,
                limit=top_k,
                return_metadata=MetadataQuery(distance=True, score=True),
            )
            results: List[Dict[str, Any]] = []
            for obj in response.objects:
                props = dict(obj.properties or {})
                distance = getattr(obj.metadata, "distance", None)
                score = 1.0 - float(distance) if distance is not None else getattr(obj.metadata, "score", 0.0) or 0.0
                props["score"] = max(0.0, min(1.0, float(score)))
                props["source"] = props.get("source") or "vector_store"
                results.append(props)
            return results
        except WeaviateBaseError as exc:
            logger.warning("weaviate_search_failed", extra={"error": str(exc)})
            return []

    return await asyncio.to_thread(_run)


async def upsert(docs: List[Dict[str, Any]], vectors: List[List[float]]) -> int:
    if not docs or not vectors or len(docs) != len(vectors):
        return 0

    def _run() -> int:
        client = _connect()
        if client is None:
            return 0
        try:
            collection = client.collections.get(_settings.WEAVIATE_CLASS)
            with collection.batch.dynamic() as batch:
                for doc, vector in zip(docs, vectors):
                    batch.add_object(properties=doc, vector=vector)
            return len(docs)
        except WeaviateBaseError as exc:
            logger.warning("weaviate_upsert_failed", extra={"error": str(exc)})
            return 0

    return await asyncio.to_thread(_run)


def ping() -> bool:
    client = _connect()
    return bool(client and client.is_ready())
