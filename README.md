# Najm ICUCalc

Weight-based ICU drug dosing and clinical calculators — a single-file HTML app. Works offline, installable as a PWA, no build step, no dependencies.

## Features

### Infusions tab
Weight-based dose ranges across four categories:
- **Sedation & Analgesia** — fentanyl, propofol, midazolam, dexmedetomidine, ketamine, morphine, hydromorphone, rocuronium, cisatracurium
- **Vasopressors & Inotropes** — norepinephrine, epinephrine, phenylephrine, vasopressin, dopamine, dobutamine, milrinone, isoproterenol
- **Antihypertensives & Vasodilators** — nicardipine, clevidipine, labetalol, esmolol, nitroglycerin, nitroprusside, hydralazine
- **Antiarrhythmics & Other** — amiodarone, lidocaine, diltiazem, heparin, insulin, octreotide, furosemide

Doses display in their correct clinical units (`mcg/kg/min`, `mg/kg/hr`, `mg/hr`, `units/hr`, etc.) with the patient-specific calculated range.

### Calculators tab
- Body metrics: BMI, BSA (Mosteller), IBW (Devine), Adjusted Body Weight
- Renal: Creatinine Clearance (Cockcroft-Gault)
- Hemodynamics: MAP, pulse pressure
- Electrolytes & acid-base: anion gap, albumin-corrected AG, corrected calcium, serum osmolality
- Oxygenation: P/F ratio
- Fluids & nutrition: maintenance IVF (4-2-1), caloric need, protein target

### Scores tab
- Glasgow Coma Scale
- Shock Index
- Lung-protective tidal volume (6 and 8 mL/kg IBW)

## Usage

Open `index.html` in any browser. No server required.

To host on GitHub Pages: push to `main`, then enable Pages (Settings → Pages → Source: `main` / root).

## Disclaimer

For clinical reference only. Always verify doses against institutional protocols and current formularies before administration.
