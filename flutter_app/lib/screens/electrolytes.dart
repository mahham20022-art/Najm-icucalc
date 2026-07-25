import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ElectrolytesScreen extends StatelessWidget {
  const ElectrolytesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();

    // Corrected calcium
    final ca = st.input('ca_ca'), calb = st.input('ca_alb');
    double? caCorr;
    Verdict caLevel = Verdict.info;
    String caMsg = 'Reference 8.5 – 10.5 mg/dL.';
    if (ca != null && calb != null) {
      caCorr = ca + 0.8 * (4 - calb);
      if (caCorr < 8.5) { caLevel = Verdict.warn; caMsg = 'Hypocalcemia (corrected).'; }
      else if (caCorr > 10.5) { caLevel = Verdict.warn; caMsg = 'Hypercalcemia (corrected).'; }
      else { caLevel = Verdict.ok; caMsg = 'Normal corrected Ca.'; }
    }

    // Corrected sodium
    final naVal = st.input('na_na'), glu = st.input('na_glu');
    final naCorr = (naVal != null && glu != null) ? naVal + 1.6 * (glu - 100) / 100 : null;

    // Osmolality
    final oNa = st.input('os_na'), oG = st.input('os_glu'), oB = st.input('os_bun');
    final oE = st.input('os_etoh'), oM = st.input('os_meas');
    double? osCalc, osGap;
    Verdict osLevel = Verdict.info;
    String osMsg = 'Enter Na, Glucose, BUN.';
    if (oNa != null && oG != null && oB != null) {
      osCalc = 2 * oNa + oG / 18 + oB / 2.8 + (oE != null ? oE / 3.7 : 0);
      if (oM != null) {
        osGap = oM - osCalc;
        if (osGap > 10) { osLevel = Verdict.bad; osMsg = 'Osmolar gap > 10 → consider toxic alcohols.'; }
        else { osLevel = Verdict.ok; osMsg = 'Normal osmolar gap.'; }
      } else osMsg = 'Add measured osm for gap.';
    }

    // Free water deficit
    final fNa = st.input('fwd_na'), fTgt = st.input('fwd_tgt') ?? 140;
    double? fwd;
    if (fNa != null && st.patient.weight != null && st.patient.sex.isNotEmpty) {
      final tbwFactor = st.patient.sex == 'M' ? 0.6 : 0.5;
      final tbw = tbwFactor * st.patient.weight!;
      final v = tbw * (fNa / fTgt - 1);
      if (v > 0) fwd = v;
    }

    // K replacement
    final k = st.input('k_k');
    String kMsg = '—';
    if (k != null) {
      if (k >= 4.0) kMsg = 'No replacement needed';
      else if (k >= 3.5) kMsg = '10 mEq KCl PO/IV';
      else if (k >= 3.0) kMsg = '20–40 mEq KCl IV (split doses)';
      else if (k >= 2.5) kMsg = '40–60 mEq KCl IV + check Mg';
      else kMsg = '60–80 mEq + central line + telemetry';
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        InfoCard(
          title: 'Corrected Calcium',
          subtitle: 'Ca corr = Ca + 0.8 × (4 − albumin)',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'ca_ca', label: 'Ca measured', unit: 'mg/dL'),
              NumField(stateKey: 'ca_alb', label: 'Albumin', unit: 'g/dL'),
            ]),
            ResultRow('Corrected Ca', caCorr == null ? '—' : '${fmt(caCorr, d: 2)} mg/dL', level: caLevel, topDivider: false),
            VerdictBox(level: caLevel, child: Text(caMsg)),
          ],
        ),
        InfoCard(
          title: 'Corrected Sodium (hyperglycemia)',
          subtitle: 'Na corr = Na + 1.6 × (glucose − 100) / 100',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'na_na', label: 'Na measured', unit: 'mEq/L'),
              NumField(stateKey: 'na_glu', label: 'Glucose', unit: 'mg/dL'),
            ]),
            ResultRow('Corrected Na', naCorr == null ? '—' : '${fmt(naCorr, d: 1)} mEq/L', topDivider: false),
          ],
        ),
        InfoCard(
          title: 'Serum Osmolality',
          subtitle: '2·Na + Glucose/18 + BUN/2.8 (+ EtOH/3.7)',
          children: [
            const FieldGrid(columns: 3, children: [
              NumField(stateKey: 'os_na', label: 'Na'),
              NumField(stateKey: 'os_glu', label: 'Glucose'),
              NumField(stateKey: 'os_bun', label: 'BUN'),
              NumField(stateKey: 'os_etoh', label: 'EtOH'),
              NumField(stateKey: 'os_meas', label: 'Measured'),
            ]),
            ResultRow('Calculated osm', osCalc == null ? '—' : '${fmt(osCalc, d: 0)} mOsm/kg', topDivider: false),
            ResultRow('Osmolar gap', osGap == null ? '—' : fmt(osGap, d: 1), level: osLevel),
            VerdictBox(level: osLevel, child: Text(osMsg)),
          ],
        ),
        InfoCard(
          title: 'Free Water Deficit (hypernatremia)',
          subtitle: 'FWD = TBW × (Na/target − 1). TBW = 0.6·W (M) / 0.5·W (F).',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'fwd_na', label: 'Current Na', unit: 'mEq/L'),
              NumField(stateKey: 'fwd_tgt', label: 'Target Na', hint: '140', unit: 'mEq/L'),
            ]),
            ResultRow('Free water deficit', fwd == null ? '—' : '${fmt(fwd, d: 2)} L', topDivider: false),
            const VerdictBox(level: Verdict.info, child: Text('Correct ≤ 10 mEq/L per 24 hr to avoid cerebral edema.')),
          ],
        ),
        InfoCard(
          title: 'Potassium Replacement',
          subtitle: 'Empiric IV KCl guide for low serum K⁺.',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'k_k', label: 'Serum K⁺', unit: 'mEq/L'),
            ]),
            ResultRow('Suggested replacement', kMsg, topDivider: false),
            const VerdictBox(level: Verdict.info, child: Text('Max peripheral 10 mEq/hr; central 20 mEq/hr with monitoring.')),
          ],
        ),
      ],
    );
  }
}
