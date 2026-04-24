from contextlib import contextmanager
from typing import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from core.config import get_settings


class Base(DeclarativeBase):
    pass


_settings = get_settings()


def _engine_kwargs(url: str) -> dict:
    kwargs: dict = {"pool_pre_ping": True, "future": True}
    if url.startswith("sqlite"):
        kwargs["connect_args"] = {"check_same_thread": False}
    else:
        kwargs.update({"pool_size": 10, "max_overflow": 20})
    return kwargs


engine = create_engine(_settings.DATABASE_URL, **_engine_kwargs(_settings.DATABASE_URL))
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, expire_on_commit=False)


def get_db() -> Iterator[Session]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@contextmanager
def session_scope() -> Iterator[Session]:
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def init_db() -> None:
    from models import user  # noqa: F401
    from core import audit  # noqa: F401
    Base.metadata.create_all(bind=engine)
