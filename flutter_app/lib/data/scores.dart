import '../theme.dart';

class ScoreItem {
  final String label;
  final List<ScoreOption> options;
  const ScoreItem(this.label, this.options);
}

class ScoreOption {
  final String label;
  final num value;
  const ScoreOption(this.label, this.value);
}

class ScoreDef {
  final String key;
  final String name;
  final String subtitle;
  final List<ScoreItem> items;
  final (String, Verdict) Function(num total) interpret;
  const ScoreDef({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.items,
    required this.interpret,
  });
}

final scores = <ScoreDef>[
  ScoreDef(
    key: 'gcs',
    name: 'GCS',
    subtitle: 'Glasgow Coma Scale (3–15)',
    items: const [
      ScoreItem('Eye', [
        ScoreOption('Spontaneous (4)', 4), ScoreOption('To speech (3)', 3),
        ScoreOption('To pain (2)', 2), ScoreOption('None (1)', 1),
      ]),
      ScoreItem('Verbal', [
        ScoreOption('Oriented (5)', 5), ScoreOption('Confused (4)', 4),
        ScoreOption('Inappropriate (3)', 3), ScoreOption('Incomprehensible (2)', 2),
        ScoreOption('None (1)', 1),
      ]),
      ScoreItem('Motor', [
        ScoreOption('Obeys (6)', 6), ScoreOption('Localizes (5)', 5),
        ScoreOption('Withdraws (4)', 4), ScoreOption('Abnormal flexion (3)', 3),
        ScoreOption('Extension (2)', 2), ScoreOption('None (1)', 1),
      ]),
    ],
    interpret: (t) {
      if (t <= 8) return ('Severe — consider intubation.', Verdict.bad);
      if (t <= 12) return ('Moderate.', Verdict.warn);
      return ('Mild / normal.', Verdict.ok);
    },
  ),
  ScoreDef(
    key: 'qsofa',
    name: 'qSOFA',
    subtitle: '≥ 2 → higher sepsis mortality risk',
    items: const [
      ScoreItem('RR ≥ 22', [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Altered mental status', [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('SBP ≤ 100', [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
    ],
    interpret: (t) => t >= 2
        ? ('High sepsis mortality risk.', Verdict.bad)
        : ('Low risk by qSOFA.', Verdict.ok),
  ),
  ScoreDef(
    key: 'sofa',
    name: 'SOFA',
    subtitle: 'Organ dysfunction (0–24)',
    items: const [
      ScoreItem('PaO₂/FiO₂', [
        ScoreOption('≥ 400 (0)', 0), ScoreOption('< 400 (1)', 1),
        ScoreOption('< 300 (2)', 2), ScoreOption('< 200 vent (3)', 3),
        ScoreOption('< 100 vent (4)', 4),
      ]),
      ScoreItem('Platelets', [
        ScoreOption('≥ 150 (0)', 0), ScoreOption('< 150 (1)', 1),
        ScoreOption('< 100 (2)', 2), ScoreOption('< 50 (3)', 3),
        ScoreOption('< 20 (4)', 4),
      ]),
      ScoreItem('Bilirubin', [
        ScoreOption('< 1.2 (0)', 0), ScoreOption('1.2–1.9 (1)', 1),
        ScoreOption('2–5.9 (2)', 2), ScoreOption('6–11.9 (3)', 3),
        ScoreOption('≥ 12 (4)', 4),
      ]),
      ScoreItem('Cardiovascular', [
        ScoreOption('MAP ≥ 70 (0)', 0), ScoreOption('MAP < 70 (1)', 1),
        ScoreOption('Dopa ≤ 5 / dobut (2)', 2),
        ScoreOption('Dopa > 5 / NE ≤ 0.1 (3)', 3),
        ScoreOption('Dopa > 15 / NE > 0.1 (4)', 4),
      ]),
      ScoreItem('GCS', [
        ScoreOption('15 (0)', 0), ScoreOption('13–14 (1)', 1),
        ScoreOption('10–12 (2)', 2), ScoreOption('6–9 (3)', 3),
        ScoreOption('< 6 (4)', 4),
      ]),
      ScoreItem('Creatinine / UO', [
        ScoreOption('< 1.2 (0)', 0), ScoreOption('1.2–1.9 (1)', 1),
        ScoreOption('2–3.4 (2)', 2), ScoreOption('3.5–4.9 or < 500 mL (3)', 3),
        ScoreOption('≥ 5 or < 200 mL (4)', 4),
      ]),
    ],
    interpret: (t) {
      if (t >= 11) return ('Very high mortality.', Verdict.bad);
      if (t >= 7) return ('High mortality.', Verdict.bad);
      if (t >= 4) return ('Moderate.', Verdict.warn);
      return ('Low organ dysfunction.', Verdict.ok);
    },
  ),
  ScoreDef(
    key: 'chads',
    name: 'CHA₂DS₂-VASc',
    subtitle: 'Stroke risk in AF',
    items: const [
      ScoreItem('CHF',                      [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Hypertension',             [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Age ≥ 75',                 [ScoreOption('No', 0), ScoreOption('Yes', 2)]),
      ScoreItem('Diabetes',                 [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Stroke / TIA / thrombo',   [ScoreOption('No', 0), ScoreOption('Yes', 2)]),
      ScoreItem('Vascular disease',         [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Age 65–74',                [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Female',                   [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
    ],
    interpret: (t) {
      if (t >= 2) return ('Anticoagulation recommended.', Verdict.bad);
      if (t == 1) return ('Consider anticoagulation.', Verdict.warn);
      return ('No anticoagulation needed.', Verdict.ok);
    },
  ),
  ScoreDef(
    key: 'hasbled',
    name: 'HAS-BLED',
    subtitle: 'Bleeding risk on anticoagulation',
    items: const [
      ScoreItem('Hypertension (uncontrolled)', [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Abnormal renal function',     [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Abnormal liver function',     [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Stroke history',              [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Bleeding history',            [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Labile INR',                  [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Elderly > 65',                [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Drugs (antiplatelet/NSAID)',  [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Alcohol ≥ 8/wk',              [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
    ],
    interpret: (t) => t >= 3
        ? ('High bleeding risk — caution / closer follow-up.', Verdict.bad)
        : ('Moderate / low bleeding risk.', Verdict.ok),
  ),
  ScoreDef(
    key: 'wells',
    name: 'Wells (PE)',
    subtitle: 'Pretest probability of PE',
    items: const [
      ScoreItem('Signs of DVT',                    [ScoreOption('No', 0), ScoreOption('Yes', 3)]),
      ScoreItem('PE more likely than alt dx',      [ScoreOption('No', 0), ScoreOption('Yes', 3)]),
      ScoreItem('HR > 100',                        [ScoreOption('No', 0), ScoreOption('Yes', 1.5)]),
      ScoreItem('Immobilization / surgery ≤ 4 wk', [ScoreOption('No', 0), ScoreOption('Yes', 1.5)]),
      ScoreItem('Prior DVT/PE',                    [ScoreOption('No', 0), ScoreOption('Yes', 1.5)]),
      ScoreItem('Hemoptysis',                      [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
      ScoreItem('Active malignancy',               [ScoreOption('No', 0), ScoreOption('Yes', 1)]),
    ],
    interpret: (t) {
      if (t > 6) return ('High probability — image directly.', Verdict.bad);
      if (t >= 2) return ('Moderate — D-dimer or CT.', Verdict.warn);
      return ('Low — D-dimer to exclude.', Verdict.ok);
    },
  ),
  ScoreDef(
    key: 'rass',
    name: 'RASS',
    subtitle: 'Richmond Agitation–Sedation Scale',
    items: const [
      ScoreItem('Level', [
        ScoreOption('+4 Combative', 4),
        ScoreOption('+3 Very agitated', 3),
        ScoreOption('+2 Agitated', 2),
        ScoreOption('+1 Restless', 1),
        ScoreOption(' 0 Alert & calm', 0),
        ScoreOption('−1 Drowsy', -1),
        ScoreOption('−2 Light sedation', -2),
        ScoreOption('−3 Moderate sedation', -3),
        ScoreOption('−4 Deep sedation', -4),
        ScoreOption('−5 Unarousable', -5),
      ]),
    ],
    interpret: (t) {
      if (t >= 2) return ('Agitated — assess pain/delirium.', Verdict.warn);
      if (t <= -3) return ('Deep sedation — daily SAT if possible.', Verdict.warn);
      return ('Acceptable depth.', Verdict.ok);
    },
  ),
];
