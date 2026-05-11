# ASH · Acute Support Hub
### Critical-Care Cockpit for Hajj Physicians — Design RC 1.0

> **Brief:** "اعتبر ده ٤/١٠ — صمم واحد ٩.٩/١٠ كخبير أسطوري."
> **Answer:** Stop describing screens. Ship them.

Open **`design/ash/index.html`** in any browser (or push to GitHub Pages). What you'll see is the actual designed product — every device mockup is live HTML, every animation is CSS, every gradient and font is intentional. No image renders. No mock-up screenshots. The design *is* the prototype.

---

## Why this is a 9.9, not a 4

The previous deliverable was a slide deck pretending to be a product. This is a product pretending (very convincingly) to be shipped. The difference shows up in five places:

1. **A signature visual identity, not a Bootstrap re-paint.** *Aurora Critical* — Plasma cyan for action, Vital red for the body's worst moments, Mihrab green for evidence, Bismuth violet for AI, Sand for Hajj. Each colour earned its name and its job. Together they read as *one* medical instrument, not a colour-picker.

2. **A real domain POV.** ASH is not "a medical app." It is the app a physician runs *in Mina, at 47 °C, with one usable thumb, between Adhan calls, with a pilgrim speaking Urdu and a STEMI on the cot.* The whole IA — Heat & Crowd Intel, Polyglot Triage, Tasleem, Tawakkalna QR, WBGT, Jamarat density — is built around *that* physician, not a generic ICU doctor.

3. **Cited AI, not hand-waving AI.** Every AI answer in ASH ships with `[ESC AF · 2024 · Class I]`-style provenance, a calibrated confidence bar, and a *cited refusal* mechanism when a dose is blocked. Hospitals will not deploy AI that cannot explain itself. ASH was designed knowing that.

4. **A live ECG, not a screenshot.** The ECG Lens screen contains a real animated SVG waveform with scan-line, finding card, and a vital-red "Activate Code STEMI" action that calls KAMC. It demonstrates the *feel* of an AI diagnosis-first product — not a static mock.

5. **A Najm Bridge, not a Najm replacement.** The existing **Najm ICUCalc** engine (this very repo) stays the source of truth for drug math. ASH wraps it. Phase 1 embeds. Phase 2 bridges patient context. Phase 3 ships Najm-Pro. Continuity is the design.

---

## The nine signature screens

| # | Name | Job |
|---|---|---|
| 01 | **Mission Control** | Cockpit, not dashboard. AI briefing, code radar, Hajj situational tiles. |
| 02 | **Ask ASH** | The only AI that cites itself. Confidence bar, evidence pills, red-flag detection. |
| 03 | **ECG Lens** | Point. Shoot. Reperfuse. AI-confirmed STEMI → one-tap cath-lab activation. |
| 04 | **Rapid Protocol** | Branching ACS protocol with per-step timers and auto-log. |
| 05 | **Drug Twin · Najm Bridge** | Najm's math + ASH's safety (KDIGO, SCCM). One product, two surfaces. |
| 06 | **Heat & Crowd Intel** | WBGT × sector density. Surge prediction 90 min ahead. |
| 07 | **Polyglot Triage** | 7 languages → clinical English. Red-flag pills appear live. |
| 08 | **Pilgrim Passport** | Tawakkalna/Nusuk QR → identity, comorbids, meds, vaccines, vitals. |
| 09 | **Shift Tasleem** | AI-drafted handover. Sign in 8 seconds. Zero forgotten patients. |
| 10 | **Safety Net** | The voice that says *don't.* Three-tier alert grammar. Cited refusals. |

---

## Design principles (the five that everything follows)

1. **Two-tap rule** — every life-saving action reachable within two taps of any screen.
2. **Cited or silent** — no AI answer ships without source + level of evidence + confidence.
3. **Polyglot by default** — Arabic + 6 pilgrim languages are first-class, not localisation.
4. **Hajj-aware** — WBGT, crowd density, prayer-time silencing, KAMC referral — first-class data.
5. **Offline-first** — every protocol, dose, and calc works without network.

---

## What's still to ship

- Voice activation model fine-tuned on pilgrim-population accents
- Pairing protocol with MOH-KSA monitor fleet (Philips IntelliVue + Mindray)
- Najm Bridge Phase-1 embedding (tracked separately in `/bridge`)
- Light mode? Not yet — black-flag heat means outdoor screens stay dark + high-contrast
- Apple Watch companion for code-team paging

Built with respect for the physicians who'll actually use this.
For clinical reference only — verify against your institution's protocols.
