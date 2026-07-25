import 'dart:convert';
import 'dart:math' as math;

class Patient {
  final double? weight;
  final double? height;
  final double? age;
  final String sex;   // "M" | "F" | ""
  final double? creatinine;

  const Patient({
    this.weight,
    this.height,
    this.age,
    this.sex = '',
    this.creatinine,
  });

  static const empty = Patient();

  Patient copyWith({
    double? weight,
    double? height,
    double? age,
    String? sex,
    double? creatinine,
    bool clearWeight = false,
    bool clearHeight = false,
    bool clearAge = false,
    bool clearCr = false,
  }) {
    return Patient(
      weight: clearWeight ? null : (weight ?? this.weight),
      height: clearHeight ? null : (height ?? this.height),
      age: clearAge ? null : (age ?? this.age),
      sex: sex ?? this.sex,
      creatinine: clearCr ? null : (creatinine ?? this.creatinine),
    );
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'height': height,
    'age': age,
    'sex': sex,
    'cr': creatinine,
  };

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
    weight: (j['weight'] as num?)?.toDouble(),
    height: (j['height'] as num?)?.toDouble(),
    age: (j['age'] as num?)?.toDouble(),
    sex: (j['sex'] as String?) ?? '',
    creatinine: (j['cr'] as num?)?.toDouble(),
  );

  String toRaw() => jsonEncode(toJson());
  factory Patient.fromRaw(String s) => Patient.fromJson(jsonDecode(s) as Map<String, dynamic>);

  /// Predicted body weight (Devine). Needs height + sex.
  double? get pbw {
    if (height == null || sex.isEmpty) return null;
    final inches = height! / 2.54;
    final over60 = inches - 60;
    final base = sex == 'M' ? 50.0 : 45.5;
    return base + 2.3 * over60;
  }

  /// BSA (Mosteller). Needs height + weight.
  double? get bsa {
    if (height == null || weight == null) return null;
    return math.sqrt((height! * weight!) / 3600);
  }

  /// Cockcroft-Gault CrCl (mL/min). Needs age + weight + sex + creatinine.
  double? get crCl {
    if (age == null || weight == null || creatinine == null || sex.isEmpty) return null;
    var v = ((140 - age!) * weight!) / (72 * creatinine!);
    if (sex == 'F') v *= 0.85;
    return v;
  }
}
