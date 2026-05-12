# Najm ICUCalc

Weight-based ICU drug dose calculator — fast, offline-ready, and built for the bedside.

Najm ICUCalc gives critical-care clinicians instant min–max infusion ranges
for sedation, vasopressors, inotropes, antihypertensives, and antiarrhythmics,
adjusted live as patient weight is entered.

## Features

- **Live calculation** — every drug recalculates as you type the weight.
- **Working navigation** — smooth-scroll anchor links (`#calculator`, `#drugs`, `#features`, `#faq`, `#cta`) with an active-section indicator.
- **Drug search & filter** — by name, generic class, or category.
- **Safety-coded ranges** — color hints for narrow vs. wide therapeutic windows.
- **Pulse / ECG UI** — animated heart-rate and waveform indicators for an at-a-glance "alive" feel.
- **Installable PWA** — works offline once loaded, installable on phones, tablets and desktops.
- **Native share / copy-link** — share the calculator from the CTA bar.
- **Respects reduced-motion** preferences.

## Running locally

It's a single static page. Open `index.html` directly in any modern browser, or serve the folder:

```bash
python3 -m http.server 8080
# then open http://localhost:8080/
```

## File layout

```
index.html              # the full app (markup, styles, drug database, behavior)
manifest.webmanifest    # PWA metadata (name, icons, theme color, offline scope)
README.md               # this file
```

## Drug coverage

| Category          | Drugs                                                                      |
|-------------------|----------------------------------------------------------------------------|
| Sedation          | Fentanyl, Propofol, Midazolam, Dexmedetomidine, Ketamine, Morphine         |
| Vasopressors      | Norepinephrine, Epinephrine, Phenylephrine, Vasopressin                    |
| Inotropes         | Dopamine, Dobutamine, Milrinone                                            |
| Antihypertensives | Esmolol, Nicardipine, Labetalol, Nitroglycerin, Sodium nitroprusside       |
| Antiarrhythmics   | Amiodarone, Lidocaine, Diltiazem                                           |

Ranges are encoded in `index.html` in the `DRUGS` array — edit there to adjust.

## Disclaimer

Najm ICUCalc is provided for clinical reference only. Doses must be verified
against institutional protocols, drug labels, and the patient's clinical
condition. The authors assume no liability for clinical decisions made with
this tool.
