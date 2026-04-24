# MedEvidence

Evidence-grounded clinical decision-support application.

## Stack

| Layer     | Tech                                             |
|-----------|--------------------------------------------------|
| Frontend  | React (UMD) + Tailwind (CDN), single `index.html` |
| Backend   | FastAPI · SQLAlchemy 2 · Pydantic v2             |
| LLM       | Anthropic (`claude-sonnet-4-20250514` default)   |
| Embeddings| OpenAI `text-embedding-3-large`                  |
| Vector DB | Weaviate 1.26                                    |
| Database  | PostgreSQL 16                                    |
| Cache     | Redis 7                                          |
| Edge      | Nginx (serves SPA, proxies `/api`)               |

## Architecture

```
Client ── Nginx ── FastAPI ── Safety Guard ── RAG (Weaviate + PubMed || cache)
                        ├── Hallucination Guard
                        ├── LLM (Anthropic)
                        └── Audit (PostgreSQL)
```

### Request lifecycle

1. **Auth** — JWT bearer validated against users table.
2. **Safety** — deterministic regex guard checks for emergencies.
   - `EMERGENCY` → return hardcoded protocol, LLM is skipped.
   - `ESCALATE` → banner is attached, continue to LLM.
3. **RAG** — embed query (OpenAI) → Weaviate top-10 + PubMed esearch/efetch in parallel → dedupe → rerank on Oxford CEBM grade + recency + vector score.
4. **Evidence gate** — if aggregate score < 0.40, return deterministic *Insufficient Evidence* payload.
5. **LLM** — Anthropic Messages API, `temperature=0.1`, JSON-only output.
6. **Hallucination guard** — validate JSON shape, confidence bounds, and that cited PMIDs appear in the evidence bundle.
7. **Audit** — every query persisted to `audit_logs` (user, query, mode, safety, confidence, evidence grade, IP).

## Running

```bash
cp .env.example .env
# edit .env to set ANTHROPIC_API_KEY, OPENAI_API_KEY, SECRET_KEY
docker-compose up --build
```

- Frontend:   http://localhost:8080
- API docs:   http://localhost:8080/api/docs
- Health:     http://localhost:8080/health

## Endpoints

| Method | Path                    | Auth | Purpose                       |
|--------|-------------------------|------|-------------------------------|
| POST   | `/auth/register`        | —    | Create account + JWT          |
| POST   | `/auth/login`           | —    | Log in, receive JWT           |
| GET    | `/auth/me`              | ✅   | Current user                  |
| POST   | `/clinical/query`       | ✅   | Evidence-grounded clinical Q&A|
| POST   | `/clinical/voice`       | ✅   | Whisper → `/clinical/query`   |
| GET    | `/clinical/history`     | ✅   | Last N of your audited queries|
| POST   | `/drugs/interactions`   | ✅   | Curated + RxNav interactions  |
| GET    | `/health`               | —    | Liveness + component checks   |

## Safety posture

- Deterministic emergency pathways never invoke the LLM.
- Every LLM response is JSON-shape and reference-grounding validated.
- Confidence is capped at 0.85 whenever any grounding warning fires.
- Drug interactions are fully deterministic; the LLM is not in that loop.
- The app is decision support. It does not replace clinician judgment.
