# Najm ICUCalc

A single-file, weight-based dosing calculator for common ICU drips (sedation, inotropes, antihypertensives).

## Usage

Open `index.html` in any modern browser. Enter patient weight (or tap a quick-select button) and each card fills in the dose range.

## Drug ranges (per kg/min unless noted)

| Category         | Drug             | Range                |
|------------------|------------------|----------------------|
| Sedation         | Fentanyl         | 1 – 5 mcg/kg/min     |
|                  | Propofol         | 5 – 50 mcg/kg/min    |
|                  | Midazolam        | 0.02 – 0.1 mcg/kg/min |
|                  | Dexmedetomidine  | 0.2 – 0.7 mcg/kg/min |
| Inotropes        | Norepinephrine   | 0.01 – 1 mcg/kg/min  |
|                  | Epinephrine      | 0.01 – 1 mcg/kg/min  |
|                  | Dopamine         | 2 – 20 mcg/kg/min    |
|                  | Dobutamine       | 2 – 20 mcg/kg/min    |
| Antihypertensives | Esmolol         | 50 – 300 mcg/kg/min  |
|                  | Nicardipine      | 5 – 15 mg/hr (fixed) |
|                  | Labetalol        | 2 – 8 mg/min (fixed) |

## Disclaimer

For clinical reference only. Always verify against your local ICU protocols and pharmacy before administering.
