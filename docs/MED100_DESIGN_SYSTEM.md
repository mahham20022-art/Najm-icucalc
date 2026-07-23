# Med100 — Design System & Redlines

**Based on:** `MED100_UI_UX_SPEC.md` Section 0 (Design Foundations)
**Author:** Apple Senior UI/UX Design Team
**Status:** Draft v1.0 — concrete design tokens and component redlines, no implementation code
**Last updated:** 2026-07-23

Where `MED100_UI_UX_SPEC.md` named tokens (`accent`, `success`, `label/primary`...), this document assigns them actual values, verifies contrast against WCAG 2.1 using the relative-luminance formula (not eyeballed), and redlines a handful of the highest-traffic components as a template for the rest. Two real conflicts surfaced during that verification and are resolved explicitly below rather than glossed over — see Sections 1.3 and 1.4.

---

## 1. Color Tokens

### 1.1 Light Mode

| Token | Hex | Used for |
|---|---|---|
| `background/primary` | `#FFFFFF` | screen background |
| `background/secondary` | `#F5F6F8` | grouped-list background, secondary panels |
| `surface/elevated` | `#FFFFFF` + shadow (§3) | cards, sheets |
| `label/primary` | `#0F1419` | primary text |
| `label/secondary` | `#5B6470` | secondary text, captions with informational value |
| `label/tertiary` | `#9AA3AF` | placeholders, decorative timestamps — **never** load-bearing text (see §1.5) |
| `accent/foreground` | `#0A6CFF` | links, active icons, accent text on light backgrounds |
| `accent/fill` | `#0A6CFF` | button/control fill backgrounds (paired with white label — see §1.3) |
| `success` | `#1FAA59` | correct/mastery-positive fills and icons |
| `warning` | `#B8790A` | streak-risk / due-for-review indicators (darkened from the raw amber specifically so it's usable as text, not just fill — see §1.5) |
| `danger` | `#E5484D` | incorrect/destructive fills and icons (see §1.4 for the bold-text requirement this carries) |
| `separator` | `#E3E6EA` | hairlines, list dividers |

### 1.2 Dark Mode

| Token | Hex | Used for |
|---|---|---|
| `background/primary` | `#0B0D10` | screen background — true near-black, OLED-friendly |
| `background/secondary` | `#121417` | grouped-list background |
| `surface/elevated` | `#1C1F24` fill + `#2A2E35` 1px border, **no shadow** | cards, sheets |
| `label/primary` | `#F2F4F6` | primary text |
| `label/secondary` | `#A7AFB9` | secondary text |
| `label/tertiary` | `#6E7681` | placeholders, decorative timestamps |
| `accent/foreground` | `#4C93FF` | links, active icons, accent text on dark backgrounds — brighter than light mode's accent, see §1.3 |
| `accent/fill` | `#0A6CFF` | button/control fill — **same value as light mode**, deliberately not the brighter foreground blue, see §1.3 |
| `success` | `#34C77B` | slightly softened from the light-mode value to avoid vibrating against near-black |
| `warning` | `#F0B94D` | |
| `danger` | `#EB6469` | |
| `separator` | `#2A2E35` | |

### 1.3 Why accent is two tokens, not one (a real conflict found during verification)

The UI/UX spec said Dark Mode's accent "shifts brighter to maintain contrast against near-black." That's true for accent used *as a foreground* (text, icons, links sitting directly on the dark background) — `#4C93FF` on `#0B0D10` measures **6.42:1**, comfortably clearing the 4.5:1 body-text minimum.

But the same brighter blue fails badly as a *button fill* with a white label: white text on `#4C93FF` measures only **3.03:1** — well under 4.5:1. A single accent value can't serve both roles well, because "bright enough to read against black" and "dark enough for white text to read on top of it" pull in opposite directions.

**Resolution:** `accent/fill` keeps the light-mode value (`#0A6CFF`) in both themes for button/control backgrounds — white-label contrast is **4.56:1**, meeting the 4.5:1 floor (with the caveat in §1.5 about margin), and the fill itself measures 4.26:1 against the dark background, clearing the separate 3:1 non-text-UI-component requirement. `accent/foreground` is the only token that actually changes between themes, used strictly for accent-colored content sitting directly on the background (links, active tab glyph), never as a button fill.

### 1.4 Danger fill requires bold/large text (a second real conflict found during verification)

White text on `danger` fill (`#E5484D`) measures **3.91:1** — below the 4.5:1 floor for regular-weight body text, but above the 3:1 floor WCAG allows for **bold text ≥14pt or regular text ≥18pt** ("large text"). Every destructive button label in the spec (Sign Out, Delete Account) already uses the Headline style (17pt, semibold) — which qualifies as large/bold text — so this is compliant as specified, but only *because* of that weight choice. **Rule going forward: nothing renders in regular weight directly on a `danger` or `success` fill; only semibold-or-heavier labels or icon glyphs.** `success` fill has the identical shape of problem (white icon-on-fill measures ~3.02:1, right at the graphical-object floor) for the same reason and carries the same rule.

### 1.5 Contrast verification table (computed via WCAG relative luminance, not estimated)

| Pair | Ratio | Verdict |
|---|---|---|
| `label/primary` on `background/primary` (light) | 18.6 : 1 | Passes AAA |
| `label/secondary` on `background/primary` (light) | 6.0 : 1 | Passes AA |
| `label/primary` on `background/primary` (dark) | 17.7 : 1 | Passes AAA |
| `label/secondary` on `background/primary` (dark) | 8.8 : 1 | Passes AA |
| `accent/foreground` on `background/primary` (light) | 4.6 : 1 | Passes AA, tight — reserve for Body size or larger, never Caption |
| `accent/foreground` on `background/primary` (dark) | 6.4 : 1 | Passes AA |
| White label on `accent/fill` (both themes) | 4.6 : 1 | Passes AA for normal text, tight margin |
| White label on `danger` fill (both themes) | 3.9 : 1 | Passes only at bold/large text — see §1.4 |
| White glyph on `success` fill (both themes) | 3.0 : 1 | Passes graphical-object floor only, minimal margin |

`label/tertiary` is intentionally **not** in this table — it does not clear 4.5:1 in either theme by design, which is why §1.1/1.2 restrict it to decorative, non-essential use (placeholder text, redundant timestamps already conveyed elsewhere) rather than anything a user must read to use the app. Full asset-level contrast QA still happens once real icon/illustration assets exist; this table covers the highest-traffic text/fill pairs, not an exhaustive combinatorial check.

### 1.6 Specialty track color coding

Each specialty track gets one hue from a fixed 8-color rotation (used only for the small track badge/pill, never for anything status-bearing so it can't be confused with success/warning/danger): a desaturated, light-mode-appropriate tint with a darker label-colored text, and an equivalent lower-luminance dark-mode tint — assigned at content-publish time, stable per specialty so a track's color never changes once a user has learned to recognize it.

---

## 2. Typography Scale

Same point sizes and weights in both themes — only `label/*` color changes.

| Style | Size / Line-height | Weight | Tracking | Typical use |
|---|---|---|---|---|
| Display | 34 / 41 | Bold | −0.4 | Splash tagline, hero milestone numbers |
| Title 1 | 28 / 34 | Bold | −0.3 | Screen-level titles (Statistics summary) |
| Title 2 | 22 / 28 | Bold | −0.2 | Section headers |
| Title 3 | 20 / 25 | Semibold | −0.1 | Card titles |
| Headline | 17 / 22 | Semibold | −0.1 | Button labels, list row titles |
| Body | 17 / 22 | Regular | 0 | Topic body text, question stems |
| Callout | 16 / 21 | Regular | 0 | Secondary body content |
| Subheadline | 15 / 20 | Regular | 0 | Metadata rows |
| Footnote | 13 / 18 | Regular | 0 | Timestamps, fine print |
| Caption | 12 / 16 | Regular | +0.1 | Badges, tags |

**Dynamic-Type-equivalent scaling** (multiplier applied to the sizes above, mirroring iOS's Dynamic Type steps): xSmall 0.82× · Small 0.88× · Medium 0.94× · **Large 1.00× (default)** · xLarge 1.12× · xxLarge 1.24× · xxxLarge 1.36× · Accessibility-1 1.64× · Accessibility-2 1.96× · Accessibility-3 2.35× · Accessibility-4 2.76× · Accessibility-5 3.12×. No container in the app has a fixed height that would clip text at the top of this range — confirmed per-screen in `MED100_UI_UX_SPEC.md` §0.

---

## 3. Spacing, Radius & Elevation

**Spacing tokens (8pt grid, 4pt for micro-gaps):** `space-1` 4 · `space-2` 8 · `space-3` 12 · `space-4` 16 · `space-5` 24 · `space-6` 32 · `space-7` 48 · `space-8` 64.

**Screen margins:** phone 16pt · tablet compact-width 24pt · tablet regular-width 32–48pt (with the reading column additionally capped per `MED100_UI_UX_SPEC.md` §21, not simply stretched to the margin).

**Corner radius:** `radius/control-sm` 8pt (chips, small badges) · `radius/control-md` 12pt (buttons, choice buttons) · `radius/card` 16pt · `radius/sheet-top` 20pt (bottom sheet top corners only).

**Elevation — Light Mode:** card shadow `0px 2px 8px rgba(15,20,25,0.08)`; sheet shadow `0px -4px 16px rgba(15,20,25,0.12)`.

**Elevation — Dark Mode:** no shadow anywhere (per §1.2's rationale); elevated surfaces are `surface/elevated` fill (`#1C1F24`) plus a 1px `#2A2E35` border. This is a hard rule, not a preference — shadows rendered against `#0B0D10` are close to invisible and would leave elevated surfaces looking like flat color blocks with no separation cue at all.

---

## 4. Iconography

24×24pt canvas, 1.5pt stroke for the regular/inactive weight, 2pt stroke for the bold/active weight (tab bar selection, toggled states), 2pt corner radius on stroke terminals for a consistent soft-edge character across the whole set. Icons inherit `label/secondary` when inactive and `accent/foreground` when active — never a hardcoded color baked into the asset, so the single icon set works unmodified across both themes.

---

## 5. Motion Tokens

| Token | Duration | Curve | Used for |
|---|---|---|---|
| `motion/micro` | 120ms | ease-out, scale to 0.97 | button-press feedback |
| `motion/standard` | 300ms | spring (damping ≈0.86, response ≈0.4) | card/sheet present-dismiss |
| `motion/flip` | 400ms | spring rotation | flashcard flip |
| `motion/macro` | 350ms | standard push/pop curve | screen navigation |

**Reduce Motion:** every token above is replaced system-wide by a single 150ms cross-fade — no scale, rotation, or slide survives when the OS accessibility setting is on. This is enforced at the motion-token layer, not per-component, so no individual screen can accidentally forget to respect it.

---

## 6. Component Redlines

A template pass on the highest-traffic components; the remaining components in `MED100_UI_UX_SPEC.md` follow the same token references.

### 6.1 PrimaryButton
Height 50pt · horizontal padding `space-4` (16pt) · corner radius `radius/control-md` (12pt) · fill `accent/fill` · label: Headline style, white, centered · disabled state: fill drops to 40% opacity, label unchanged (opacity-based disabling keeps the same hue rather than swapping to a grey that could read as a different control) · pressed state: `motion/micro` applied, fill darkens 8%.

### 6.2 ChoiceButton (MCQ answer option)
Full-width minus margins · min height 56pt (comfortably exceeds the 44pt tap-target floor even at large Dynamic Type sizes) · corner radius `radius/control-md` · 1.5pt border.
- Neutral: border `separator`, fill `background/secondary`, label `label/primary`.
- Selected (pre-submit): border `accent/foreground` at 2pt, fill unchanged.
- Correct (post-submit): fill `success` at 12% tint (not full-strength — full-strength `success` is reserved for the small checkmark glyph itself, per §1.4's bold/icon-only rule), border `success` 2pt, trailing checkmark glyph in full-strength `success`.
- Incorrect (post-submit): fill `danger` at 12% tint, border `danger` 2pt, trailing X glyph in full-strength `danger`; the correct choice simultaneously renders in its Correct state so the right answer is never ambiguous.
- Offline-pending: fill `background/secondary`, border `separator` dashed, trailing sync-pending glyph in `label/tertiary`.

### 6.3 StreakBadge
Flame icon (bold weight, `warning` tint) + Headline-style count, horizontal `space-2` gap, contained in a `radius/control-sm` pill with `background/secondary` fill — sized to its content, not stretched, since it sits inline in the Home header.

### 6.4 TabBar item
Icon 24pt (regular weight inactive, bold weight + `accent/foreground` tint active) above a Caption-style label, `space-1` gap between them, full tap target extends to the tab's full column width and the bar's full height regardless of the icon+label's visual footprint.

### 6.5 FlashcardStack card
16:10 aspect ratio at phone widths (capped max-width at tablet widths per `MED100_UI_UX_SPEC.md` §21) · `radius/card` corners · `surface/elevated` fill · front-face centers `Title 2` style prompt text with generous internal padding (`space-6`) so short and long prompts both sit optically centered · flip uses `motion/flip`.

---

*This document defines design tokens and representative component redlines only — no implementation code, no production icon/illustration assets. Next phase: full component redline pass covering every remaining component named in `MED100_UI_UX_SPEC.md`, and production asset creation (icon set, illustrations) against the tokens defined here.*
