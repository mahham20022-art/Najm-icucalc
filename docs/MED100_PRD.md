# Med100 — Product Requirements Document

**Tagline:** One Topic. Every Day. Master Your Specialty.
**Designed by:** Dr. Mohamed Najm
**Document owner:** Product Management
**Status:** Draft v1.0
**Last updated:** 2026-07-23

---

## 1. Vision

Every doctor, nurse, and medical student on Earth has access to the same depth of specialty mastery as a professor at a top academic hospital — one focused topic at a time, every single day, for life.

Med100 becomes the daily habit layer for medical knowledge: the way Duolingo owns language learning and Strava owns fitness, Med100 owns clinical mastery. In five years, "Did you do your Med100 today?" is a normal question in hospital break rooms from Cairo to Chicago to Manila.

## 2. Mission

To make world-class, specialty-specific medical education a 5-minute daily habit — accessible, affordable, and rigorous enough to trust with a patient's life — for every clinician and learner, regardless of where they trained or which language they speak.

## 3. Philosophy

1. **Depth through repetition, not cramming.** Medicine is forgotten as fast as it's learned. Med100 is built on spaced repetition and daily micro-dosing of knowledge, not marathon study sessions.
2. **One topic, fully owned.** Each day delivers a single, tightly-scoped clinical topic — not a firehose. Mastery is built topic-by-topic, specialty-by-specialty.
3. **Clinician-built, not content-farmed.** Every module is authored or reviewed by practicing specialists and mapped to real board/licensing curricula — not generic content scraped from textbooks.
4. **Global by default.** Multi-language, multi-guideline (covering regional practice variance — e.g., ESC vs. AHA, WHO vs. national protocols), and priced for both a resident in Lagos and an attending in Los Angeles.
5. **Respect the learner's time.** Clinicians are the busiest professionals alive. Every interaction is designed for a 3–7 minute daily window: commute, break room, before bed.
6. **Evidence over vanity.** Success is measured in retention, exam pass rates, and clinical confidence — not vanity metrics like streak counts alone (though streaks help habit formation).

## 4. Target Users

| Segment | Description | Primary Need |
|---|---|---|
| Medical students (pre-clinical & clinical) | Studying for USMLE, PLAB, MCCEE, national boards | Structured daily review, exam-mapped content |
| Residents / Registrars | Training within a specialty (IM, surgery, EM, peds, etc.) | Specialty-deep daily learning tied to rotations |
| Attending physicians / Consultants | Practicing specialists maintaining CME/CPD | Rapid guideline updates, recertification credit |
| Nurses & Allied Health (ICU, ER, OR) | Critical care nurses, paramedics, PAs, NPs | Protocol-level daily competency (e.g., drug dosing, algorithms) |
| International Medical Graduates (IMGs) | Preparing for licensing exams abroad (USMLE, PLAB, AMC) | Bridging curriculum gaps, exam-specific tracks |
| Medical schools & hospitals (B2B) | Institutions wanting structured CME/education programs | White-labeled cohort tracking, compliance reporting |

## 5. User Personas

### Persona 1 — "Dr. Amara, the Resident"
- 28, second-year Internal Medicine resident, Lagos, Nigeria
- Works 70-hour weeks, studies on the bus and during downtime
- Goal: pass her specialty board exam in 18 months while surviving rotations
- Pain: existing resources (huge textbooks, generic question banks) don't fit her fragmented time
- Med100 use: 5-minute daily Internal Medicine topic + weekly quiz, on low-bandwidth mobile data

### Persona 2 — "Dr. Chen, the ICU Attending"
- 41, critical care consultant, Toronto, Canada
- Needs to stay current on evolving sepsis/ventilator guidelines, maintain CME credits
- Pain: CME content is often outdated, boring, and disconnected from bedside practice
- Med100 use: Daily "ICU Pearl" + monthly guideline-update deep dive, tracks CME credits automatically

### Persona 3 — "Nurse Priya, the ICU Nurse"
- 26, ICU staff nurse, Mumbai, India
- Wants to build clinical confidence and move toward becoming a charge nurse
- Pain: nursing education content is either too basic or written for physicians
- Med100 use: Nursing-track daily topics (drug titration, hemodynamics), badges toward promotion portfolio

### Persona 4 — "Sarah, the Med Student"
- 24, third-year medical student, London, UK
- Preparing for finals and PLAB/USMIE Step exams simultaneously
- Pain: overwhelmed by scope, needs daily discipline and cannot self-structure a study plan
- Med100 use: Daily topic aligned to her rotation + exam-mode flashcard review before bed

### Persona 5 — "Dr. Al-Farsi, the Program Director" (B2B buyer)
- 52, Dean of Postgraduate Medical Education, Riyadh, Saudi Arabia
- Needs to demonstrate structured, trackable CME for 200 residents across specialties
- Pain: no easy way to verify residents are engaging with education outside clinical hours
- Med100 use: Institutional dashboard, cohort compliance reports, custom specialty tracks

## 6. Core Features

1. **Daily Topic Engine** — One curated topic per day per specialty track, delivered as a push notification/email at the user's chosen time.
2. **Micro-Learning Format** — Each topic: 3–5 min read/video + high-yield summary card + 3–5 question quiz + spaced-repetition flashback of prior topics.
3. **Specialty Tracks** — Internal Medicine, Surgery, Pediatrics, OB/GYN, Emergency Medicine, Critical Care/ICU, Cardiology, Nursing, and expanding library.
4. **Spaced Repetition Engine (SRE)** — Adaptive algorithm resurfaces past topics at intervals (1/3/7/21/60 days) based on quiz performance.
5. **Streaks & Mastery Score** — Gamified daily streak, per-specialty "Mastery %" score, leaderboard (optional, toggleable).
6. **Exam-Mode Tracks** — Curated sequences mapped to USMLE Step 1/2/3, PLAB, MCCEE, national board exams, with countdown-based pacing.
7. **Offline Mode** — Full-day topic downloadable for low-connectivity regions.
8. **Multi-language Content** — English, Arabic, French, Spanish, Portuguese at launch; expanding roadmap.
9. **CME/CPD Credit Tracking** — Auto-logged continuing education credits with exportable certificates (for accredited content).
10. **Clinical Reference Companion** — Quick-access calculators and protocol cards (leveraging Dr. Najm's existing ICU drug calculator work) tied contextually to daily topics.
11. **Community & Discussion** — Light-touch, moderated topic-specific discussion thread per day (optional, can be muted).
12. **Institutional Dashboard (B2B)** — Cohort progress tracking, compliance reporting, custom track assignment for hospitals/med schools.

## 7. MVP Scope

**Goal:** Validate the core daily-habit loop with one specialty vertical before horizontal expansion.

**In scope for MVP:**
- 1–2 launch specialty tracks (recommend: **Internal Medicine** + **Critical Care/ICU**, leveraging Dr. Najm's existing ICU domain expertise and calculator asset)
- Daily topic delivery (push notification + in-app) with text + image content (video deferred)
- Core quiz (3–5 MCQs) per topic with instant feedback
- Basic spaced-repetition flashback (simple fixed intervals, not fully adaptive ML)
- Streak tracking + basic Mastery % per track
- iOS + Android app (single codebase, e.g., React Native/Flutter) + responsive web
- English + Arabic content
- Free tier + single Premium tier (see below) with basic paywall
- Manual content pipeline (in-house clinical editorial team, no AI-authored content at launch — physician-reviewed only)
- Basic account system, notification preferences, offline caching of last 7 days

**Explicitly out of scope for MVP:** institutional dashboards, CME accreditation, community discussion threads, adaptive ML-based SRE, video content, additional languages, additional specialty tracks.

## 8. Premium Features (Post-MVP / Subscription Tier)

- Full specialty track library (all specialties, unlocked)
- Exam-Mode tracks (USMLE, PLAB, MCCEE, national boards) with countdown pacing
- Full adaptive spaced-repetition engine (ML-personalized intervals)
- CME/CPD accredited certificates, exportable transcripts
- Advanced analytics ("your weak topics," peer benchmarking)
- Offline full-library download
- Ad-free / distraction-free mode
- Priority access to new specialty tracks and monthly guideline updates
- Clinical Reference Companion full suite (calculators, protocol libraries)

## 9. Future Roadmap

**Phase 1 (0–6 months): Foundation**
Launch MVP with 2 tracks, EN/AR, iOS/Android/Web, core loop validated (target: D30 retention, quiz completion rate).

**Phase 2 (6–12 months): Depth & Breadth**
Add 6+ specialty tracks, video content, French/Spanish/Portuguese, adaptive SRE v1, CME accreditation partnerships (ACCME, EACCME equivalents), community threads.

**Phase 3 (12–24 months): Institutional & AI**
B2B institutional dashboards, hospital/med-school licensing, AI-assisted (physician-supervised) content authoring to scale topic production, personalized daily topic ordering via ML, integration with hospital LMS systems.

**Phase 4 (24–36 months): Platform & Ecosystem**
Med100 Certification (recognized micro-credentials), live case discussions with specialists, API/SDK for partner integration (EHR vendors, medical publishers), Med100 for nursing/allied health as a distinct branded vertical, expansion into veterinary/dental adjacent verticals.

**Long-term:** Med100 becomes the default "continuing competency" layer referenced by licensing bodies and hospital credentialing committees worldwide — a recognized signal of active, current clinical knowledge.

## 10. User Journey

1. **Discovery** — User hears about Med100 via a resident WhatsApp group, Instagram/X clip from Dr. Najm, or hospital recommendation.
2. **Onboarding** — Downloads app → selects role (student/resident/attending/nurse) → selects specialty track(s) → selects exam goal (optional) → sets daily notification time.
3. **First Topic (Aha moment)** — Receives push notification at chosen time → opens 4-minute topic → answers quiz → sees "Day 1 streak started" + Mastery % appear.
4. **Habit Formation (Day 2–14)** — Daily notification becomes routine; spaced-repetition flashbacks reintroduce Day 1–3 content; streak counter builds emotional investment.
5. **Value Realization (Week 3–4)** — User notices real clinical recall improvement (e.g., recalls a dosing fact at bedside); free-tier paywall hit (e.g., 2nd specialty track locked) prompts upgrade consideration.
6. **Conversion** — User upgrades to Premium during a moment of high motivation (e.g., 30 days before board exam, or after a near-miss clinical moment where they wished they'd known something).
7. **Retention & Advocacy** — User maintains 100+ day streak, shares Mastery % milestone on social/LinkedIn, invites colleagues/co-residents (referral loop), institution notices adoption and inquires about B2B license.

## 11. Success Metrics

**Engagement (Habit Health)**
- D1 / D7 / D30 retention (target: D30 ≥ 35%, best-in-class habit apps benchmark)
- Daily Active Users / Monthly Active Users (DAU/MAU ratio, target ≥ 40%)
- Average streak length; % of users with 7+/30+/100+ day streaks
- Daily topic completion rate (target ≥ 70% of notified users)

**Learning Outcomes**
- Quiz score improvement over time (per-user learning curve)
- Spaced-repetition recall accuracy at 7/21/60-day intervals
- Self-reported clinical confidence (quarterly in-app survey)
- Board/licensing exam pass-rate lift for Exam-Mode cohort (post-launch survey/partnership data)

**Business**
- Free-to-Premium conversion rate (target 3–6% within first 3 months, SaaS/edtech benchmark)
- MRR / ARR growth
- CAC vs. LTV (target LTV:CAC ≥ 3:1)
- B2B institutional contracts signed (Phase 3+)
- Net Promoter Score (NPS) among clinicians (target ≥ 50)

**Content Quality**
- % topics reviewed/approved by board-certified specialists (target: 100%)
- Content freshness (time since last guideline-alignment review, target < 12 months per topic)

## 12. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Clinical inaccuracy in content | High — patient safety, legal liability, trust destruction | Mandatory dual physician review + citation to primary guidelines; clear "for educational purposes" disclaimers; versioned content audit trail |
| Regulatory / medical device classification ambiguity | Medium-High — some jurisdictions may scrutinize clinical decision-support features (e.g., calculators) | Legal review per market; clearly position as educational, not diagnostic/prescriptive tool; avoid patient-specific dosing recommendations |
| Content production bottleneck (scaling specialist-authored content) | High — MVP-to-scale gap | Build editorial partnerships with medical societies/universities early; phased AI-assist with mandatory human sign-off |
| Low-bandwidth / low-income market access | Medium — target users include emerging markets | Offline mode, lightweight app size, regional pricing tiers |
| Habit fatigue / notification blindness | Medium — core loop depends on daily engagement | Smart notification timing (ML-adjusted), streak-freeze/grace mechanics, content variety |
| Competitive response from incumbents (UpToDate, Osmosis, Amboss) | Medium — well-funded competitors could copy format | Move fast on specialty depth + community + Dr. Najm's clinical brand/credibility as differentiator |
| Language/localization quality | Medium — literal translation ≠ clinically accurate localization | Native-speaking specialist reviewers per language, not machine translation alone |
| Data privacy / health data regulations (HIPAA/GDPR-adjacent, though not PHI) | Medium — user learning data, quiz performance considered sensitive professional data | Privacy-by-design architecture, clear data policy, regional data residency where required |
| Monetization resistance in price-sensitive markets (residents, students) | Medium — target users often have limited discretionary income | Tiered/regional pricing (PPP-adjusted), institutional sponsorship models, student discounts |

## 13. Competitive Analysis

| Competitor | Strength | Weakness | Med100 Differentiation |
|---|---|---|---|
| **UpToDate** | Gold-standard point-of-care reference, trusted by institutions | Reference tool, not a learning habit; expensive; not designed for daily active recall | Med100 is a daily habit product, not a lookup tool — built for retention, not just reference |
| **Amboss** | Strong USMLE/exam content, good qbank | Exam-focused, less oriented to practicing attendings/ongoing CME; content-dense, not micro-dose | Med100 targets the full career arc (student → attending), not just exam prep; true micro-learning format |
| **Osmosis** | Engaging video content, strong student brand | Primarily pre-clinical/student focus; limited specialty depth for practicing clinicians | Med100 goes deeper into specialty practice and post-graduate/attending-level content |
| **Duolingo (habit-model analog)** | Best-in-class daily habit mechanics, gamification | Not medical, no clinical rigor | Med100 borrows the habit engine but applies clinical-grade rigor and specialist authorship |
| **Medscape / CME apps** | Broad reach, free CME content | Generic, ad-heavy, not personalized or habit-structured | Med100 offers structured daily progression + personalization, not a passive content dump |
| **Hospital-internal CME programs** | Institutional trust, compliance-driven | Static, boring, low completion rates, not mobile-first | Med100 offers a modern, mobile-native, engaging alternative institutions can license |

**Whitespace Med100 owns:** No major player currently combines (a) daily micro-learning habit mechanics, (b) specialty-deep physician-authored content, (c) full career-arc coverage (student → nurse → resident → attending), and (d) global/multi-language accessibility in one product. This is Med100's defensible position.

## 14. Monetization Strategy

**Model: Freemium subscription (B2C) + Institutional licensing (B2B), following the proven habit-app playbook (Duolingo/Strava model applied to medical education).**

1. **Free Tier**
   - 1 specialty track, daily topic + quiz
   - Basic streak tracking
   - Limited spaced-repetition (recent topics only)
   - Ad-free (education context — no ads; monetization via subscription, not advertising, to preserve clinical trust)

2. **Premium (Individual) — subscription, monthly/annual**
   - Est. pricing: $9–15/month or $79–120/year in high-income markets; PPP-adjusted regional pricing (e.g., $2–5/month) in emerging markets
   - All specialty tracks, Exam-Mode, full adaptive SRE, CME credits, advanced analytics, offline full library
   - Student discount tier (~40–50% off, verified via .edu/institutional email)

3. **Institutional / B2B Licensing (Phase 3+)**
   - Per-seat annual licensing for hospitals, residency programs, medical schools
   - Includes cohort dashboards, compliance reporting, custom track curation, SSO integration
   - Pricing: negotiated enterprise contracts, likely $50–150/seat/year depending on scale and features

4. **Strategic/Sponsorship Revenue (longer-term, carefully gated)**
   - Non-promotional educational grants from medical societies/pharma foundations for guideline-update content sponsorship (with strict editorial firewall and clear disclosure — no product promotion, no influence over clinical content)
   - Certification/credential fees for Med100 Certified tracks (Phase 4)

5. **Referral Growth Loop**
   - Streak-milestone social sharing, "invite a colleague, unlock a bonus track" mechanics to drive organic, zero-CAC growth within hospital/residency social networks — a naturally viral distribution channel given how tightly clinicians cluster socially by cohort and institution.

**Key monetization principle:** Never let pricing be a barrier to core medical safety knowledge — critical/ICU protocol content relevant to patient safety should remain accessible even to free-tier users, with monetization focused on breadth, exam-prep, and institutional features rather than gating safety-critical information.

---

*This PRD is a living document and will be revised as user research, pilot data, and specialist advisory board input become available.*
