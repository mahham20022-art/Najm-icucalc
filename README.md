# Najm ICUCalc

A bedside personal assistant for ICU/CCU clinicians. Set the patient once, and
every module — infusions, hemodynamics, ventilator, ABG, electrolytes, renal,
scores, notes — reacts live. All data stays on the device.

## Modules

| Tab | What it does |
|-----|--------------|
| **Infusions** | 23 weight-based ICU drips (sedation, vasopressors, inotropes, antihypertensives, antiarrhythmics, insulin, heparin). Shows standard range, absolute dose for the patient, and **mL/hr** from the configured concentration. |
| **Hemodynamics** | MAP, pulse pressure, shock index, modified SI, CPP (MAP − ICP), and **norepi-equivalent vasopressor load**. |
| **Ventilator** | Predicted body weight (Devine), TV targets at 4/6/8 mL/kg, **Berlin ARDS classification** from P/F, SpO₂/FiO₂ ratio, driving pressure, static compliance. |
| **ABG** | Primary acid-base disorder, expected compensation (Winters etc.), anion gap, albumin-corrected AG, **Δ-Δ ratio interpretation**, A-a gradient with age-expected. |
| **Electrolytes** | Corrected calcium, sodium-for-glucose, calculated osmolality + **osmolar gap**, **free water deficit**, K⁺ replacement guide. |
| **Renal / Fluids** | Cockcroft–Gault CrCl with renal-dosing alert, urine output mL/kg/hr with oliguria thresholds, sepsis 30 mL/kg bolus, **4-2-1 maintenance**. |
| **Scores** | GCS, qSOFA, SOFA, CHA₂DS₂-VASc, HAS-BLED, Wells (PE), RASS — live scoring with color-coded interpretation. |
| **Notes** | Plain-text scratchpad with copy/export/clear. Saved to `localStorage`. |

## Patient bar (sticky)

Enter once, used everywhere:
- Weight · Height · Age · Sex · Creatinine
- Auto-computed: **IBW** (Devine), **BSA** (Mosteller), **CrCl** (Cockcroft–Gault)

## Privacy

Every input is stored in your browser's `localStorage` only. Nothing is sent
to any server. To wipe everything, clear site data in your browser settings
or use **Clear patient** / **Clear** in Notes.

## Running locally

```bash
python3 -m http.server 8080
# open http://localhost:8080/
```

Or open `index.html` directly in any modern browser. The app is installable
as a PWA (Add to Home Screen) and works fully offline once loaded.

## Disclaimer

Reference aid only. Verify every dose, score, and interpretation against
institutional protocols, drug labels, and the patient's clinical context.
The authors assume no liability for clinical decisions made with this tool.
