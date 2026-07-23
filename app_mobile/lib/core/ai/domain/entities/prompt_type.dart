/// Mirrors the client-relevant subset of `MED100_DATABASE_DESIGN.md`
/// §10's documented `promptType` enum (`mcq_explanation | topic_summary`)
/// — `content_draft` and `schedule_recommendation` are the backend-only,
/// human-gated Phase 3 pipelines described in `MED100_ARCHITECTURE.md`
/// §10.1/10.2 and are never triggered from this client engine, so they
/// aren't modeled here. [custom] is the escape hatch for a one-off
/// prompt not backed by a named [PromptTemplate].
enum PromptType { mcqExplanation, topicSummary, custom }
