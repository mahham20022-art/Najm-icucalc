import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RenalScreen extends StatelessWidget {
  const RenalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final c = st.patient.crCl;
    Verdict cLevel = Verdict.info;
    String cMsg = 'Set age, weight, sex, creatinine in the patient bar.';
    if (c != null) {
      if (c < 15) { cLevel = Verdict.bad; cMsg = 'Kidney failure (CrCl < 15) — renal-dose all meds.'; }
      else if (c < 30) { cLevel = Verdict.bad; cMsg = 'Severe ↓ (15–29) — major dose adjustment needed.'; }
      else if (c < 60) { cLevel = Verdict.warn; cMsg = 'Moderate ↓ (30–59) — dose-adjust many drugs.'; }
      else { cLevel = Verdict.ok; cMsg = 'Adequate clearance (≥ 60).'; }
    }

    final vol = st.input('uo_vol'), hr = st.input('uo_hr');
    final w = st.patient.weight;
    double? uoRate;
    Verdict uoLevel = Verdict.info;
    String uoMsg = 'Enter volume + hours.';
    if (vol != null && hr != null && hr > 0 && w != null) {
      uoRate = vol / hr / w;
      if (uoRate < 0.3) { uoLevel = Verdict.bad; uoMsg = 'Anuria/severe oliguria — escalate.'; }
      else if (uoRate < 0.5) { uoLevel = Verdict.warn; uoMsg = 'Oliguria — assess perfusion, obstruction.'; }
      else { uoLevel = Verdict.ok; uoMsg = 'Adequate urine output.'; }
    }

    // Sepsis bolus
    double? sepVol;
    int? sepQuarter;
    if (w != null) {
      sepVol = w * 30;
      sepQuarter = (sepVol / 250).ceil();
    }

    // 4-2-1 maintenance
    double? mn;
    if (w != null) {
      if (w <= 10) mn = w * 4;
      else if (w <= 20) mn = 40 + (w - 10) * 2;
      else mn = 60 + (w - 20);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        InfoCard(
          title: 'Creatinine Clearance (Cockcroft–Gault)',
          subtitle: 'CrCl = (140 − age) × W / (72 × Cr); × 0.85 (F).',
          children: [
            ResultRow('CrCl', c == null ? '—' : '${fmt(c, d: 0)} mL/min', level: cLevel, topDivider: false),
            VerdictBox(level: cLevel, child: Text(cMsg)),
          ],
        ),
        InfoCard(
          title: 'Urine Output',
          subtitle: 'Per kg/hr — oliguria < 0.5 mL/kg/hr.',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'uo_vol', label: 'Total UO', unit: 'mL'),
              NumField(stateKey: 'uo_hr', label: 'Over', unit: 'hr'),
            ]),
            ResultRow('Rate', uoRate == null ? '—' : '${fmt(uoRate, d: 2)} mL/kg/hr', level: uoLevel, topDivider: false),
            VerdictBox(level: uoLevel, child: Text(uoMsg)),
          ],
        ),
        InfoCard(
          title: 'Sepsis Fluid Bolus',
          subtitle: 'Surviving Sepsis: 30 mL/kg crystalloid within 3 hr.',
          children: [
            ResultRow('Target volume', sepVol == null ? '—' : '${fmt(sepVol, d: 0)} mL', topDivider: false),
            ResultRow('¼ bolus (250 mL increments)', sepQuarter == null ? '—' : '$sepQuarter × 250 mL boluses'),
            const VerdictBox(level: Verdict.info, child: Text('Reassess after each bolus — avoid over-resuscitation.')),
          ],
        ),
        InfoCard(
          title: 'Maintenance Fluids (4-2-1)',
          subtitle: 'First 10 kg ×4, next 10 kg ×2, remainder ×1 mL/kg/hr.',
          children: [
            ResultRow('Maintenance rate', mn == null ? '—' : '${fmt(mn, d: 0)} mL/hr', topDivider: false),
          ],
        ),
      ],
    );
  }
}
