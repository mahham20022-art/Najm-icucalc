/// Common ICU antibiotics with CrCl-based dose adjustments.
class Antibiotic {
  final String id;
  final String name;
  final String category;
  final String standardDose;
  /// list of (crclMin, crclMax, doseLabel) — first range where crcl fits wins.
  /// `crclMax = double.infinity` means no upper bound.
  final List<(double, double, String)> byCrCl;
  final String indications;
  final String? notes;

  const Antibiotic({
    required this.id,
    required this.name,
    required this.category,
    required this.standardDose,
    required this.byCrCl,
    required this.indications,
    this.notes,
  });

  /// Returns the dose label appropriate for a given CrCl, plus a flag for
  /// whether the adjustment actually applies (false = generic fallback).
  (String, bool) doseFor(double? crcl) {
    if (crcl == null) return (standardDose, false);
    for (final (lo, hi, dose) in byCrCl) {
      if (crcl >= lo && crcl < hi) return (dose, true);
    }
    return (standardDose, false);
  }
}

const inf = double.infinity;

const antibiotics = <Antibiotic>[
  // β-lactams
  Antibiotic(
    id: 'pipTazo', name: 'Piperacillin-tazobactam', category: 'β-lactam',
    standardDose: '4.5 g IV q6h (extended infusion 4 h)',
    byCrCl: [(40, inf, '4.5 g q6h'), (20, 40, '3.375 g q6h'), (0, 20, '2.25 g q6h')],
    indications: 'HAP/VAP, complicated intra-abdominal, febrile neutropenia',
  ),
  Antibiotic(
    id: 'meropenem', name: 'Meropenem', category: 'Carbapenem',
    standardDose: '1 g IV q8h (2 g q8h for CNS)',
    byCrCl: [(51, inf, '1 g q8h'), (26, 51, '1 g q12h'), (10, 26, '500 mg q12h'), (0, 10, '500 mg q24h')],
    indications: 'Severe sepsis, ESBL, nosocomial pneumonia',
  ),
  Antibiotic(
    id: 'imipenem', name: 'Imipenem-cilastatin', category: 'Carbapenem',
    standardDose: '500 mg IV q6h',
    byCrCl: [(71, inf, '500 mg q6h'), (41, 71, '500 mg q8h'), (21, 41, '500 mg q12h'), (0, 21, '500 mg q24h')],
    indications: 'Similar to meropenem — avoid in seizure risk',
  ),
  Antibiotic(
    id: 'cefepime', name: 'Cefepime', category: 'Cephalosporin',
    standardDose: '2 g IV q8h',
    byCrCl: [(60, inf, '2 g q8h'), (30, 60, '2 g q12h'), (11, 30, '2 g q24h'), (0, 11, '1 g q24h')],
    indications: 'HAP, pyelonephritis, febrile neutropenia, MDR gram-negatives',
  ),
  Antibiotic(
    id: 'ceftriaxone', name: 'Ceftriaxone', category: 'Cephalosporin',
    standardDose: '2 g IV q24h (q12h for meningitis)',
    byCrCl: [(0, inf, 'No renal adjustment')],
    indications: 'CAP, meningitis, pyelonephritis',
  ),
  Antibiotic(
    id: 'ceftazAvi', name: 'Ceftazidime-avibactam', category: 'Cephalosporin',
    standardDose: '2.5 g IV q8h',
    byCrCl: [(51, inf, '2.5 g q8h'), (31, 51, '1.25 g q8h'), (16, 31, '0.94 g q12h'), (6, 16, '0.94 g q24h'), (0, 6, '0.94 g q48h')],
    indications: 'Carbapenem-resistant Enterobacterales (KPC), Pseudomonas',
  ),
  Antibiotic(
    id: 'ampSulbactam', name: 'Ampicillin-sulbactam', category: 'β-lactam',
    standardDose: '3 g IV q6h',
    byCrCl: [(30, inf, '3 g q6h'), (15, 30, '3 g q12h'), (0, 15, '3 g q24h')],
    indications: 'Aspiration pneumonia, intra-abdominal, skin/soft tissue',
  ),
  Antibiotic(
    id: 'aztreonam', name: 'Aztreonam', category: 'Monobactam',
    standardDose: '2 g IV q8h',
    byCrCl: [(30, inf, '2 g q8h'), (10, 30, '1 g q8h'), (0, 10, '500 mg q8h')],
    indications: 'Gram-negative coverage in β-lactam allergy',
  ),

  // Anti-MRSA
  Antibiotic(
    id: 'vanco', name: 'Vancomycin', category: 'Anti-MRSA glycopeptide',
    standardDose: '15–20 mg/kg IV q8–12h (load 25–30 mg/kg for critical)',
    byCrCl: [(80, inf, '15–20 mg/kg q8–12h (AUC 400–600)'), (50, 80, '15–20 mg/kg q12h'), (20, 50, '15 mg/kg q24h'), (0, 20, 'By levels only')],
    indications: 'MRSA, empiric coverage in septic shock',
    notes: 'Follow trough (15–20) or AUC24 (400–600).',
  ),
  Antibiotic(
    id: 'linezolid', name: 'Linezolid', category: 'Oxazolidinone',
    standardDose: '600 mg IV / PO q12h',
    byCrCl: [(0, inf, 'No renal adjustment')],
    indications: 'MRSA pneumonia, VRE',
    notes: 'Watch thrombocytopenia, serotonin syndrome.',
  ),
  Antibiotic(
    id: 'daptomycin', name: 'Daptomycin', category: 'Lipopeptide',
    standardDose: '6–10 mg/kg IV q24h',
    byCrCl: [(30, inf, '6–10 mg/kg q24h'), (0, 30, '6–10 mg/kg q48h')],
    indications: 'MRSA bacteremia, right-sided endocarditis',
    notes: 'Inactivated by surfactant — never use for pneumonia. Monitor CPK.',
  ),

  // Fluoroquinolones
  Antibiotic(
    id: 'levo', name: 'Levofloxacin', category: 'Fluoroquinolone',
    standardDose: '750 mg IV q24h',
    byCrCl: [(50, inf, '750 mg q24h'), (20, 50, '750 mg then 750 mg q48h'), (0, 20, '750 mg then 500 mg q48h')],
    indications: 'CAP, complicated UTI, atypicals',
  ),
  Antibiotic(
    id: 'cipro', name: 'Ciprofloxacin', category: 'Fluoroquinolone',
    standardDose: '400 mg IV q8–12h',
    byCrCl: [(50, inf, '400 mg q8–12h'), (30, 50, '400 mg q12h'), (0, 30, '400 mg q24h')],
    indications: 'Pseudomonas, complicated intra-abdominal (with metro)',
  ),

  // Others
  Antibiotic(
    id: 'metro', name: 'Metronidazole', category: 'Nitroimidazole',
    standardDose: '500 mg IV q8h',
    byCrCl: [(0, inf, 'No renal adjustment')],
    indications: 'Anaerobes, C. difficile (oral)',
  ),
  Antibiotic(
    id: 'azithro', name: 'Azithromycin', category: 'Macrolide',
    standardDose: '500 mg IV q24h',
    byCrCl: [(0, inf, 'No renal adjustment')],
    indications: 'Atypical CAP coverage, Legionella',
  ),

  // Aminoglycosides
  Antibiotic(
    id: 'amikacin', name: 'Amikacin', category: 'Aminoglycoside',
    standardDose: '15–20 mg/kg IV q24h (extended interval)',
    byCrCl: [(60, inf, '15–20 mg/kg q24h'), (40, 60, '15 mg/kg q36h'), (20, 40, '15 mg/kg q48h'), (0, 20, 'By levels only')],
    indications: 'MDR gram-negative synergy',
    notes: 'Monitor trough (<4) + peak (56–64).',
  ),
  Antibiotic(
    id: 'gent', name: 'Gentamicin', category: 'Aminoglycoside',
    standardDose: '5–7 mg/kg IV q24h',
    byCrCl: [(60, inf, '5–7 mg/kg q24h'), (40, 60, '5 mg/kg q36h'), (20, 40, '5 mg/kg q48h'), (0, 20, 'By levels only')],
    indications: 'Enterococcal synergy, gram-negative augmentation',
  ),
  Antibiotic(
    id: 'colistin', name: 'Colistin (CBA)', category: 'Polymyxin',
    standardDose: 'Load 9 MIU then 4.5 MIU q12h (~2.5 mg/kg q12h)',
    byCrCl: [(80, inf, '4.5 MIU q12h'), (50, 80, '3.5 MIU q12h'), (30, 50, '2.5 MIU q12h'), (0, 30, '1.5–2 MIU q12h')],
    indications: 'MDR/XDR Acinetobacter, Pseudomonas',
    notes: 'Nephrotoxic — monitor creatinine daily.',
  ),

  // Antifungals
  Antibiotic(
    id: 'fluconazole', name: 'Fluconazole', category: 'Antifungal (azole)',
    standardDose: 'Load 800 mg, then 400 mg IV q24h',
    byCrCl: [(50, inf, '400–800 mg q24h'), (0, 50, '50% of dose q24h')],
    indications: 'Candidiasis (non-krusei/non-glabrata)',
  ),
  Antibiotic(
    id: 'vorico', name: 'Voriconazole', category: 'Antifungal (azole)',
    standardDose: 'Load 6 mg/kg IV q12h × 2, then 4 mg/kg IV q12h',
    byCrCl: [(50, inf, '4 mg/kg q12h'), (0, 50, 'PO if possible (IV vehicle accumulates)')],
    indications: 'Aspergillosis',
    notes: 'Many drug interactions; trough 1–5.5 mg/L.',
  ),
  Antibiotic(
    id: 'caspo', name: 'Caspofungin', category: 'Antifungal (echinocandin)',
    standardDose: 'Load 70 mg, then 50 mg IV q24h',
    byCrCl: [(0, inf, 'No renal adjustment')],
    indications: 'Invasive candidiasis, empiric for febrile neutropenia',
  ),
  Antibiotic(
    id: 'mica', name: 'Micafungin', category: 'Antifungal (echinocandin)',
    standardDose: '100 mg IV q24h (150 mg for esophageal)',
    byCrCl: [(0, inf, 'No renal adjustment')],
    indications: 'Candidemia, invasive candidiasis',
  ),

  // Antivirals
  Antibiotic(
    id: 'acyclovir', name: 'Acyclovir', category: 'Antiviral',
    standardDose: '10 mg/kg IV q8h',
    byCrCl: [(50, inf, '10 mg/kg q8h'), (25, 50, '10 mg/kg q12h'), (10, 25, '10 mg/kg q24h'), (0, 10, '5 mg/kg q24h')],
    indications: 'HSV encephalitis, VZV pneumonitis',
  ),
  Antibiotic(
    id: 'oseltamivir', name: 'Oseltamivir', category: 'Antiviral',
    standardDose: '75 mg PO q12h',
    byCrCl: [(60, inf, '75 mg q12h'), (30, 60, '30 mg q12h'), (10, 30, '30 mg q24h'), (0, 10, '30 mg once (or per HD)')],
    indications: 'Influenza A/B',
  ),
];

List<String> get antibioticClasses {
  final set = <String>{'all'};
  for (final a in antibiotics) { set.add(a.category); }
  return set.toList();
}

/// Clinical references shown in the About screen.
const references = <String>[
  'Marino PL. The ICU Book, 5th ed. Wolters Kluwer, 2023.',
  'Evans L et al. Surviving Sepsis Campaign: International Guidelines 2021. Crit Care Med 2021;49(11):e1063–e1143.',
  'ARDS Definition Task Force. Acute respiratory distress syndrome: the Berlin definition. JAMA 2012;307(23):2526–33.',
  'ARDSnet. Ventilation with lower tidal volumes for ALI/ARDS. NEJM 2000;342(18):1301–08.',
  'Amato MBP et al. Driving pressure and survival in ARDS. NEJM 2015;372(8):747–55.',
  'Panchal AR et al. 2020 AHA Guidelines for CPR and ECC. Circulation 2020;142(16 Suppl 2).',
  'Gilbert DN et al. The Sanford Guide to Antimicrobial Therapy 2024.',
  'Kalil AC et al. Management of adults with HAP/VAP: 2016 IDSA/ATS guidelines. Clin Infect Dis 2016;63(5):e61–e111.',
  'KDIGO. Clinical practice guideline for acute kidney injury. Kidney Int Suppl 2012;2(1):1–138.',
  'Hindricks G et al. 2020 ESC Guidelines for AF (CHA₂DS₂-VASc, HAS-BLED). Eur Heart J 2021;42(5):373–498.',
  'Konstantinides SV et al. 2019 ESC PE Guidelines (Wells). Eur Heart J 2020;41(4):543–603.',
  'Sessler CN et al. RASS. Am J Respir Crit Care Med 2002;166(10):1338–44.',
  'Vincent JL et al. SOFA score. Intensive Care Med 1996;22(7):707–10.',
  'Cockcroft DW, Gault MH. Nephron 1976;16(1):31–41 (CrCl).',
  'Winters RW. Ann NY Acad Sci 1966;133(1):211–24 (acid-base compensation).',
  'Adrogué HJ, Madias NE. Hypernatremia. NEJM 2000;342(20):1493–99 (free water deficit).',
  'Khanna A et al. Angiotensin II for vasodilatory shock. NEJM 2017;377(5):419–30 (norepi equivalents).',
];
