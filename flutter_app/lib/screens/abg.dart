import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AbgScreen extends StatelessWidget {
  const AbgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final pH   = st.input('ab_ph');
    final co2  = st.input('ab_co2');
    final hco3 = st.input('ab_hco3');
    final na   = st.input('ab_na');
    final cl   = st.input('ab_cl');
    final alb  = st.input('ab_alb');
    final pao2 = st.input('ab_pao2');
    final fio2 = fio2Fraction(st.input('ab_fio2'));

    String primary = '—';
    String comp = '—';
    final summaries = <String>[];
    Verdict level = Verdict.info;

    if (pH != null && co2 != null && hco3 != null) {
      if (pH < 7.35) {
        if (co2 > 45 && hco3 >= 22) primary = 'Respiratory acidosis';
        else if (hco3 < 22 && co2 <= 45) primary = 'Metabolic acidosis';
        else if (co2 > 45 && hco3 < 22) primary = 'Mixed metabolic + respiratory acidosis';
        else primary = 'Acidemia';
      } else if (pH > 7.45) {
        if (co2 < 35 && hco3 <= 26) primary = 'Respiratory alkalosis';
        else if (hco3 > 26 && co2 >= 35) primary = 'Metabolic alkalosis';
        else if (co2 < 35 && hco3 > 26) primary = 'Mixed metabolic + respiratory alkalosis';
        else primary = 'Alkalemia';
      } else {
        if (co2 > 45 && hco3 > 26) primary = 'Compensated / mixed (high CO₂ + HCO₃)';
        else if (co2 < 35 && hco3 < 22) primary = 'Compensated / mixed (low CO₂ + HCO₃)';
        else primary = 'Normal pH';
      }
      level = primary.contains('Mixed') || primary.contains('acidosis') || primary.contains('alkalosis')
          ? Verdict.warn : Verdict.ok;

      if (primary.startsWith('Metabolic acidosis')) {
        final exp = 1.5 * hco3 + 8;
        comp = 'Winters: PaCO₂ ${fmt(exp - 2, d: 0)}–${fmt(exp + 2, d: 0)}';
        if (co2 > exp + 2) summaries.add('Inadequate respiratory compensation → concurrent respiratory acidosis.');
        else if (co2 < exp - 2) summaries.add('Over-compensation → concurrent respiratory alkalosis.');
      } else if (primary.startsWith('Metabolic alkalosis')) {
        final exp = 0.7 * (hco3 - 24) + 40;
        comp = 'Expected PaCO₂ ≈ ${fmt(exp, d: 0)}';
      } else if (primary.startsWith('Respiratory acidosis')) {
        final d = co2 - 40;
        comp = 'Acute ΔHCO₃ ≈ ${fmt(24 + 0.1 * d, d: 0)} · Chronic ≈ ${fmt(24 + 0.35 * d, d: 0)}';
      } else if (primary.startsWith('Respiratory alkalosis')) {
        final d = 40 - co2;
        comp = 'Acute ΔHCO₃ ≈ ${fmt(24 - 0.2 * d, d: 0)} · Chronic ≈ ${fmt(24 - 0.5 * d, d: 0)}';
      }
    }

    // Anion gap
    double? ag, cag, dd;
    String dText = '—';
    if (na != null && cl != null && hco3 != null) {
      ag = na - cl - hco3;
      cag = alb != null ? ag + 2.5 * (4 - alb) : ag;
      final dAG = (alb != null ? cag! : ag) - 12;
      final dHCO3 = 24 - hco3;
      if (dHCO3 != 0) {
        dd = dAG / dHCO3;
        final interp = dd < 0.4 ? 'pure non-AG metabolic acidosis'
            : dd < 1 ? 'mixed AG + non-AG acidosis'
            : dd <= 2 ? 'pure AG metabolic acidosis'
            : 'AG acidosis + concurrent met alkalosis';
        dText = '${fmt(dd, d: 2)} — $interp';
      }
    }

    String aaText = '—';
    if (pao2 != null && fio2 != null && co2 != null) {
      final pAO2 = fio2 * (760 - 47) - co2 / 0.8;
      final aa = pAO2 - pao2;
      final age = st.patient.age;
      final exp = age != null ? age / 4 + 4 : null;
      aaText = '${fmt(aa, d: 0)} mmHg${exp != null ? ' (expected ≤ ${fmt(exp, d: 0)})' : ''}';
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const InfoCard(
          title: 'Inputs',
          children: [
            FieldGrid(columns: 2, children: [
              NumField(stateKey: 'ab_ph', label: 'pH'),
              NumField(stateKey: 'ab_co2', label: 'PaCO₂', unit: 'mmHg'),
              NumField(stateKey: 'ab_hco3', label: 'HCO₃', unit: 'mEq/L'),
              NumField(stateKey: 'ab_na', label: 'Na', unit: 'mEq/L'),
              NumField(stateKey: 'ab_cl', label: 'Cl', unit: 'mEq/L'),
              NumField(stateKey: 'ab_alb', label: 'Albumin', unit: 'g/dL'),
              NumField(stateKey: 'ab_pao2', label: 'PaO₂', unit: 'mmHg'),
              NumField(stateKey: 'ab_fio2', label: 'FiO₂', hint: '0.4 or 40'),
            ]),
          ],
        ),
        InfoCard(
          title: 'Interpretation',
          children: [
            ResultRow('Primary disorder', primary, level: level, topDivider: false),
            ResultRow('Expected compensation', comp),
            ResultRow('Anion gap', ag == null ? '—' : fmt(ag, d: 1)),
            ResultRow('Corrected AG', cag == null ? '—' : '${fmt(cag, d: 1)}${alb == null ? " (no alb)" : ""}'),
            ResultRow('Δ-Δ ratio', dText),
            ResultRow('A–a gradient', aaText),
            VerdictBox(
              level: level,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(primary == '—' ? 'Enter pH, PaCO₂, HCO₃ to start.' : primary,
                    style: TextStyle(fontWeight: FontWeight.w800, color: level.color)),
                  if (comp != '—') Text(comp),
                  for (final s in summaries) Text('• $s'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
