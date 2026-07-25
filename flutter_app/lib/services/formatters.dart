/// Number formatting shared across screens.
String fmt(num? n, {int d = 1}) {
  if (n == null || n.isNaN || n.isInfinite) return '—';
  final abs = n.abs();
  if (abs >= 100) return n.toStringAsFixed(0);
  if (abs >= 10)  return n.toStringAsFixed(d);
  return n.toStringAsFixed(d < 2 ? 2 : d);
}

/// Accept either a fraction (0.4) or a percent (40) and return the fraction.
double? fio2Fraction(double? x) {
  if (x == null) return null;
  return x > 1 ? x / 100 : x;
}
