# Najm ICUCalc

> Adult ICU continuous-infusion **dose & pump-rate (mL/hr) calculator** — fast, offline-capable, and installable.

A single-purpose web app for the bedside: enter the patient's weight, pick a bag
concentration, and get the infusion pump rate in **mL/hr** for common critical-care
drips — with the correct, drug-specific dosing units.

> ⚠️ **Clinical reference only.** Doses are typical adult ranges and may differ
> from your institution's protocols. Always independently verify every dose,
> concentration, and pump rate against a current formulary and local ICU
> guidelines before administration. This tool does not replace clinical judgement.

---

## Features

- **Correct, drug-specific units** — `mcg/kg/min`, `mcg/kg/hr`, `mg/kg/hr`,
  `mg/hr`, `units/min`, etc. (the previous version labelled everything `mcg/min`).
- **Real pump-rate output** — converts a dose at a chosen bag concentration into
  an actual **mL/hr** rate, plus the full min–max range.
- **Selectable standard concentrations** per drug (e.g. norepinephrine 16 / 32 / 64 mcg/mL).
- **Target-dose slider** — dial in a specific dose and read the exact rate live.
- **Safety guardrails** — flags doses above the usual maximum; prompts for weight
  on weight-based drugs.
- **21 common ICU infusions** across 4 categories: vasopressors/inotropes,
  sedation/analgesia, antihypertensives/vasodilators, and other infusions.
- **Search/filter**, **light & dark themes**, **print/export** layout.
- **Offline-first PWA** — installable to a home screen, works with no signal.
  Weight and settings persist on-device (localStorage); no data leaves the device.
- Accessible: labelled controls, keyboard-operable, focus-visible, reduced-motion aware.

## How the rate is calculated

Rates are normalised to a per-hour mass, then divided by the bag concentration:

```
mass/hr = dose × (weight if weight-based) × (60 if dose is per-minute)
rate (mL/hr) = mass/hr ÷ concentration (same mass unit per mL)
```

## Run it

It's a static site — no build step.

```bash
# any static server works; for example:
python3 -m http.server 8080
# then open http://localhost:8080
```

Or just open `index.html` directly (the service worker / install prompt needs
`http(s)`, but the calculator itself works from `file://`).

### Install as an app
Open it in a mobile or desktop browser and choose **Add to Home Screen / Install**.
After the first load it runs fully offline.

## Project structure

| File | Purpose |
|------|---------|
| `index.html` | The entire app — UI, drug data, and calculation logic |
| `manifest.webmanifest` | PWA metadata (name, icons, display) |
| `sw.js` | Service worker for offline caching |
| `icon.svg` | App / home-screen icon |

## Drug data & accuracy

Drug ranges and standard concentrations follow widely-published adult
critical-care references and are intended as a starting point, **not** as
institutional protocol. When deploying in a clinical setting, review and adjust
the `DRUGS` array in `index.html` to match your local formulary, then bump the
`CACHE` version in `sw.js` so devices pick up the change.

## License

Provided as-is for educational and reference use. No warranty; not a medical device.
