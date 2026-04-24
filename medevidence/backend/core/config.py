from functools import lru_cache
from typing import List

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    APP_NAME: str = "MedEvidence"
    ENV: str = Field(default="production")
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"

    ANTHROPIC_API_KEY: str = ""
    OPENAI_API_KEY: str = ""
    ANTHROPIC_MODEL: str = "claude-sonnet-4-20250514"
    EMBEDDING_MODEL: str = "text-embedding-3-large"
    LLM_TEMPERATURE: float = 0.1
    LLM_MAX_TOKENS: int = 2048

    DATABASE_URL: str = "postgresql+psycopg2://medevidence:medevidence@postgres:5432/medevidence"
    WEAVIATE_URL: str = "http://weaviate:8080"
    WEAVIATE_CLASS: str = "ClinicalEvidence"
    REDIS_URL: str = "redis://redis:6379/0"

    SECRET_KEY: str = "change-me-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24

    PUBMED_EMAIL: str = "admin@medevidence.local"
    PUBMED_API_KEY: str = ""
    PUBMED_TIMEOUT: float = 8.0

    RAG_TOP_K: int = 10
    RAG_PUBMED_K: int = 8
    RAG_MIN_SCORE: float = 0.40

    CORS_ORIGINS: List[str] = ["*"]


@lru_cache
def get_settings() -> Settings:
    return Settings()
