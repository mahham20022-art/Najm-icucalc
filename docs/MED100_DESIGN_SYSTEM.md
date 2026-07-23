# Med100 — Design System (Complete UI Library Specification)

**Based on:** `MED100_PRD.md`, `MED100_ARCHITECTURE.md`, `MED100_DATABASE_DESIGN.md`, `MED100_UI_UX_SPEC.md`
**Author:** Apple Senior UI/UX Design Team
**Status:** Draft v2.1 — supersedes v2.0; restores two component specs (ChoiceButton, FlashcardStack) dropped during the v1.0→v2.0 rewrite and only left as dangling index references, and fixes a broken internal cross-reference (§17)
**Last updated:** 2026-07-23

This document is the single source of truth for every visual and interaction primitive in Med100 — the library the whole app is assembled from, not a per-screen restatement. `MED100_UI_UX_SPEC.md` describes *where* components appear; this document defines *what each component is*, in every state, in both themes. No feature logic or implementation code is included.

**Governing rule for the entire library:** no component ever hardcodes a color, size, or duration. Every value below is a named token; a component that needs a color references `accent/fill`, never `#0A6CFF` directly. This is what makes Light/Dark theming (§15–16) and future rebrands mechanical rather than a per-screen hunt-and-replace.

---

## 1. Colors

### 1.1 Semantic tokens (values, both themes)

| Token | Light | Dark | Used for |
|---|---|---|---|
| `background/primary` | `#FFFFFF` | `#0B0D10` | screen background |
| `background/secondary` | `#F5F6F8` | `#121417` | grouped-list background, secondary panels |
| `surface/elevated` | `#FFFFFF` + shadow | `#1C1F24` + 1px `#2A2E35` border | cards, sheets, dialogs |
| `label/primary` | `#0F1419` | `#F2F4F6` | primary text |
| `label/secondary` | `#5B6470` | `#A7AFB9` | secondary text |
| `label/tertiary` | `#9AA3AF` | `#6E7681` | decorative-only text (§17.3) |
| `accent/foreground` | `#0A6CFF` | `#4C93FF` | links, active icons, accent text directly on background |
| `accent/fill` | `#0A6CFF` | `#0A6CFF` (unchanged — see §1.3) | button/control fill backgrounds |
| `success` | `#1FAA59` | `#34C77B` | correct/mastery-positive |
| `warning` | `#B8790A` | `#F0B94D` | streak-risk / due-for-review |
| `danger` | `#E5484D` | `#EB6469` | incorrect / destructive |
| `separator` | `#E3E6EA` | `#2A2E35` | hairlines, dividers |

### 1.2 Contrast verification (WCAG relative-luminance formula, computed not estimated)

| Pair | Ratio | Verdict |
|---|---|---|
| `label/primary` on `background/primary` (light) | 18.6:1 | Passes AAA |
| `label/secondary` on `background/primary` (light) | 6.0:1 | Passes AA |
| `label/primary` on `background/primary` (dark) | 17.7:1 | Passes AAA |
| `label/secondary` on `background/primary` (dark) | 8.8:1 | Passes AA |
| `accent/foreground` on `background/primary` (light) | 4.6:1 | Passes AA, tight — Body size or larger only |
| `accent/foreground` on `background/primary` (dark) | 6.4:1 | Passes AA |
| White label on `accent/fill` (both themes) | 4.6:1 | Passes AA, tight margin |
| White label on `danger` fill (both themes) | 3.9:1 | Passes only at bold/large text — see §17.2 |
| White glyph on `success` fill (both themes) | 3.0:1 | Passes the graphical-object floor only — icon-only, never text |

### 1.3 Why `accent` is two tokens

A single "brighter blue in dark mode" satisfies foreground legibility (`#4C93FF` on near-black measures 6.4:1) but fails as a button fill under a white label (3.0:1) — the two roles pull in opposite directions. `accent/fill` therefore keeps one constant value in both themes (4.6:1 with white text, 4.3:1 against the dark background as a non-text UI component); `accent/foreground` is the only accent value that changes by theme, reserved for text/icons sitting directly on the background.

### 1.4 Specialty track colors

Each specialty track is assigned one hue from a fixed 8-color rotation, used only for the track badge/pill — never for anything status-bearing, so it can never be confused with `success`/`warning`/`danger`. Light-mode tracks use a desaturated tint fill with a darker label-colored name; dark-mode tracks use an equivalent lower-luminance tint. Assigned once at content-publish time and never changed, so users build color recognition for their tracks over time.

---

## 2. Typography

| Style | Size / Line-height | Weight | Tracking | Typical use |
|---|---|---|---|---|
| Display | 34/41 | Bold | −0.4 | Splash tagline, milestone numbers |
| Title 1 | 28/34 | Bold | −0.3 | Screen-level titles |
| Title 2 | 22/28 | Bold | −0.2 | Section headers, flashcard prompts |
| Title 3 | 20/25 | Semibold | −0.1 | Card titles |
| Headline | 17/22 | Semibold | −0.1 | Button labels, list row titles |
| Body | 17/22 | Regular | 0 | Topic body text, question stems |
| Callout | 16/21 | Regular | 0 | Secondary body content |
| Subheadline | 15/20 | Regular | 0 | Metadata rows |
| Footnote | 13/18 | Regular | 0 | Timestamps, fine print |
| Caption | 12/16 | Regular | +0.1 | Badges, tags |

**Dynamic-Type-equivalent scaling steps:** xSmall 0.82× · Small 0.88× · Medium 0.94× · **Large 1.00× (default)** · xLarge 1.12× · xxLarge 1.24× · xxxLarge 1.36× · AX1 1.64× · AX2 1.96× · AX3 2.35× · AX4 2.76× · AX5 3.12×. No component in this library has a fixed-height text container — verified per-component below.

**RTL note (Arabic):** all styles apply identically under RTL; only alignment and directional icons change (§17.5), never size or weight.

---

## 3. Spacing

`space-1` 4pt · `space-2` 8pt · `space-3` 12pt · `space-4` 16pt · `space-5` 24pt · `space-6` 32pt · `space-7` 48pt · `space-8` 64pt.

**Screen margins:** phone 16pt (`space-4`) · tablet compact-width 24pt (`space-5`) · tablet regular-width 32–48pt (`space-6`–`space-7`), with the reading column additionally capped at ~65–75 characters rather than stretched to the margin (`MED100_UI_UX_SPEC.md` §21).

**Internal component padding** defaults to `space-4` for cards/sheets/dialogs, `space-3` for compact rows (list items, chips), `space-2` for tight icon-to-label gaps.

---

## 4. Icons

24×24pt canvas · 1.5pt stroke (regular/inactive weight) · 2pt stroke (bold/active weight — tab bar selection, toggled states) · 2pt rounded corner on stroke terminals for a consistent soft-edge character across the set. Icons never carry a baked-in color; they inherit `label/secondary` inactive / `accent/foreground` active, so the one asset set works unmodified in both themes.

**Icon categories:**
- **Navigation** — back chevron, close X, tab bar glyphs (Home, Bookmarks, Progress, Profile).
- **Action** — bookmark (outline/filled toggle), share, search, filter, present (Teaching Mode).
- **Status** — checkmark (success), X (danger), lock (premium-gated), sync-pending, flame (streak).
- **Clinical** — a small dedicated set for Medical Cards (§7): lightbulb (Clinical Pearl), triangle-caution (Pitfall), syringe/dose (Drug Dosing Card), checklist (Protocol Card), shield-check (specialist-reviewed trust mark).

---

## 5. Buttons

All button variants share the same height/radius/motion scale; only fill and border differ.

| Variant | Height | Fill | Label | Border | Disabled |
|---|---|---|---|---|---|
| **Primary** | 50pt | `accent/fill` | Headline, white | none | fill at 40% opacity |
| **Secondary** | 50pt | `background/secondary` | Headline, `accent/foreground` | 1.5pt `accent/foreground` | border+label at 40% opacity |
| **Tertiary / Text** | 44pt (tap target only, no visible fill) | none | Headline, `accent/foreground` | none | label at 40% opacity |
| **Destructive** | 50pt | `danger` | Headline, white (bold weight required — §1.2/§17.2) | none | fill at 40% opacity |
| **Icon Button** | 44×44pt | none (or `background/secondary` circle for emphasis) | 24pt icon, `label/secondary`/`accent/foreground` when active | none | icon at 40% opacity |

**Shared spec:** corner radius `radius/control-md` (12pt, §14) · horizontal padding `space-4` · pressed state applies `motion/micro` (120ms ease-out, scale to 0.97) plus an 8% fill darken · loading state replaces the label with an inline spinner and disables the tap target, never both a spinner and the label at once.

**Compound controls built from the same primitives:**
- **Segmented Control** — a row of Callout-style labels in a `background/secondary` track (`radius/control-sm`, 8pt); the selected segment gets a `surface/elevated`-style pill behind it that slides between positions on tap (`motion/standard`).
- **Toggle / Switch** — standard two-state track+thumb; `on` track uses `accent/fill`, `off` track uses `separator`; thumb is always white in both themes for consistent legibility against either track color.
- **Chip** (specialty selection, filter tags) — `radius/control-sm`, Caption or Callout label, optional leading icon, selected state adds a 1.5pt `accent/foreground` border and tints the fill.

### 5.1 ChoiceButton (specialized — MCQ answer option)

Full-width minus margins · min height 56pt (comfortably exceeds the 44pt tap-target floor even at large Dynamic Type sizes) · corner radius `radius/control-md` · 1.5pt border · label style Body.

| State | Fill | Border | Trailing glyph |
|---|---|---|---|
| Neutral (unanswered) | `background/secondary` | `separator`, 1.5pt | none |
| Selected (pre-submit) | unchanged | `accent/foreground`, 2pt | none |
| Correct (post-submit) | `success` at 12% tint (full-strength `success` is reserved for the glyph itself, per §17.2) | `success`, 2pt | checkmark, full-strength `success` |
| Incorrect (post-submit) | `danger` at 12% tint | `danger`, 2pt | X, full-strength `danger` |
| Offline-pending | `background/secondary` | `separator`, dashed | sync-pending glyph, `label/tertiary` |

The correct choice always renders in its Correct state simultaneously with an Incorrect selection elsewhere in the same question, so the right answer is never left ambiguous. Color is never the only differentiator here — every non-neutral state pairs its tint with a distinct glyph (§17.3), which is also why the Correct/Incorrect tints are capped at 12% rather than full-strength fills: a full-strength `success`/`danger` fill under body-weight choice text would fall below the 4.5:1 floor (§1.2), whereas a 12% tint behind unchanged `label/primary` text keeps the text at its full, unaffected contrast and lets the glyph — not the background — carry the color signal at full strength.

---

## 6. Cards

The generic, domain-agnostic card family — structural, not clinical (see §7 for clinical-content cards).

- **Content Card** — `surface/elevated`, `radius/card` (16pt), `space-4` internal padding. Base shape for the Today's Topic Hero Card, Continue Learning Card, Track Shelf Card.
- **List Row Card** — a flatter variant with no elevation, used inside grouped lists (Bookmarks, Settings) — separated by `separator` hairlines instead of individual shadows/borders, so a long list doesn't stack dozens of competing shadows.
- **Stat Tile** — compact, fixed-aspect card pairing one large Title-1-style number with a Caption label beneath (Statistics screen's summary row).
- **Track Shelf Card** — Content Card variant sized for horizontal-scroll shelves, always paired with a small `ProgressRing` (§11) in a fixed corner position across every instance.

**Shared interaction rule:** any tappable card gets the same `motion/micro` press feedback as a button (scale to 0.97) — cards are never visually inert if they're actually tappable, so users can tell tappable and static cards apart before they even tap.

### 6.1 FlashcardStack (specialized)

16:10 aspect ratio at phone widths, capped max-width at tablet widths (`MED100_UI_UX_SPEC.md` §21) · `radius/card` corners · `surface/elevated` fill.

- **Front-face** — centers a Title-2-style prompt with generous internal padding (`space-6`) so short and long prompts both sit optically centered.
- **Back-face** — reached via tap-anywhere on the card or an explicit "Show Answer" button (the button exists specifically so the flip affordance is discoverable and accessible, not solely a tap-to-guess gesture); flip uses `motion/flip` (400ms spring rotation).
- **GradingButtonRow** — the four-button Again/Hard/Good/Easy row anchored below the card (not part of the card itself): each button is a Secondary-style button colored along a `danger`→`warning`→`success`→`accent/foreground` gradient (Again through Easy) with a Footnote-style interval preview beneath its label ("Again → tomorrow"). This row, not the swipe gesture below, is the primary and fully accessible grading path.
- **SwipeGestureLayer** — an optional swipe-to-grade overlay (left = Again, right = Easy) layered on top of the card for power users; purely additive — every action it exposes is also reachable through `GradingButtonRow`, so nothing is swipe-only. Under RTL, the gesture mapping mirrors so the same physical thumb-motion side keeps the same relative "lighter/heavier" grade meaning (§17.5), rather than preserving the literal left/right label.
- **CardProgressIndicator** — a `StepIndicator` (§11) instance ("Card 3 of 12 due today") positioned above the stack.

---

## 7. Medical Cards

Clinical content needs to read as instantly more authoritative than ordinary app chrome — these variants share the Content Card's shape but carry a distinct trust treatment, and every one of them carries a persistent `shield-check` **"Reviewed by specialists"** trust mark in the footer, distinguishing genuine editorial content from anything AI-assisted (which instead carries the AI Summary sheet's own disclosure badge, per `MED100_UI_UX_SPEC.md` §14 — the two marks are never interchangeable).

- **Clinical Pearl Card** — Content Card with a 4pt `accent/fill` left-edge stripe and a lightbulb icon in the header; used inline within topic body text to highlight a single high-value clinical insight.
- **Common Pitfall / Caution Card** — identical structure to the Clinical Pearl Card, differentiated *only* by color (`warning` stripe) and icon (triangle-caution) — deliberately the same shape so the two read as a matched pair, not unrelated components.
- **Drug Dosing Card** — the direct design-system descendant of the project's original ICU drug calculator: a header (drug name), then one row per dose range, each row carrying a color-coded severity indicator. The original prototype's ad hoc `.low`/`.mid`/`.high` yellow/green/red is formalized here as `warning`/`success`/`danger` respectively, computed the same way (ratio of max to min dose) but now drawn from verified, accessible tokens instead of arbitrary hex values. Each row shows drug name, computed dose range, and unit; a footer note states the reference weight used for the calculation.
- **Protocol / Algorithm Card** — a numbered step list (e.g., a sepsis-bundle sequence), each step a row with a filled numeral badge (`accent/fill`, white numeral) rather than a checkbox — visually distinct from an interactive checklist, since reading a protocol is not the same action as completing one.
- **Exam-Mapping Badge** — not a card but a small pill (Caption style, `background/secondary` fill) listing which exams a topic maps to (e.g., "USMLE Step 2 · PLAB"); appears in the header region of any Medical Card or Topic screen where relevant.

**Non-goal reminder (ties to the PRD's Non-Goals, `MED100_PRD.md` §17):** no Medical Card variant ever renders a per-patient dosing recommendation — the Drug Dosing Card always shows a range tied to an explicit reference weight input, framed as educational reference, never a prescriptive instruction, with the standard medical disclaimer always reachable from the card's overflow menu.

---

## 8. Dialogs

Modal, centered, scrim behind (`rgba(0,0,0,0.4)` light / `rgba(0,0,0,0.6)` dark — deliberately theme-independent black rather than a token, since a scrim's only job is to recede the background regardless of theme), `surface/elevated` fill, `radius/card` corners, max-width capped (critical on tablet — a dialog never stretches to fill a 12" display). Entrance/exit: `motion/standard` scale+fade.

- **Alert Dialog** — Title (Title 3), Body (Callout), one or two actions. Single-action alerts use a full-width Primary button; two-action alerts place the safe/neutral action as a Tertiary button on the left and the primary action as a Primary or Destructive button on the right, matching the platform-conventional "safe default on the left, action on the right" reading order (mirrored under RTL).
- **Confirmation Dialog** (destructive pattern — Sign Out, Delete Account, Clear Downloaded Content) — same anatomy, but the destructive action is always a Destructive button, and it is never the visually dominant one by default focus/emphasis — Cancel remains the button a thumb lands on by habit, so a destructive action always requires a deliberate reach.
- **Permission-Priming Dialog** — a custom in-app dialog shown *before* the native OS permission prompt (e.g., Onboarding's notification step, `MED100_UI_UX_SPEC.md` §2e), explaining the "why" in plain language; always has a "Not Now" Tertiary action alongside the primary "Enable" action, since priming only works if declining is genuinely easy, not a dead end.

---

## 9. Bottom Sheets

The generalized pattern behind AI Summary (`MED100_UI_UX_SPEC.md` §14) and any future contextual panel.

**Anatomy:** `DragHandle` (small pill, `label/tertiary`, centered, top of sheet) → `SheetHeader` (Title 3 + optional close X) → `SheetBody` (scrollable once content exceeds available height) → optional sticky `SheetActionRow` footer for primary actions that must stay reachable regardless of scroll position.

- **Compact Sheet** — auto-sized to content height (AI Summary, contextual action menus); rounded top corners only (`radius/sheet-top`, 20pt); dismissible by swipe-down or scrim tap.
- **Expanded Sheet** — supports drag between a compact and a full-height snap point (used for content-heavy panels like a full filter/settings picker on phone width); the drag handle remains the primary affordance communicating "this can move."
- **Non-dismissible Sheet** — rare, reserved for a mandatory acknowledgment (e.g., an updated medical disclaimer the user must accept) — no scrim-tap or swipe dismissal; only the explicit in-sheet action closes it. Used sparingly and never for anything gamified or promotional, only genuine legal/safety acknowledgments.

---

## 10. Navigation

- **Tab Bar** (phone) — four destinations (Home, Bookmarks, Progress, Profile), icon+Caption label, active item in bold icon weight + `accent/foreground`; full-height, full-column tap targets regardless of the icon+label's visual footprint.
- **Navigation Rail** (tablet, regular width) — same four destinations, persistent on the left edge, icon+label shown side-by-side rather than stacked (`MED100_UI_UX_SPEC.md` §21).
- **Nav Bar** (top, per-screen) — three variants:
  - *Standard* — back chevron, Headline-style title, trailing action icon(s) (bookmark, share).
  - *Large-Title* — an iOS-style oversized title (Title 1) that collapses into a Standard-sized title as the user scrolls, used on tab-root screens (Home, Progress, Statistics) to give the destination visual weight on first arrival without permanently consuming vertical space.
  - *Modal* — a close "X" replaces the back chevron, used whenever a screen is presented modally rather than pushed (Subscription, Onboarding, any Dialog/Sheet's own header).
- **TrackContextHeader** — a breadcrumb-style secondary header ("Critical Care Track · Day 14 of 30") used on the Learning Screen, sitting below the Nav Bar rather than replacing it.
- **Segmented Control** — see §5; used navigationally for filters (Bookmarks type filter, Statistics time range) rather than as a tab replacement.
- **Teaching Mode Chrome** — a specialized auto-hiding navigation bar (fades out after a few seconds of inactivity, reappears on tap) — the only navigation variant that intentionally hides itself, since Teaching Mode's whole premise is a clean, chrome-free presentation surface.

---

## 11. Progress Components

- **Progress Ring** (circular) — two sizes: *Small* (32pt, inline use in Quick Stats rows and Track Shelf Cards) and *Large* (120pt+, Progress screen hero). Ring fill uses `accent/fill` up to 100%; a ring that reaches full mastery transitions its fill to `success` as a distinct "complete" signal, not just a maxed-out accent ring.
- **Progress Bar** (linear) — two weights: *Thin* (2pt, the Today's Topic `ReadProgressIndicator` sitting under the nav bar) and *Thick* (6pt, the Onboarding progress bar) — same track/fill token logic as the ring.
- **Step Indicator** (discrete) — textual ("Question 2 of 4," "Card 3 of 12 due today") optionally paired with a dot row for very short sequences (≤6 steps); switches to text-only beyond that, since a row of 20 dots stops being scannable.
- **Streak Badge** — flame icon (bold weight, `warning` tint) + Headline-style count in a `background/secondary` pill, sized to content.
- **Mastery Delta Badge** — a small, transient "+2%" pill that appears after a quiz/flashcard session (`success`-tinted), animates in with `motion/standard` and persists on the summary screen rather than disappearing — the animation announces the change, the badge itself is what a user can actually re-read.
- **Skeleton Shimmer** — not a numeric progress indicator but functionally the same category: a content-shaped placeholder (§18) communicating "more is coming," always shaped like the real content it precedes so no layout jump occurs on load.

---

## 12. Animations

| Token | Duration | Curve | Used for |
|---|---|---|---|
| `motion/micro` | 120ms | ease-out, scale to 0.97 | button/card press feedback |
| `motion/standard` | 300ms | spring (damping ≈0.86, response ≈0.4) | card/sheet/dialog present-dismiss, badge entrance |
| `motion/flip` | 400ms | spring rotation | flashcard flip |
| `motion/macro` | 350ms | standard push/pop curve | screen navigation |

See §18 (Motion Guidelines) for the principles governing *when* and *why* these are applied, not just their timing values.

---

## 13. Elevation

- **Light Mode:** card shadow `0px 2px 8px rgba(15,20,25,0.08)`; sheet/dialog shadow `0px -4px 16px rgba(15,20,25,0.12)` (sheets) or a symmetric soft shadow (dialogs, since they're not edge-anchored).
- **Dark Mode:** **no shadows anywhere.** Elevated surfaces use `surface/elevated` fill (`#1C1F24`) plus a 1px `#2A2E35` border instead — a shadow rendered against `#0B0D10` is nearly invisible and would leave elevated surfaces looking like flat, undifferentiated color blocks. This is a hard rule enforced at the `surface/elevated` token level, not a per-component judgment call.

---

## 14. Corner Radius

`radius/control-sm` 8pt (chips, small badges, segmented-control track) · `radius/control-md` 12pt (buttons, choice buttons, toggle track) · `radius/card` 16pt (all Cards and Medical Cards, Dialogs) · `radius/sheet-top` 20pt (Bottom Sheets, top corners only — bottom corners are square since a sheet meets the screen edge).

---

## 15. Light Theme

Light Mode is the default until a user has expressed a preference (System setting is respected first; `background/primary` white, `label/primary` near-black at 18.6:1, `accent/fill`/`accent/foreground` both `#0A6CFF`, elevation via soft shadow (§13). Every screen in `MED100_UI_UX_SPEC.md` is designed against this theme first — Dark Mode (§16) is a deliberate second pass on the same layouts, not an automatic inversion.

---

## 16. Dark Theme

Not an inverted Light Theme — a separately tuned value set behind the same token names (§1.1). Key departures from a naive inversion:
- Backgrounds are true near-black (`#0B0D10`), not mid-grey, for OLED efficiency and a calmer late-night/night-shift reading experience (a real usage pattern for this audience — residents and ICU nurses reading during overnight shifts).
- Elevation is border+fill, never shadow (§13).
- `accent/foreground` is measurably brighter than its Light-Mode value; `accent/fill` deliberately is not (§1.3).
- Status colors (`success`/`warning`/`danger`) are softened/desaturated slightly relative to their Light-Mode values so they don't visually vibrate against the near-black base.
- Line-art icons re-tint automatically (single-color assets, no dual icon set needed); any illustration with a light background ships a dark-optimized variant.
- Respects the OS System setting by default; explicit override lives in Settings → Appearance (`MED100_UI_UX_SPEC.md` §11).

---

## 17. Accessibility Rules

*(Numbered as addressable subsections — 17.1, 17.2, etc. — specifically so other sections of this document can cite a single rule precisely, rather than pointing at "§17" as an undifferentiated block.)*

### 17.1 Tap targets
Every interactive element, regardless of visual size or text scale, maintains a minimum 44×44pt hit area.

### 17.2 Contrast
Verified per §1.2; `label/tertiary` and any fill/glyph pair measuring below 4.5:1 is restricted to bold/large text or icon-only use, never small regular-weight text (the `danger`/`success` fill rule from §1.2 is the concrete case of this rule, not an exception to it).

### 17.3 Color is never the sole differentiator
Every status distinction pairs color with a shape or icon: MCQ correct/incorrect always carries a checkmark/X glyph alongside the tint (§5.1's ChoiceButton spec), track badges use color plus a text label, sync-pending state uses a distinct glyph plus a dashed border, not tint alone.

### 17.4 Dynamic Type
Every component supports scaling to AX5 (3.12×, §2) without clipping or truncation; no fixed-height text container exists anywhere in the library.

### 17.5 RTL (Arabic)
Full mirroring: text alignment, back-chevron direction, linear progress-bar fill direction, and horizontal motion (page swipes, back-navigation slides) all flip under RTL layout; the FlashcardStack's swipe-to-grade gesture mapping (§6.1) flips correspondingly so "the safer/lighter grade" stays on the same physical thumb-motion side rather than the same literal left/right label.

### 17.6 Reduce Motion
Governed globally at the motion-token layer (§18), not per-component, so no screen can accidentally omit it.

### 17.7 Reduce Transparency
Any translucent surface (the soft-paywall blur overlay on a premium topic, `MED100_UI_UX_SPEC.md` §5) has a fully opaque fallback treatment when this OS setting is enabled, rather than a degraded blur.

### 17.8 Screen reader semantics
Every interactive element carries a label, hint, and role; decorative illustrations are explicitly marked non-accessible rather than read aloud as unlabeled images; a Card's constituent parts (title, badge, progress ring) are grouped as one semantic stop so VoiceOver/TalkBack reads it as one coherent unit, not five fragmented ones.

### 17.9 Live regions
Content that updates without user navigation (a streak count changing on sync, a sync-status indicator resolving) is exposed as an accessible live region so the change is announced, not only visually implied.

### 17.10 Keyboard/focus order
On web and tablet with a hardware keyboard, focus order follows logical reading order (top-to-bottom, leading-to-trailing, mirrored under RTL) with a visible focus ring on every focusable element.

---

## 18. Motion Guidelines

Beyond the duration/curve tokens in §12, motion in Med100 follows four principles:

1. **Spatial continuity, not conjuring.** A sheet rises from the element that triggered it; a card expands from its collapsed position. Nothing simply fades in from nowhere — motion should always answer "where did this come from."
2. **Entrance and exit are not always mirror images.** A sheet's entrance uses the full `motion/standard` spring; a user-initiated swipe-down dismissal responds faster and lighter, since a dismissal the user is actively driving with their finger should feel immediately responsive, not paced by the same timing as an unprompted entrance.
3. **Motion announces a transition; it never is the only carrier of a state.** The Mastery Delta Badge animates in, but the "+2%" value it settles on remains legible and re-readable at rest — if a user missed the animation, the end state alone still communicates everything they need.
4. **RTL-aware direction.** Any motion with a horizontal component (screen push/pop slide, page-swipe onboarding carousel) mirrors direction under RTL layout, consistent with §17.5.

**Reduce Motion override:** every token in §12 is replaced system-wide by a single 150ms cross-fade — no scale, rotation, or directional slide survives when this OS accessibility setting is active. This is the one case where principle 1 (spatial continuity) is deliberately overridden, because for a Reduce-Motion user, the priority is minimizing movement, not narrating causality.

---

## 19. Reusable Component Library — Index

Every component defined in this document, for at-a-glance reference. "Screens" cross-references `MED100_UI_UX_SPEC.md`.

| Component | Category | Key states/variants | Used in (screens) |
|---|---|---|---|
| PrimaryButton / SecondaryButton / TertiaryButton / DestructiveButton | Buttons (§5) | default, pressed, disabled, loading | Nearly every screen |
| IconButton | Buttons (§5) | default, active, disabled | Nav bars, Today's Topic bookmark toggle |
| SegmentedControl | Buttons/Navigation (§5, §10) | selected/unselected per segment | Bookmarks filter, Statistics range, Settings theme |
| Toggle / Switch | Buttons (§5) | on, off, disabled | Settings |
| Chip | Buttons (§5) | selected, unselected | Onboarding specialty selection, Bookmarks filter |
| Content Card / List Row Card / Stat Tile / Track Shelf Card | Cards (§6) | static, tappable-pressed | Home, Statistics, Progress |
| Clinical Pearl Card / Pitfall Card | Medical Cards (§7) | — | Today's Topic, Learning Screen |
| Drug Dosing Card | Medical Cards (§7) | per-drug row | Clinical Reference Companion |
| Protocol/Algorithm Card | Medical Cards (§7) | — | Topic body (procedural content) |
| Exam-Mapping Badge | Medical Cards (§7) | — | Topic header, Medical Cards |
| Alert Dialog / Confirmation Dialog / Permission-Priming Dialog | Dialogs (§8) | — | Sign Out, Delete Account, Onboarding notification step |
| Compact Sheet / Expanded Sheet / Non-dismissible Sheet | Bottom Sheets (§9) | — | AI Summary, filter panels, disclaimer acknowledgment |
| TabBar / NavigationRail | Navigation (§10) | active/inactive | Root of every tab-rooted screen |
| NavBar (Standard/Large-Title/Modal) | Navigation (§10) | — | Every pushed/presented screen |
| TrackContextHeader | Navigation (§10) | — | Learning Screen |
| TeachingModeChrome | Navigation (§10) | visible/auto-hidden | Teaching Mode |
| ProgressRing (Small/Large) | Progress (§11) | 0–100%, complete (success transition) | Home, Progress, Track Shelf Card |
| ProgressBar (Thin/Thick) | Progress (§11) | 0–100% | Today's Topic, Onboarding |
| StepIndicator | Progress (§11) | text-only, dot-row | MCQs, Flashcards |
| StreakBadge | Progress (§11) | — | Home, Progress |
| MasteryDeltaBadge | Progress (§11) | entrance animation, at-rest | MCQ/Flashcard summary |
| SkeletonShimmer | Progress/Loading (§11, §12) | shaped per host component | Any content load >300ms |
| ChoiceButton | Buttons (specialized, §5.1) | neutral, selected, correct, incorrect, offline-pending | MCQs |
| FlashcardStack | Cards (specialized, §6.1) | front, back, flipping | Flashcards, Teaching Mode |
| GradingButtonRow | Cards (specialized, §6.1) | four graded button states, per-button interval preview | Flashcards |
| SwipeGestureLayer | Cards (specialized, §6.1) | additive over GradingButtonRow, never swipe-only | Flashcards |

---

*This document defines the complete design system and component library specification — colors, typography, spacing, icons, and every reusable component in both themes — with no feature implementation. Next phase: production visual assets (icon set, illustrations) built against these tokens, and engineering handoff for componentization.*
