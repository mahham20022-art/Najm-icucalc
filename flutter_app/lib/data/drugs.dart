import '../models/drug.dart';

const drugs = <Drug>[
  // Sedation / analgesia
  Drug(id: 'fentanyl',  name: 'Fentanyl',        category: 'Sedation',        min: 0.5,   max: 3,     unit: 'mcg/kg/hr',  concLabel: '10 mcg/mL',   concValue: 10,    concUnit: 'mcg/mL'),
  Drug(id: 'propofol',  name: 'Propofol',        category: 'Sedation',        min: 5,     max: 50,    unit: 'mcg/kg/min', concLabel: '10 mg/mL',    concValue: 10000, concUnit: 'mcg/mL'),
  Drug(id: 'midaz',     name: 'Midazolam',       category: 'Sedation',        min: 0.02,  max: 0.1,   unit: 'mg/kg/hr',   concLabel: '1 mg/mL',     concValue: 1,     concUnit: 'mg/mL'),
  Drug(id: 'dex',       name: 'Dexmedetomidine', category: 'Sedation',        min: 0.2,   max: 1.4,   unit: 'mcg/kg/hr',  concLabel: '4 mcg/mL',    concValue: 4,     concUnit: 'mcg/mL'),
  Drug(id: 'ketamine',  name: 'Ketamine',        category: 'Sedation',        min: 0.1,   max: 2,     unit: 'mg/kg/hr',   concLabel: '1 mg/mL',     concValue: 1,     concUnit: 'mg/mL'),
  Drug(id: 'morphine',  name: 'Morphine',        category: 'Sedation',        min: 0.01,  max: 0.05,  unit: 'mg/kg/hr',   concLabel: '1 mg/mL',     concValue: 1,     concUnit: 'mg/mL'),

  // Vasopressors
  Drug(id: 'norepi',    name: 'Norepinephrine',  category: 'Vasopressor',     min: 0.01,  max: 1,     unit: 'mcg/kg/min', concLabel: '16 mcg/mL',   concValue: 16,    concUnit: 'mcg/mL'),
  Drug(id: 'epi',       name: 'Epinephrine',     category: 'Vasopressor',     min: 0.01,  max: 1,     unit: 'mcg/kg/min', concLabel: '16 mcg/mL',   concValue: 16,    concUnit: 'mcg/mL'),
  Drug(id: 'phenyl',    name: 'Phenylephrine',   category: 'Vasopressor',     min: 0.1,   max: 5,     unit: 'mcg/kg/min', concLabel: '100 mcg/mL',  concValue: 100,   concUnit: 'mcg/mL'),
  Drug(id: 'vaso',      name: 'Vasopressin',     category: 'Vasopressor',     min: 0.01,  max: 0.04,  unit: 'U/min',      concLabel: '0.4 U/mL',    concValue: 0.4,   concUnit: 'U/mL',    weightless: true),

  // Inotropes
  Drug(id: 'dop',       name: 'Dopamine',        category: 'Inotrope',        min: 2,     max: 20,    unit: 'mcg/kg/min', concLabel: '1600 mcg/mL', concValue: 1600,  concUnit: 'mcg/mL'),
  Drug(id: 'dob',       name: 'Dobutamine',      category: 'Inotrope',        min: 2,     max: 20,    unit: 'mcg/kg/min', concLabel: '1000 mcg/mL', concValue: 1000,  concUnit: 'mcg/mL'),
  Drug(id: 'milri',     name: 'Milrinone',       category: 'Inotrope',        min: 0.25,  max: 0.75,  unit: 'mcg/kg/min', concLabel: '200 mcg/mL',  concValue: 200,   concUnit: 'mcg/mL'),

  // Antihypertensives
  Drug(id: 'esmo',      name: 'Esmolol',         category: 'Antihypertensive',min: 50,    max: 300,   unit: 'mcg/kg/min', concLabel: '10 mg/mL',    concValue: 10000, concUnit: 'mcg/mL'),
  Drug(id: 'nicar',     name: 'Nicardipine',     category: 'Antihypertensive',min: 5,     max: 15,    unit: 'mg/hr',      concLabel: '0.1 mg/mL',   concValue: 0.1,   concUnit: 'mg/mL',   weightless: true),
  Drug(id: 'labet',     name: 'Labetalol',       category: 'Antihypertensive',min: 2,     max: 8,     unit: 'mg/min',     concLabel: '1 mg/mL',     concValue: 1,     concUnit: 'mg/mL',   weightless: true),
  Drug(id: 'ntg',       name: 'Nitroglycerin',   category: 'Antihypertensive',min: 5,     max: 200,   unit: 'mcg/min',    concLabel: '100 mcg/mL',  concValue: 100,   concUnit: 'mcg/mL',  weightless: true),
  Drug(id: 'snp',       name: 'Nitroprusside',   category: 'Antihypertensive',min: 0.25,  max: 10,    unit: 'mcg/kg/min', concLabel: '200 mcg/mL',  concValue: 200,   concUnit: 'mcg/mL'),

  // Antiarrhythmics
  Drug(id: 'amio',      name: 'Amiodarone',      category: 'Antiarrhythmic',  min: 0.5,   max: 1,     unit: 'mg/min',     concLabel: '1.8 mg/mL',   concValue: 1.8,   concUnit: 'mg/mL',   weightless: true),
  Drug(id: 'lido',      name: 'Lidocaine',       category: 'Antiarrhythmic',  min: 1,     max: 4,     unit: 'mg/min',     concLabel: '8 mg/mL',     concValue: 8,     concUnit: 'mg/mL',   weightless: true),
  Drug(id: 'diltiazem', name: 'Diltiazem',       category: 'Antiarrhythmic',  min: 5,     max: 15,    unit: 'mg/hr',      concLabel: '1 mg/mL',     concValue: 1,     concUnit: 'mg/mL',   weightless: true),

  // Endocrine / Anticoag
  Drug(id: 'insulin',   name: 'Insulin (regular)', category: 'Endocrine',    min: 0.05,  max: 0.1,   unit: 'U/kg/hr',    concLabel: '1 U/mL',      concValue: 1,     concUnit: 'U/mL'),
  Drug(id: 'heparin',   name: 'Heparin',         category: 'Anticoagulant',   min: 12,    max: 25,    unit: 'U/kg/hr',    concLabel: '100 U/mL',    concValue: 100,   concUnit: 'U/mL'),
];

List<String> get drugCategories {
  final set = <String>{'all'};
  for (final d in drugs) {
    set.add(d.category);
  }
  return set.toList();
}
