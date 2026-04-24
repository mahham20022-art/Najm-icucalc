"""FastAPI entrypoint for the MedEvidence backend."""
from __future__ import annotations

import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text

from api.routes import auth as auth_routes
from api.routes import clinical as clinical_routes
from api.routes import drugs as drugs_routes
from core.config import get_settings
from core.logging import configure_logging, get_logger
from db.database import engine, init_db
from services import cache_service, vector_store

settings = get_settings()
logger = get_logger("main")


@asynccontextmanager
async def lifespan(app: FastAPI):
    configure_logging()
    logger.info("startup_begin", extra={"env": settings.ENV})
    try:
        init_db()
        logger.info("db_initialized")
    except Exception as exc:
        logger.error("db_init_failed", extra={"error": str(exc)})
    # warm connections (non-fatal)
    try:
        vector_store.ping()
    except Exception:
        pass
    try:
        cache_service.ping()
    except Exception:
        pass
    logger.info("startup_complete")
    yield
    try:
        vector_store.close()
    except Exception:
        pass
    logger.info("shutdown_complete")


app = FastAPI(
    title=f"{settings.APP_NAME} API",
    version="1.0.0",
    description="Evidence-grounded clinical decision support API.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def request_timing(request: Request, call_next):
    start = time.perf_counter()
    try:
        response = await call_next(request)
    except Exception as exc:
        logger.exception("unhandled_request_error", extra={"path": request.url.path})
        return JSONResponse(status_code=500, content={"detail": "Internal server error"})
    duration_ms = int((time.perf_counter() - start) * 1000)
    response.headers["X-Response-Time-ms"] = str(duration_ms)
    logger.info(
        "request",
        extra={
            "method": request.method,
            "path": request.url.path,
            "status": response.status_code,
            "latency_ms": duration_ms,
        },
    )
    return response


app.include_router(auth_routes.router)
app.include_router(clinical_routes.router)
app.include_router(drugs_routes.router)


@app.get("/")
def root() -> dict:
    return {"name": settings.APP_NAME, "status": "ok", "docs": "/docs"}


@app.get("/health")
def health() -> dict:
    db_ok = False
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_ok = True
    except Exception as exc:
        logger.warning("health_db_failed", extra={"error": str(exc)})

    checks = {
        "database": db_ok,
        "redis": cache_service.ping(),
        "vector_store": vector_store.ping(),
    }
    status = "ok" if all(checks.values()) else "degraded"
    return {
        "status": status,
        "app": settings.APP_NAME,
        "version": "1.0.0",
        "checks": checks,
    }


@app.get("/ready")
def ready() -> dict:
    return {"status": "ready"}
