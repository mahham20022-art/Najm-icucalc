# Med100 — Database Design

**Based on:** `MED100_PRD.md`, `MED100_ARCHITECTURE.md`
**Author:** Senior Database Engineer
**Status:** Draft v1.0 — schema design only, no implementation
**Last updated:** 2026-07-23

This document supersedes the illustrative Firestore sketch in the architecture doc's Section 7.2 with a fully worked schema, and closes three gaps flagged in the architecture review:

- **Content gating** (`Topics`, below): resolves the CDN-vs-signed-URL contradiction with a split delivery path.
- **Streak/Mastery as derived state** (`Streaks`, `Mastery Scores`, below): both are server-computed projections, not client-synced scalars, with an explicit optimistic-local-preview mechanism so offline UX stays instant.
- **Multi-tenancy reserved at MVP** (`Users`, below): `institutionId` is in the schema from day one, unused until Phase 3.

It also introduces a schema-versioning/migration convention, which neither prior document defined.

---

## 0. Cross-Cutting Conventions

These apply to every entity below and are not repeated per-section:

- **`schemaVersion` (int)** on every Firestore document and every Drift table's row-shape is implicit in a table-level `SCHEMA_VERSION` constant. Firestore documents carry a per-document `schemaVersion` field so a Cloud Function or client can detect and upgrade old shapes on read ("lazy migration"). Drift uses its built-in `MigrationStrategy` (`onUpgrade`) keyed off `Drift`'s schema version — this is stated explicitly because it was undefined in the architecture doc and is real technical debt if left implicit.
- **Timestamps**: `createdAt` / `updatedAt` on every mutable document, always server-set (`FieldValue.serverTimestamp()`), never client-supplied — this is what makes last-write-wins conflict resolution meaningful anywhere it's used.
- **Soft delete**: user-generated content (bookmarks, settings) hard-deletes; catalog/content entities (topics, MCQs, flashcards) use `status: 'active' | 'archived'` instead of deletion, since a topic a user has history against can't simply disappear without orphaning their progress records.
- **Idempotency**: every client-originated write that isn't naturally idempotent carries a client-generated `clientOpId` (UUID v4), deduplicated server-side — this is the mechanism the `outbox`/`Sync` design (Section 16) depends on.
- **Write ownership**: each section states whether the client or a Cloud Function is the sole writer. This is enforced in Firestore Security Rules, not by convention — see the ownership matrix in Section 17.

---

## 1. Users

The identity and profile anchor for every other entity.

### Firestore — `users/{userId}`

| Field | Type | Notes |
|---|---|---|
| `uid` | string | matches Firebase Auth UID, doc ID |
| `email` | string | |
| `displayName` | string | |
| `role` | enum | `learner \| editor \| admin \| institution_admin` — mirrored into Auth custom claims, this copy is for display/query only |
| `specialties` | array\<string\> | selected specialty IDs |
| `locale` | string | e.g. `en`, `ar` |
| `timezone` | string | IANA tz, drives notification fan-out bucketing |
| `notificationTime` | string | local `HH:mm`, combined with `timezone` |
| `institutionId` | string \| null | **reserved from MVP**, unused until Phase 3 institutional accounts exist — closes the tenant-retrofit gap from the architecture review |
| `accountStatus` | enum | `active \| suspended \| pending_deletion` |
| `createdAt` / `lastActiveAt` | timestamp | |
| `schemaVersion` | int | |

Subcollections (each detailed in its own section): `progress`, `streaks`, `mastery`, `sreSchedule`, `flashcardSchedule`, `bookmarks`, `quizAttempts`, `notificationTokens`, `settings`, `statistics`, `unlockedAchievements`.

**Write owner:** client writes its own profile fields (`displayName`, `locale`, `notificationTime`); `role` and `institutionId` are server-only (set via a Cloud Function during institutional enrollment or admin action).

### SQLite (Drift) — `users`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | matches Firestore uid |
| `displayName`, `email` | TEXT | |
| `role` | TEXT | cached for offline UI gating (real enforcement is still server-side rules) |
| `specialtiesJson` | TEXT | JSON array |
| `locale`, `timezone`, `notificationTime` | TEXT | |
| `institutionId` | TEXT NULL | |
| `lastSyncedAt` | INTEGER | epoch ms |

Single logical row per device (one signed-in user at a time). Exists so the app has an identity anchor and profile display available with zero network calls at cold start.

---

## 2. Topics

The core content unit. Promoted to a **top-level** collection (a refinement over the architecture doc's nested `specialties/{id}/tracks/{id}/topics/{id}` sketch), because a topic can legitimately belong to more than one learning path (e.g., an ICU sepsis topic appears in both the Critical Care track and a Boards-prep exam path) — nesting under one track would force duplication.

### Firestore — `topics/{topicId}`

| Field | Type | Notes |
|---|---|---|
| `title` | string | |
| `specialtyId` | string | primary specialty classification |
| `bodyRef` | string | path/URL to content payload — see gating logic below |
| `isFree` | boolean | entitlement flag (per-topic, not per-track — resolves the PRD's free/premium contradiction) |
| `version` | int | increments on republish; content is immutable per version |
| `language` | string | |
| `estimatedMinutes` | int | |
| `mcqIds` / `flashcardIds` | array\<string\> | references into the `mcqs` / `flashcards` collections |
| `examMappings` | array\<string\> | e.g. `["USMLE_STEP2", "PLAB"]` |
| `tags` | array\<string\> | |
| `authorId`, `reviewerIds` | string / array | editorial provenance |
| `status` | enum | `active \| archived` |
| `publishedAt` | timestamp | |

**Content gating — resolving the architecture review's open contradiction:**
- If `isFree == true`: `bodyRef` points to a stable, versioned path on the public CDN (`cdn.med100.app/content/{topicId}/v{version}.json`). Fully cacheable, no auth needed — this is the path optimized for scale in the architecture doc, and it's the one carrying the highest read volume by design (free content is what unauthenticated/low-tier traffic hits).
- If `isFree == false`: `bodyRef` points to a private Cloud Storage object. The client never reads it directly; it calls a callable Cloud Function (`getTopicContentUrl`) that checks the caller's `subscriptions/{userId}` status server-side and mints a short-TTL (e.g., 15 min) signed URL. The client caches the *content*, not the URL, once fetched — so the signed-URL round trip happens once per download, not per read. This keeps premium content properly access-controlled while free content still gets full CDN scale benefits, without pretending both can use the same delivery path.

**Write owner:** server-only (Editorial Console → Cloud Function publish pipeline). Never client-writable.

### SQLite — `topics`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `title`, `specialtyId`, `language` | TEXT | |
| `bodyLocalPath` | TEXT NULL | filesystem path once downloaded; NULL if metadata-only |
| `isFree` | INTEGER (bool) | |
| `version` | INTEGER | |
| `estimatedMinutes` | INTEGER | |
| `tagsJson`, `examMappingsJson` | TEXT | |
| `isFullyDownloaded` | INTEGER (bool) | distinguishes "browsable metadata" vs. "available offline" |
| `downloadedAt`, `lastAccessedAt` | INTEGER | `lastAccessedAt` drives LRU eviction per the offline-cache budget |

---

## 3. Learning Paths

The sequencing/curriculum layer, decoupled from raw content so the same topic can be reused across multiple paths.

### Firestore — `learningPaths/{pathId}`

| Field | Type | Notes |
|---|---|---|
| `name` | string | |
| `type` | enum | `specialty_track \| exam_mode \| institutional_custom` |
| `specialtyId` | string \| null | |
| `pacing` | map | `{ mode: 'daily_release' \| 'self_paced' \| 'countdown', examDate?, dailyReleaseTime? }` |
| `isFree` | boolean | path-level default; individual topics can still override via their own `isFree` |
| `active` | boolean | |

### Firestore — `learningPaths/{pathId}/items/{itemId}` (subcollection)

| Field | Type | Notes |
|---|---|---|
| `topicId` | string | reference |
| `order` | int | position in sequence |
| `releaseOffsetDays` | int | days after enrollment/path-start this item unlocks |

Subcollection instead of an array field to avoid the 1MB document ceiling on long exam-prep paths (hundreds of items) and to allow cheap partial reads (e.g., "next 7 items") instead of pulling the whole path.

**Write owner:** server-only (Editorial Console).

### SQLite — `learning_paths` and `learning_path_items`

| `learning_paths` column | Type |
|---|---|
| `id` | TEXT PK |
| `name`, `type`, `specialtyId` | TEXT |
| `pacingJson` | TEXT |
| `isFree`, `active` | INTEGER (bool) |

| `learning_path_items` column | Type |
|---|---|
| `id` | TEXT PK |
| `pathId` | TEXT (FK → learning_paths.id) |
| `topicId` | TEXT (FK → topics.id) |
| `order`, `releaseOffsetDays` | INTEGER |

Relational storage here is deliberate: "what's unlocked for me today, across all my enrolled paths" is exactly the kind of join Drift handles cleanly and a local KV store would not.

---

## 4. Bookmarks

Polymorphic user-curated saves — a learner can bookmark a topic, a specific MCQ, or a flashcard.

### Firestore — `users/{userId}/bookmarks/{bookmarkId}`

| Field | Type | Notes |
|---|---|---|
| `itemType` | enum | `topic \| mcq \| flashcard` |
| `itemId` | string | |
| `note` | string \| null | optional user annotation |
| `createdAt` | timestamp | |

**Write owner:** client (fully user-owned data, no server computation involved).

### SQLite — `bookmarks`

| Column | Type |
|---|---|
| `id` | TEXT PK (client UUID) |
| `itemType`, `itemId` | TEXT |
| `note` | TEXT NULL |
| `createdAt` | INTEGER |
| `syncStatus` | TEXT — `pending \| synced` |

Client-writable locally first, pushed through the outbox (Section 16) — simple last-write-wins is fine here since it's single-user-authored data with no gamification stakes.

---

## 5. Progress

The aggregate learning record per topic, plus the append-only granular log that everything else (streaks, mastery, statistics) is *derived from*. This log is the single source of truth the rest of the schema treats as authoritative.

### Firestore — `users/{userId}/progress/{topicId}`

| Field | Type | Notes |
|---|---|---|
| `status` | enum | `not_started \| in_progress \| completed` |
| `attemptsCount` | int | |
| `lastQuizScorePercent` | number | |
| `timeSpentSeconds` | int | |
| `firstCompletedAt`, `lastReviewedAt` | timestamp | |

### Firestore — `users/{userId}/quizAttempts/{attemptId}` (append-only)

| Field | Type | Notes |
|---|---|---|
| `mcqId`, `topicId` | string | |
| `selectedChoiceId` | string | |
| `isCorrect` | boolean | |
| `answeredAt` | timestamp | server-set |
| `clientOpId` | string | idempotency key — a retried submission after a timeout never double-counts |
| `source` | enum | `initial \| spaced_review \| exam_mode` |

**Write owner:** client submits attempts through a Cloud Function (`submitQuizAttempt`), which validates the answer server-side (never trust a client-reported `isCorrect`), writes the immutable log entry, and updates the `progress` aggregate — this is also the trigger point for streak/mastery recompute (Sections 6–7).

### SQLite — `progress` and `quiz_attempts_log`

| `progress` column | Type |
|---|---|
| `topicId` | TEXT PK |
| `status` | TEXT |
| `attemptsCount` | INTEGER |
| `lastQuizScorePercent` | REAL |
| `timeSpentSeconds` | INTEGER |
| `lastReviewedAt` | INTEGER |

| `quiz_attempts_log` column | Type |
|---|---|
| `id` | TEXT PK (= `clientOpId`) |
| `mcqId`, `topicId`, `selectedChoiceId` | TEXT |
| `answeredAtLocal` | INTEGER — device-clock time, for instant UI; not trusted as the record of truth |
| `source` | TEXT |
| `syncStatus` | TEXT — `pending \| synced \| failed` |

This is the table the offline outbox drains from. `isCorrect` is deliberately **not stored client-side as authoritative** — the local UI can show an optimistic "looks right" state from the bundled answer key for immediate feedback, but the record that counts toward mastery/streak is only official once the server confirms it.

---

## 6. Streaks

**Server-computed projection, not a synced mutable field** — this directly fixes the architecture review finding that last-write-wins on a raw streak counter can silently overwrite a legitimately higher value when a user's two devices reconnect out of order.

### Firestore — `users/{userId}/streaks/{trackId}`

| Field | Type | Notes |
|---|---|---|
| `currentStreak` | int | recomputed by Cloud Function from `quizAttempts`/topic-completion events, never incremented directly by a client write |
| `longestStreak` | int | |
| `lastActiveDate` | date | |
| `freezesAvailable`, `freezesUsedThisMonth` | int | streak-freeze grace mechanic from the PRD's habit-fatigue mitigation |
| `computedAt` | timestamp | |

**Write owner:** server only. Firestore rule: `allow write: if false;` for clients on this path.

### SQLite — `streaks_cache` and the optimistic-preview mechanism

| Column | Type | Notes |
|---|---|---|
| `trackId` | TEXT PK | |
| `currentStreak`, `longestStreak` | INTEGER | last value **confirmed by server** |
| `lastActiveDate` | INTEGER | |
| `optimisticStreak` | INTEGER \| NULL | see below |
| `isOptimistic` | INTEGER (bool) | |

To keep the "Day 5!" celebration instant after finishing today's topic *offline* (a real UX requirement — users expect immediate feedback, not a spinner), the client computes `optimisticStreak` locally the moment a topic is completed, displays it with a subtle "syncing" affordance, and overwrites it with the authoritative `currentStreak` the moment the next sync confirms it. If the server value ever disagrees with the optimistic guess (rare — only possible after a multi-device out-of-order reconnect), the UI reconciles silently to the server number rather than the app ever writing its own guess back as truth.

---

## 7. Mastery Scores

Same pattern as Streaks: **server-computed**, per specialty/track, derived from the quiz-attempt log and spaced-repetition recall accuracy — not a value the client can move by itself.

### Firestore — `users/{userId}/mastery/{specialtyId}`

| Field | Type | Notes |
|---|---|---|
| `masteryPercent` | number | weighted composite of quiz accuracy + SRE recall performance |
| `contributingTopicsCount` | int | |
| `trend` | enum | `up \| down \| flat` vs. prior computation |
| `computedAt` | timestamp | |

**Write owner:** server only (same Cloud Function that recomputes streaks, triggered off the same quiz-attempt/flashcard-grade events).

### SQLite — `mastery_cache`

| Column | Type |
|---|---|
| `specialtyId` | TEXT PK |
| `masteryPercent` | REAL |
| `contributingTopicsCount` | INTEGER |
| `trend` | TEXT |
| `lastSyncedAt` | INTEGER |

Read-only local cache; no optimistic-preview needed here (unlike streaks, mastery isn't celebrated instantly per-action, so showing last-synced value with a "as of" timestamp is acceptable UX).

---

## 8. Flashcards

Where per-item spaced repetition (SM-2-style) actually lives — a refinement over the architecture doc, which described SRE only at topic granularity. With Flashcards as an explicit entity, spaced repetition naturally operates at card granularity, which is the standard (Anki-style) and far more effective than whole-topic review scheduling.

### Firestore — `flashcards/{flashcardId}`

| Field | Type | Notes |
|---|---|---|
| `topicId` | string | |
| `front`, `back` | string | |
| `hint` | string \| null | |
| `difficulty` | enum | `easy \| medium \| hard` |
| `isFree` | boolean | usually inherited from parent topic, occasionally overridden for a "sample card" promo |
| `version` | int | |
| `tags` | array\<string\> | |

**Write owner:** server-only (editorial pipeline).

### Firestore — `users/{userId}/flashcardSchedule/{flashcardId}`

| Field | Type | Notes |
|---|---|---|
| `nextReviewDate` | date | |
| `intervalDays` | int | |
| `easeFactor` | number | SM-2 ease factor |
| `repetitionCount` | int | |
| `lastGrade` | enum | `again \| hard \| good \| easy` |
| `lastReviewedAt` | timestamp | |

**Write owner:** client submits a grade via a Cloud Function (`submitFlashcardGrade`), which recomputes the SM-2 state server-side and writes it — kept server-side (rather than client-computed) so the MVP's fixed algorithm can later be swapped for the Phase 3 adaptive engine without any client release being required.

### SQLite — `flashcards` and `flashcard_schedule`

| `flashcards` column | Type |
|---|---|
| `id` | TEXT PK |
| `topicId` | TEXT |
| `front`, `back`, `hint` | TEXT |
| `difficulty` | TEXT |
| `version` | INTEGER |
| `tagsJson` | TEXT |
| `downloadedAt` | INTEGER |

| `flashcard_schedule` column | Type |
|---|---|
| `flashcardId` | TEXT PK |
| `nextReviewDate` | INTEGER |
| `intervalDays` | INTEGER |
| `easeFactor` | REAL |
| `repetitionCount` | INTEGER |
| `lastGrade` | TEXT |
| `syncStatus` | TEXT |

This is the table behind the "cards due today, across all tracks, ordered by priority" query — the exact relational query pattern the architecture doc cites as the reason Drift was chosen over Hive/Isar.

---

## 9. MCQs

Assessment content, distinct from Flashcards (graded correct/incorrect against a fixed answer, feeds quiz score and mastery; not individually SM-2-scheduled, though a topic containing them can still be resurfaced for review).

### Firestore — `mcqs/{mcqId}`

| Field | Type | Notes |
|---|---|---|
| `topicId` | string | |
| `questionText` | string | |
| `choices` | array\<map\> | `[{id, text}]` |
| `correctChoiceId` | string | **never sent to the client** in the content payload used for rendering — see note below |
| `explanationText` | string | shown after answering |
| `aiExplanationCacheKey` | string \| null | optional pointer into `aiCache` (Section 10) for an AI-elaborated explanation |
| `difficulty` | enum | |
| `examMappings` | array\<string\> | |
| `isFree`, `version` | boolean / int | |

**Security note:** `correctChoiceId` must be excluded from the document the client fetches for *rendering* the question (a separate read-optimized projection, or validated purely server-side in `submitQuizAttempt`) — otherwise a learner can inspect network traffic and read the answer key before answering. This is a correctness/integrity requirement the architecture doc didn't call out, being added here.

**Write owner:** server-only.

### SQLite — `mcqs`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | |
| `topicId` | TEXT | |
| `questionText` | TEXT | |
| `choicesJson` | TEXT | **answer-key-stripped** version for offline rendering |
| `explanationText` | TEXT | cached only after the user has answered (not pre-downloaded with the question, for the same integrity reason as above) |
| `difficulty` | TEXT | |
| `version` | INTEGER | |

Grading while offline: the client cannot validate correctness itself without the answer key, so an offline-answered MCQ shows a neutral "submitted, will confirm once synced" state rather than an immediate right/wrong — a deliberate, small UX tradeoff in exchange for not shipping the answer key to the device.

---

## 10. AI Cache

Serves two purposes: (a) a server-side cost-control cache so repeated AI calls (explanation generation, content-assist drafts, schedule recomputation) aren't recomputed for identical inputs, and (b) a client-side cache of AI content the user has already viewed, so it remains available offline.

### Firestore — `aiCache/{cacheKey}`

`cacheKey = sha256(promptType + inputHash + modelVersion)`

| Field | Type | Notes |
|---|---|---|
| `promptType` | enum | `mcq_explanation \| topic_summary \| content_draft \| schedule_recommendation` |
| `modelVersion` | string | cache is invalidated on model upgrade, not just content change |
| `sourceContentVersion` | int | ties the cache entry to the `topics`/`mcqs` version it was generated from — auto-invalidates when the underlying content is revised |
| `output` | string / map | the generated content |
| `hitCount` | int | observability into cache effectiveness |
| `expiresAt` | timestamp | |

**Access:** never read or written directly by any client — only by Cloud Functions (`ai_bridge` module). Firestore rules deny all client access to this collection entirely; it's an internal implementation detail of the AI Layer, not user data.

### SQLite — `ai_cache_local`

| Column | Type | Notes |
|---|---|---|
| `cacheKey` | TEXT PK | mirrors the server key where applicable |
| `itemType` | TEXT | `mcq \| topic \| flashcard` |
| `itemId` | TEXT | |
| `content` | TEXT | the fetched AI output (e.g., an MCQ's AI-elaborated explanation) |
| `fetchedAt`, `expiresAt` | INTEGER | |

This is a pure read cache populated lazily the first time a user requests AI-elaborated content for an item; it's evicted under the same LRU/storage-budget policy as downloaded topic content, not treated as precious data.

---

## 11. Notifications

### Firestore — `users/{userId}/notificationTokens/{tokenId}`

| Field | Type | Notes |
|---|---|---|
| `fcmToken` | string | |
| `deviceId`, `platform` | string | supports multiple devices per user |
| `registeredAt`, `lastSeenAt` | timestamp | |

### Firestore — `users/{userId}/notificationLog/{notificationId}`

| Field | Type | Notes |
|---|---|---|
| `type` | enum | `daily_topic \| streak_risk \| achievement \| billing` |
| `payload` | map | |
| `deepLink` | string | |
| `sentAt`, `readAt` | timestamp | |

Powers both the server-side delivery record and the in-app notification center. The daily fan-out job itself reads `notificationTime` + `timezone` directly off the `users` document — no separate schedule collection is needed.

**Write owner:** `sentAt` is server-set (Cloud Function on send); `readAt` is client-set (user opened it).

### SQLite — `notifications_local`

| Column | Type |
|---|---|
| `id` | TEXT PK |
| `type`, `title`, `body` | TEXT |
| `payloadJson`, `deepLink` | TEXT |
| `receivedAt`, `readAt` | INTEGER |

Also the log target for the offline-strategy's **local-notification fallback** (architecture doc Section 11): when FCM delivery can't be confirmed, the on-device scheduler fires a local notification and logs it here identically to a server-delivered one, so the notification center doesn't need to distinguish the two sources.

---

## 12. Subscriptions

### Firestore — `subscriptions/{userId}`

| Field | Type | Notes |
|---|---|---|
| `tier` | enum | `free \| premium` |
| `status` | enum | `active \| expired \| cancelled \| grace_period` |
| `source` | enum | `revenuecat \| stripe \| promo \| institutional_grant` |
| `currentPeriodEnd` | timestamp | |
| `autoRenew` | boolean | |
| `originalTransactionId` | string | |
| `institutionalGrantId` | string \| null | for B2B-sponsored access, Phase 3 |

**Write owner:** exclusively the billing webhook Cloud Function. Firestore rule: client read-only, no client write path at all — matches the architecture doc's PCI-isolation decision (Med100's own backend never touches raw payment data, only signed webhook events).

**Boundary race note:** a client acting right at a renewal/downgrade instant may briefly read a stale `status`; this is accepted as a bounded, short-lived leniency (same tradeoff as the offline cache below) rather than something solved with distributed-transaction complexity.

### SQLite — `subscription_cache`

| Column | Type |
|---|---|
| `tier`, `status` | TEXT |
| `currentPeriodEnd` | INTEGER |
| `gracePeriodActive` | INTEGER (bool) |
| `lastSyncedAt` | INTEGER |

Read-only cache gating premium UI/content offline. A device offline through its actual expiry date keeps stale premium access until the next sync — a deliberate, bounded leniency, not a bug: precisely revoking access the instant it lapses isn't achievable offline anyway, and the alternative (locking a paying user out because they're on a plane) is worse.

---

## 13. Achievements

### Firestore — `achievements/{achievementId}` (catalog, not user data)

| Field | Type | Notes |
|---|---|---|
| `name`, `description` | string | |
| `iconRef` | string | |
| `criteriaType` | enum | `streak_length \| mastery_threshold \| topics_completed \| specialty_completion` |
| `criteriaValue` | number | |
| `tier` | enum | `bronze \| silver \| gold` |

### Firestore — `users/{userId}/unlockedAchievements/{achievementId}`

| Field | Type | Notes |
|---|---|---|
| `unlockedAt` | timestamp | server-set, evaluated in the same recompute pass as streaks/mastery |
| `seenByUser` | boolean | the one client-writable field on this document (marks the "new!" badge as viewed) |

**Write owner:** unlock event is server-only; `seenByUser` toggle is client-writable.

### SQLite — `achievements_catalog` and `unlocked_achievements`

| `achievements_catalog` column | Type |
|---|---|
| `id` | TEXT PK |
| `name`, `description`, `iconLocalPath` | TEXT |
| `criteriaTypeJson` | TEXT |
| `tier` | TEXT |

| `unlocked_achievements` column | Type |
|---|---|
| `achievementId` | TEXT PK |
| `unlockedAt` | INTEGER |
| `seenByUser` | INTEGER (bool) |
| `syncStatus` | TEXT — only relevant for the `seenByUser` field |

---

## 14. Statistics

User-facing aggregate stats — distinct from `Mastery` (specialty-scoped competency) and from the raw `quizAttempts` log (per-event). Server-computed for the same correctness reasons as streaks/mastery, and the same values that ultimately feed the BigQuery product-metrics pipeline in the architecture doc.

### Firestore — `users/{userId}/statistics/summary`

| Field | Type | Notes |
|---|---|---|
| `totalTopicsCompleted` | int | |
| `totalStudyTimeSeconds` | int | |
| `quizAccuracyOverall` | number | |
| `weeklyActivity` | array\<int\> | last 12 weeks, denormalized for instant chart rendering without a client-side aggregation query |
| `computedAt` | timestamp | |

**Write owner:** server-only, recomputed on the same trigger as streaks/mastery.

### SQLite — `statistics_cache`

| Column | Type |
|---|---|
| `totalTopicsCompleted` | INTEGER |
| `totalStudyTimeSeconds` | INTEGER |
| `quizAccuracyOverall` | REAL |
| `weeklyActivityJson` | TEXT |
| `lastSyncedAt` | INTEGER |

---

## 15. Settings

The one fully client-owned, client-authoritative entity — no server computation involved, so simple last-write-wins sync is actually correct here (unlike Streaks/Mastery).

### Firestore — `users/{userId}/settings/preferences`

| Field | Type | Notes |
|---|---|---|
| `notificationEnabled` | boolean | |
| `theme` | enum | `light \| dark \| system` |
| `downloadOverWifiOnly` | boolean | |
| `offlineCacheSizeLimitMb` | int | |
| `leaderboardOptIn` | boolean | |
| `dailyGoalMinutes` | int | |

**Write owner:** client.

### SQLite — `settings`

| Column | Type |
|---|---|
| `userId` | TEXT PK |
| `notificationEnabled`, `leaderboardOptIn`, `downloadOverWifiOnly` | INTEGER (bool) |
| `theme` | TEXT |
| `offlineCacheSizeLimitMb`, `dailyGoalMinutes` | INTEGER |
| `syncStatus` | TEXT |

Applied locally instantly (e.g., dark mode toggles with zero perceived latency), pushed through the outbox in the background — this is the one entity where local-write-then-sync is unambiguously the right order, since there's no derived/authoritative value anywhere else to reconcile against.

---

## 16. Sync

The mechanics underpinning every "client-writable" entity above.

### SQLite — `outbox`

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | = `clientOpId`, UUID v4 |
| `entityType` | TEXT | `quiz_attempt \| flashcard_grade \| bookmark \| settings \| achievement_seen` |
| `entityId` | TEXT | |
| `operation` | TEXT | `create \| update` |
| `payloadJson` | TEXT | |
| `createdAt` | INTEGER | |
| `retryCount` | INTEGER | |
| `lastAttemptAt` | INTEGER \| NULL | |
| `status` | TEXT | `pending \| in_flight \| failed \| synced` |

**Bounding, closing a gap flagged in the architecture review:** the outbox is capped (e.g., 500 entries or a configurable size), with the oldest `failed` entries surfaced to the user as an explicit "some progress couldn't sync — check your connection" state rather than silently growing unbounded on a device offline for weeks. `retryCount` backs exponential backoff; entries exceeding a max retry count move to `failed` and stop consuming battery on retry loops until the user is back online and the app is foregrounded.

### SQLite — `sync_state`

| Column | Type | Notes |
|---|---|---|
| `entityType` | TEXT PK | e.g. `topics`, `flashcards`, `mcqs`, `progress` |
| `lastPulledAt` | INTEGER | watermark for incremental pull-sync |
| `lastPushedAt` | INTEGER | |

### Firestore — `users/{userId}/syncMeta/summary` (optional, user-facing trust signal)

| Field | Type | Notes |
|---|---|---|
| `lastFullSyncAt` | timestamp | |
| `activeDeviceIds` | array\<string\> | powers a "last synced from iPhone, 2 hours ago" style trust indicator |

---

## 17. Entity Summary & Write-Ownership Matrix

| Entity | Firestore path | SQLite table(s) | Write owner | Sync pattern |
|---|---|---|---|---|
| Users | `users/{uid}` | `users` | Client (profile fields) / Server (`role`, `institutionId`) | Pull + selective push |
| Topics | `topics/{id}` | `topics` | Server only | Pull (CDN for free, signed URL for premium) |
| Learning Paths | `learningPaths/{id}` (+`items` subcol) | `learning_paths`, `learning_path_items` | Server only | Pull |
| Bookmarks | `users/{uid}/bookmarks/{id}` | `bookmarks` | Client | Outbox push + pull |
| Progress | `users/{uid}/progress/{topicId}`, `.../quizAttempts/{id}` | `progress`, `quiz_attempts_log` | Client submits → Server validates & aggregates | Outbox push, server-authoritative |
| Streaks | `users/{uid}/streaks/{trackId}` | `streaks_cache` | Server only (derived) | Pull only; client shows local optimistic preview |
| Mastery Scores | `users/{uid}/mastery/{specialtyId}` | `mastery_cache` | Server only (derived) | Pull only |
| Flashcards | `flashcards/{id}` | `flashcards` | Server only | Pull |
| Flashcard Schedule | `users/{uid}/flashcardSchedule/{id}` | `flashcard_schedule` | Client submits grade → Server computes SM-2 | Outbox push, server-authoritative |
| MCQs | `mcqs/{id}` | `mcqs` | Server only (answer key excluded from client payload) | Pull |
| AI Cache | `aiCache/{key}` | `ai_cache_local` | Server only (server cache); client cache is a read-through copy | No client sync — server cache is internal; client cache is fetch-and-store |
| Notifications | `users/{uid}/notificationTokens`, `.../notificationLog` | `notifications_local` | Mixed (`sentAt` server, `readAt` client) | Push (FCM) + local fallback log |
| Subscriptions | `subscriptions/{uid}` | `subscription_cache` | Server only (billing webhook) | Pull only, read-only client |
| Achievements | `achievements/{id}`, `users/{uid}/unlockedAchievements/{id}` | `achievements_catalog`, `unlocked_achievements` | Server (unlock) / Client (`seenByUser`) | Pull + tiny outbox push |
| Statistics | `users/{uid}/statistics/summary` | `statistics_cache` | Server only (derived) | Pull only |
| Settings | `users/{uid}/settings/preferences` | `settings` | Client | Local-write-first + outbox push |
| Sync meta | `users/{uid}/syncMeta/summary` | `outbox`, `sync_state` | Client (outbox) / Server (syncMeta) | N/A — this *is* the sync machinery |

**Rule of thumb encoded in this matrix:** anything that affects a gamified or trust-sensitive number (streaks, mastery, statistics, achievements, subscriptions) is server-computed and client-read-only, even though it *feels* like user data. Anything purely preferential (settings, bookmarks) is client-owned with simple sync. This split is the direct fix for the streak-conflict flaw identified in the architecture review, generalized as a consistent rule across the whole schema rather than a one-off patch.

---

*This document defines schema only. No queries, indexes, migrations, or implementation code are included. Next phase: Firestore Security Rules per collection (enforcing the write-ownership matrix above) and Firestore composite index planning per known query pattern.*
