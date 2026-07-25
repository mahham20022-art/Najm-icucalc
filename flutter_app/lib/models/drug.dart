class Drug {
  final String id;
  final String name;
  final String category;
  final double min;          // per-kg or absolute if [weightless] is true
  final double max;
  final String unit;         // "mcg/kg/min" | "mg/kg/hr" | "mg/min" | "U/min" | ...
  final bool weightless;
  final String concLabel;    // e.g. "16 mcg/mL"
  final double concValue;    // amount per mL, in concUnitBase
  final String concUnit;     // "mcg/mL" | "mg/mL" | "U/mL"

  const Drug({
    required this.id,
    required this.name,
    required this.category,
    required this.min,
    required this.max,
    required this.unit,
    required this.concLabel,
    required this.concValue,
    required this.concUnit,
    this.weightless = false,
  });

  /// Ratio-based hint at how wide the therapeutic window is.
  String get riskLevel {
    final r = max / min;
    if (r > 8) return 'high';
    if (r < 3) return 'low';
    return 'mid';
  }

  /// Absolute (patient-scaled) range in the drug's raw units (per min/hr).
  (double lo, double hi, String unit)? absoluteFor(double? weightKg) {
    if (weightless) return (min, max, unit);
    if (weightKg == null) return null;
    return (min * weightKg, max * weightKg, unit.replaceAll('/kg', ''));
  }

  /// mL/hr drip rate at the configured concentration for a given dose.
  double? mlPerHour(double dosePerKgOrFixed, double? weightKg) {
    final wEff = weightless ? 1.0 : weightKg;
    if (wEff == null) return null;
    final unitL = unit.toLowerCase();
    final perKgPerHour = unitL.contains('/min') ? dosePerKgOrFixed * 60 : dosePerKgOrFixed;
    var amount = perKgPerHour * wEff;
    final inBase = unitL.startsWith('mcg') ? 'mcg' : unitL.startsWith('mg') ? 'mg' : 'U';
    final concBase = concUnit.split('/')[0];
    if (inBase == 'mcg' && concBase == 'mg') amount /= 1000;
    if (inBase == 'mg' && concBase == 'mcg') amount *= 1000;
    return amount / concValue;
  }
}
