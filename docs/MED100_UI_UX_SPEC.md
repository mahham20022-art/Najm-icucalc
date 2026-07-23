# Med100 — UI/UX Specification

**Based on:** `MED100_PRD.md`, `MED100_ARCHITECTURE.md`, `MED100_DATABASE_DESIGN.md`
**Author:** Apple Senior UI/UX Design Team (design specification role)
**Status:** Draft v1.1 — revised after cross-document audit; token definitions below are superseded in detail by `MED100_DESIGN_SYSTEM.md`, kept here in summary form only
**Last updated:** 2026-07-23

This document specifies every screen and state in the Med100 experience at Apple Human Interface Guidelines quality: purpose, layout, every component with its states, and behavior. It is platform-agnostic in spirit (the actual client is Flutter, per `MED100_ARCHITECTURE.md`) but held to iOS-native conventions — Dynamic-Type-equivalent scaling, semantic color tokens, restrained motion, tab-bar/nav-bar patterns — as the quality bar, implemented as custom Flutter widgets rather than literal UIKit.

---

## 0. Design Foundations

Every screen below references these system-level decisions rather than restating them.

**Typography.** A single type family rendered through the platform's native font stack (SF Pro on iOS, matching system font elsewhere), on a modular scale: Display (32/40), Title 1 (28/34), Title 2 (22/28), Title 3 (20/25), Headline (17/22, semibold), Body (17/22, regular), Callout (16/21), Subheadline (15/20), Footnote (13/18), Caption (12/16). All sizes scale with the user's OS text-size setting (Dynamic-Type-equivalent) up to accessibility XL sizes without truncating — no fixed-height text containers anywhere in the spec.

**Color system.** Semantic tokens, not literal colors, so Light and Dark Mode (Section 20) are two value-sets behind the same names: `background/primary`, `background/secondary`, `surface/elevated`, `label/primary`, `label/secondary`, `label/tertiary`, `accent` (Med100 clinical-trust blue — split into `accent/fill` and `accent/foreground` sub-tokens, see `MED100_DESIGN_SYSTEM.md` §1.3), `success` (mastery/correct), `warning` (due-for-review/streak-risk), `danger` (incorrect/destructive). Every component below is described in terms of these tokens; exact hex values, contrast verification, and the full token set live in `MED100_DESIGN_SYSTEM.md`, not here.

**Spacing.** 8pt base grid (4pt for icon-to-label micro-gaps, 16/24/32pt for section rhythm).

**Iconography.** One consistent outline icon set at two weights — regular for inactive/secondary, filled for active/selected states (tab bar, toggles).

**Motion.** Spring-based transitions, 250–350ms, used purposefully (a sheet rises, a card flips, a checkmark scales in) — never decorative. Every animation has a Reduce-Motion fallback: a plain cross-fade replaces slides/scales/springs system-wide when the OS accessibility setting is on.

**Elevation.** Light Mode: soft drop shadows separate elevated surfaces (cards, sheets) from the background. Dark Mode does **not** reuse shadows (they don't read against near-black) — elevation is communicated by fill lightness plus a 1px hairline border instead (full rationale in Section 20).

**Accessibility baseline (applies to every screen, not repeated per-section):** every interactive element has a VoiceOver/TalkBack label and hint; minimum 44×44pt tap targets regardless of visual size or text scale; minimum 4.5:1 contrast for body text in both themes; full keyboard/switch-control navigability on web and tablet.

---

## 1. Splash

**Purpose:** brand moment plus a silent session-bootstrap check — never a screen the user is meant to linger on or interact with.

**Layout:** centered Med100 wordmark on a solid brand-color field; the tagline ("One Topic. Every Day. Master Your Specialty.") fades in beneath it a beat after the mark settles.

**Components:**
- `AnimatedLogoMark` — scales in from 92% to 100% with a fade, ~400ms.
- `TaglineText` — fades in after the mark, ~200ms delay.

**Behavior:** the screen holds for a minimum of ~1.2s even if the session check resolves instantly (avoids a jarring flash-of-content), then routes to exactly one of: Onboarding (first launch), Authentication (no valid session), or Home (valid local session — resolved from the local Drift cache per the architecture's offline-first design, so this never blocks on a network call). No back navigation exists from this screen; VoiceOver announces "Med100, loading" once.

---

## 2. Onboarding

A horizontally-paged flow with a persistent thin progress bar at the top (not dots — a continuous bar communicates "this has a defined end" better for a flow with unequal-weight steps).

**2a. Welcome carousel** — three swipeable value-prop cards ("One Topic. Every Day.", "Built by specialists, not content farms", "Works even without signal"); a `SkipButton` top-right skips straight to 2f (Account) for users who just want in.

**2b. Role selection** — single-select grid of `RoleSelectCard`s (Medical Student, Resident, Attending, Nurse/Allied Health, Other), each a large tappable card with an icon and label. Selection drives which specialty/track recommendations appear next.

**2c. Specialty/track selection** — multi-select `SpecialtyChip` grid, at least one required to proceed; each chip shows a small free/premium indicator (a lock glyph on premium-only tracks) so the entitlement model is visible from minute one, not a surprise later.

**2d. Daily goal & notification time** — a `TimePickerWheel` ("When should we remind you?") plus a lightweight goal-minutes selector. A `SecondaryTextButton` allows skipping, paired with one non-blocking line of copy noting that the daily reminder is how the habit loop actually works — informational, not guilt-tripping, and never a repeated nag.

**2e. Notification permission** — the native OS permission dialog is triggered **here**, immediately after the user has already chosen a time (contextual priming improves opt-in versus asking cold on first launch).

**2f. Account creation bridge** — routes into the Authentication flow (Section 3), or offers "Continue as Guest," clearly labeled that guest progress is local-only and not synced across devices until an account is created.

**2g. Completion** — "You're all set — Day 1 starts now," with a single primary CTA into Home.

**Components:** `OnboardingProgressBar`, `ValuePropCard`, `RoleSelectCard`, `SpecialtyChip` (with `FreeBadge`/`PremiumLockIcon`), `TimePickerWheel`, `PrimaryButton`, `SecondaryTextButton`, `SkipButton`.

**Edge cases:** backgrounding mid-flow resumes exactly where the user left off (state persisted locally); denying notification permission shows no repeated prompts — a single, later, non-modal banner on Home suggests enabling it from Settings.

---

## 3. Authentication

**Layout:** a `SegmentedControl` toggles Sign In / Sign Up above a form. Fields: email, password (`TextField` with a show/hide toggle). Below the form: `SSOButton` for Sign in with Apple (required alongside any other third-party sign-in per App Store policy) and Google, plus a `PhoneAuthButton` for regions where email adoption is low (per the PRD's target markets). A `ForgotPasswordLink` triggers an email-based reset flow. A `LegalFootnote` links Terms and Privacy.

**States:**
- Default — fields neutral, `PrimaryButton` ("Continue") enabled once required fields are non-empty.
- Field-level validation error — inline red helper text under the specific field; never a modal for an expected input mistake.
- Loading — `PrimaryButton` shows an inline spinner in place of its label and disables itself, preventing a double-submit.
- Auth error — a non-blocking inline banner above the form ("Incorrect email or password"), not a modal alert.

**Post-auth reconciliation:** if the user arrived here from Guest mode, a brief "Syncing your progress…" state merges local guest data into the newly authenticated account before landing on Home.

---

## 4. Home

The tab-bar root and daily dashboard. Bottom `TabBar` has exactly four destinations — Home, Bookmarks, Progress, Profile — kept minimal per HIG guidance; Settings lives inside Profile rather than claiming a fifth tab slot.

**Layout (top to bottom):**
1. `GreetingHeader` — time-aware greeting + user's name.
2. `StreakBadge` — flame icon + current streak count, tappable through to Progress.
3. `AvatarButton` — top-right, opens Profile.
4. `TodaysTopicHeroCard` — the largest element on the screen: track badge, title, estimated read time, a prominent "Start" CTA. Once completed, the card switches to a checkmark state with a "Review" secondary action instead of "Start" — it never disappears, since revisiting today's topic is a valid action.
5. `DueReviewCard` strip — a horizontal scroll of small cards for flashcards/topics due today from the spaced-repetition schedule; tapping opens Flashcards or Learning Screen directly. Hidden entirely (not shown empty) when nothing is due, per the Empty States principle in Section 17.
6. `ContinueLearningCard` — appears only if a topic was opened but not finished.
7. Quick-stats row — `MasteryRing` (current specialty) + `ActivitySparkline` (mini weekly trend), tapping either opens Statistics.
8. `TrackShelfCard` row — horizontally scrollable, one card per enrolled track/path, each with its own progress ring.

Pull-to-refresh (platform-native control) triggers a manual sync pass.

---

## 5. Today's Topic

The reading screen for the day's assigned topic, reached from the Home hero card.

**Layout:**
- Nav bar — back button, track name as the title, a `BookmarkToggleButton`, a share icon.
- `ReadProgressIndicator` — a thin bar under the nav bar tracking scroll position through the article.
- Content — optional hero illustration, title, `estimatedMinutes` + track badge, then the body: headings, lists, and highlighted `ClinicalPearlCallout` / `CommonPitfallCallout` cards (accent-tinted, visually distinct from body text), with `ReferenceFootnote`s for citations.
- Sticky bottom `StickyActionBar` — primary "Take Quiz" CTA (opens MCQs, Section 15), secondary "Ask AI" icon-button (opens the AI Summary sheet, Section 14).

**Entitlement gating:** if the topic's `isFree` flag is false and the user is on the free tier, the content renders normally for roughly the first third, then a blurred-text overlay with an "Unlock with Premium" card takes over — the user tastes real value before hitting the paywall, rather than being blocked at the door. Topics flagged free-for-safety (e.g., core ICU dosing content) never show this overlay regardless of their track's default tier, per the per-topic entitlement model in `MED100_DATABASE_DESIGN.md` §2.

---

## 6. Learning Screen

The generic topic-detail player, sharing the same component family as Today's Topic (Section 5) but entered from other contexts — a track shelf, Bookmarks, a review queue — where sequence and curriculum position matter more than "today."

**Differences from Today's Topic:**
- `TrackContextHeader` — a breadcrumb ("Critical Care Track · Day 14 of 30") replacing the plain track-name title.
- `PrevNextTopicControls` — arrows for browsing a track sequentially, relevant for self-paced paths where a user might read ahead.
- `MarkCompleteButton` — a manual completion action for self-paced/exam-mode topics not tied to a specific calendar day (daily-release topics complete automatically on quiz submission instead).

Everything else — body rendering, callouts, sticky action bar, entitlement gating — is identical to Section 5.

---

## 7. Bookmarks

**Layout:** nav bar titled "Bookmarks"; a `FilterSegmentedControl` (All / Topics / MCQs / Flashcards); a `SearchBar`; a list of `BookmarkRow`s grouped under `SectionHeader`s ("This Week," "Earlier"), each row showing a type icon, title, track badge, and saved date, with swipe-to-remove.

**Empty state:** an on-brand line illustration with "Save topics, questions, and cards to find them here later" — no CTA, since bookmarking itself happens from other screens, not from here.

---

## 8. Progress

Distinct from Statistics (Section 9): Progress answers "where am I in my curriculum," Statistics answers "how am I doing over time."

**Layout:**
- `TrackSelector` (segmented control, or a dropdown once a user has more than two active tracks).
- `BigProgressRing` — large, track-level percent-complete.
- `TopicTimelineRow` list — one row per topic in the track, each in one of four visual states: completed (checkmark), current (highlighted), locked-future (greyed, lock glyph, for content not yet released per its `releaseOffsetDays`), or due-for-review (small refresh glyph).
- `StreakSummaryCard` — current streak, longest streak, freezes remaining.
- `MasteryBreakdownChart` — a small bar per sub-topic tag within the track.

Tapping a completed row reopens the Learning Screen in a read-only review mode.

---

## 9. Statistics

The aggregate analytics screen.

**Layout:**
- `TimeRangeSegmentedControl` (7 days / 30 days / All time).
- `ActivityBarChart` — rendered from the `weeklyActivity` rolling window.
- `AccuracyTrendLine` — quiz accuracy over the selected range.
- A row of `StatTile`s — total topics completed, total study time, overall accuracy.
- `MasteryComparisonChart` — horizontal bars comparing mastery across specialties, shown only once a user has more than one active specialty.
- `AchievementBadgeStrip` — recently unlocked badges, tapping opens the Achievements detail.

**Staleness affordance:** since these values are server-computed and synced (read-only caches per `MED100_DATABASE_DESIGN.md` §7/§14), a small "as of [time]" caption sits under the header rather than implying the numbers are live.

---

## 10. Profile

**Layout:** `ProfileHeader` (avatar, name, role/specialty tags) with an `EditProfileButton`; a `MiniStatRow` (mastery %, streak, topics completed — each tapping through to the relevant full screen); a menu list: Settings, Subscription (shows the current tier as a trailing badge), Teaching Mode, Help & Support, Invite a Colleague, and a `DestructiveMenuRow` for Sign Out (confirmation dialog required); a `VersionFooter` at the bottom.

---

## 11. Settings

An inset-grouped list, sectioned:

- **Account** — email, change password, linked SSO providers, delete account (destructive; requires confirmation plus a short reason prompt).
- **Notifications** — daily reminder time, master enable/disable toggle, a separate streak-risk-reminder toggle.
- **Learning Preferences** — daily goal minutes, leaderboard opt-in, language picker.
- **Downloads & Offline** — download-over-Wi-Fi-only toggle, offline cache size limit slider, "Clear downloaded content" (confirmation required).
- **Appearance** — `ThemeSegmentedControl` (Light / Dark / System).
- **Accessibility** — text-size override, Reduce Motion toggle, high-contrast toggle.
- **About & Legal** — Terms, Privacy Policy, Medical Disclaimer (per the PRD's Legal & Compliance section), Licenses, Contact Support.

**Components:** `GroupedSettingsSection`, `ToggleRow`, `SliderRow`, `PickerRow`, `DestructiveActionRow`.

---

## 12. Teaching Mode

**Purpose:** lets an attending or senior clinician present Med100 content live — a ward-round teaching moment or a classroom session — reusing the same content library in a presentation-optimized layout, distinct from solo learning consumption.

**Entry points:** the "Teaching Mode" row in Profile, or a contextual "Present" icon surfaced on any Topic/Flashcard/MCQ screen (most visible to attending/editor roles, but usable by anyone informally).

**Layout:** full-screen, chrome minimized (an option to hide the status bar entirely), one content block at a time rendered in significantly larger type than the standard reading layout — a topic section, one flashcard, or one MCQ. A `TeachingModeChrome` control bar sits at the bottom, auto-hiding after a few seconds of inactivity (standard presenter-mode convention) and reappearing on tap: `PrevNextControls`, a `RevealAnswerButton` (keeps an MCQ's or flashcard's answer hidden until the presenter chooses to show the room), a `SessionTimer`, and an `ExitButton`.

**Orientation:** defaults to landscape and assumes the device is propped up or held out to a group — this is the one screen in the spec tuned tablet-first rather than tablet-adapted (see Section 21).

**Side-effect isolation:** stepping through content in Teaching Mode does **not** record quiz attempts, flashcard grades, or update streak/mastery by default — a lecturer walking a resident through their own due cards shouldn't silently rewrite that resident's personal spaced-repetition schedule. A toggle lets the presenter explicitly opt into recording progress against their own account if they're using the mode to self-review while narrating aloud.

---

## 13. Subscription

**Trigger points:** the soft paywall overlay on a premium topic (Section 5), the Profile menu, or a proactive prompt after a meaningful milestone (e.g., a 14-day streak).

**Layout:** `PaywallHeroBanner` framing the value ("Unlock every specialty"); a `PlanComparisonTable` (Free vs. Premium: track access, Exam-Mode, adaptive spaced repetition, CME certificates, full offline library); a `PriceToggle` (Monthly/Annual, annual carrying a "save X%" badge); region-aware pricing resolved server-side through the billing provider; a less-prominent `StudentDiscountLink` requiring verification; a primary "Start Premium" CTA; a `RestorePurchasesLink`; legal fine print (auto-renews, cancel anytime, ToS link).

**Hard rule:** this screen — and the soft-paywall overlay that leads to it — never appears on a topic flagged free-for-safety, regardless of its track's default tier. The paywall is entitlement-driven per-topic, not a track-level gate (`MED100_DATABASE_DESIGN.md` §2).

---

## 14. AI Summary

Presented as a bottom sheet, not a full navigation push — it should feel like a lightweight augmentation of whatever screen triggered it (Today's Topic's "Ask AI," or an MCQ's post-answer "Explain further").

**Layout:** `AISheetHeader` ("AI Summary") with an `AIDisclosureBadge` ("AI-generated, reviewed by specialists" — a transparency requirement consistent with the PRD's "clinician-built" philosophy); concise `AIBodyText`, shorter and more scannable than the full topic; a small source/version tag tied to `sourceContentVersion` so the summary is visibly current against the underlying content; a `FeedbackThumbsRow` ("Was this helpful?"); a close affordance.

**States:**
- Cache hit (the common case, per the AI Cache design) — near-instant, a brief `SkeletonShimmerText` if there's any perceptible delay at all.
- Cache miss — a distinct animated `ThinkingIndicator` (pulsing dot/sparkle motif, deliberately different from the shimmer, since it communicates active generation rather than a fetch), with a timeout fallback to "Couldn't generate a summary right now" if the AI service is slow or unavailable.

---

## 15. MCQs

The quiz-taking screen, entered from Today's Topic's "Take Quiz" CTA or a review queue.

**Layout:** `QuizProgressIndicator` ("Question 2 of 4"); `QuestionStemText`; 3–5 `ChoiceButton`s (single-select, large tap targets); a `SubmitButton`, disabled until a choice is selected.

**Choice button states:**
- Neutral (unanswered).
- Selected, pre-submit — accent border, Submit becomes enabled.
- Correct (post-submit) — success-green fill with a checkmark.
- Incorrect (post-submit) — the chosen wrong answer turns danger-red with an X, while the correct choice simultaneously highlights success-green, so the right answer is never left ambiguous.
- Offline-submitted — a neutral "Submitted — will confirm once you're back online" state with a small sync-pending glyph, since the answer key is never shipped to the device (`MED100_DATABASE_DESIGN.md` §9) and correctness can't be shown until the server confirms.

On submit, an `ExplanationPanel` slides up from the bottom (content released only after the attempt is recorded, per the same server-only-answer design), and the primary button becomes "Next Question."

**End-of-quiz summary:** score ("3/4 correct"), a `PerQuestionReviewRow` list (tap to reopen any explanation), a `MasteryDeltaBadge` ("+2% Internal Medicine mastery"), and a CTA back to Home.

---

## 16. Flashcards

The spaced-repetition review screen, entered from Home's Due-for-Review strip or the Progress screen.

**Layout:** a single `FlashcardStack` card — front-face (prompt) shown first, a tap or "Show Answer" button flips to the back-face — followed by a four-button `GradingButtonRow`: Again / Hard / Good / Easy, color-graded red-through-green, each labeled with its resulting interval preview ("Again → tomorrow," "Easy → 12 days") so the SM-2-style consequence of each choice is visible before tapping, not a surprise after. A `CardProgressIndicator` shows position ("Card 3 of 12 due today"). A `SwipeGestureLayer` offers swipe-to-grade (left = Again, right = Easy) as a power-user shortcut layered over the same four buttons, which remain the primary, fully accessible path.

**Empty/complete state:** "All caught up — no cards due right now," a celebratory (not sad) illustration, and confirmation that today's review streak contribution is recorded.

---

## 17. Empty States

**Design principle:** every empty state pairs an on-brand line illustration (never a generic "sad face" cliché) with one sentence explaining *why* the screen is empty, plus — only if there's a genuine next action — exactly one primary CTA. Never zero explanation, never more than one CTA competing for attention.

| Screen | Empty condition | Treatment |
|---|---|---|
| Bookmarks | No saves yet | Illustration + explanatory line, no CTA (bookmarking happens elsewhere) |
| Progress | No track enrolled | Illustration + "Browse specialty tracks" CTA |
| Statistics | Fewer than 3 days of data | Encouraging "Check back after a few days" copy instead of a blank chart |
| Flashcards | Nothing due | Celebratory illustration, not sad — this is a success state, not a failure state |
| Home's Due-for-Review strip | Nothing due | Hidden entirely rather than rendered empty, to avoid dead space on the busiest screen in the app |

---

## 18. Loading States

**Principle:** skeleton screens (shimmer placeholders matching the final content's shape) are used for any content load expected to exceed ~300ms; spinners are reserved for short, indeterminate, button-level actions (e.g., an auth submit). Pull-to-refresh uses the platform-native refresh control, never a custom one.

**Per-screen skeleton shapes:** Home's hero card shows a card-shaped shimmer; Today's Topic/Learning Screen shows paragraph-shaped bar shimmers; Statistics shows greyed bar/line-chart placeholders in the exact final chart geometry. AI Summary's "Thinking…" state (Section 14) is deliberately distinct from a skeleton, since it communicates active generation rather than fetching already-known data.

**Timeout rule:** any loading state exceeding ~8 seconds surfaces a "this is taking longer than usual" inline message with a manual retry — nothing spins indefinitely.

---

## 19. Error States

- **Network/offline** — a non-blocking inline banner ("You're offline — showing saved content"), never a modal, since offline is an expected first-class state for this product (per the PRD's offline-first design), not an exceptional failure.
- **Form validation** — inline, field-level helper text, never a modal.
- **Server/unexpected errors** — a dedicated full-screen error state used only when there is truly nothing else to show (e.g., a corrupted local cache with no connectivity to recover it): illustration, plain-language message, a `RetryButton`, and — if the retry fails again — a secondary `ContactSupportLink`.
- **Payment/subscription errors** — specific, actionable copy tied to the actual decline reason from the billing provider where available, never a generic "Something went wrong."

**Principle:** user-facing copy never surfaces technical jargon or raw error codes — those go to Crashlytics for engineering, while the user sees the human-readable version.

---

## 20. Dark Mode

Not an inverted light theme — a deliberately designed second value-set behind the same semantic tokens from Section 0.

- **Backgrounds** are true near-black (OLED-friendly), not dark grey.
- **Elevated surfaces** (cards, sheets) use a lighter charcoal fill plus a 1px hairline border instead of a drop shadow — shadows read poorly against a near-black base, so elevation is communicated by fill lightness and the hairline, not by simulated light direction.
- **Accent blue** — the *foreground* use (text, links, active icons sitting on the background) shifts slightly brighter and more saturated in Dark Mode; a direct reuse of the light-theme value would look muddy against near-black and fail contrast requirements. The *fill* use (button/control backgrounds under a white label) deliberately does **not** shift — a brighter fill would itself fail contrast against a white label. These are two distinct tokens, not one value used two ways; see `MED100_DESIGN_SYSTEM.md` §1.3 for the verified contrast reasoning.
- **Semantic status colors** (success/warning/danger) get slightly desaturated Dark Mode variants to avoid visually "vibrating" against the dark background.
- **Imagery** — line-art icons are single-color and tint automatically with the active theme (no dual assets needed); illustrations with a light background ship as a separate dark-optimized variant where one is needed.
- Defaults to following the system setting; an explicit override lives in Settings → Appearance (Section 11).

---

## 21. Tablet Layout

Adaptive, not merely scaled-up, for iPad and Android tablets:

- **Navigation** shifts from the phone's bottom `TabBar` to a persistent left-side navigation rail at regular width — the same four destinations, now with room for icon-plus-label rather than icon-only.
- **Home** becomes two-column: hero card, due-for-review, and continue-learning sit in a wider primary column on the left; streak/mastery summary and the track shelf move into a persistent secondary column on the right, instead of everything stacking vertically as on phone.
- **Today's Topic / Learning Screen** caps the reading column at an optimal measure (~65–75 characters per line) and centers it, rather than stretching text edge-to-edge across a large display; the widest tablets use the freed-up side space for a persistent "on this page" outline, narrower tablets simply carry generous margin.
- **MCQs / Flashcards** grow choice buttons and cards in size but cap their maximum width and center them — tap targets stay human-scaled rather than simply stretching to fill a 12-inch display.
- **Teaching Mode** (Section 12) is tuned tablet-first rather than adapted after the fact, defaulting to landscape, since its core use case — presenting to a group — is inherently a larger-screen scenario.
- **Split-view / multi-window** — below a defined width breakpoint (iPadOS Split View, Android multi-window at a narrow pane), the app falls back cleanly to the phone-style single-column layout and bottom tab bar, rather than rendering a broken in-between layout.

---

*This document defines UI/UX specification only. No implementation code, Flutter widget trees, or visual assets are included. Next phase: high-fidelity visual design (color values, exact type ramp, component redlines) and interactive prototyping per screen.*
