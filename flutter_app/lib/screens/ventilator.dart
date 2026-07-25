import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class VentilatorScreen extends StatelessWidget {
  const VentilatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final pbw = st.patient.pbw;

    final pao2 = st.input('v_pao2');
    final spo2 = st.input('v_spo2');
    final fio2 = fio2Fraction(st.input('v_fio2'));
    final pf = (pao2 != null && fio2 != null) ? pao2 / fio2 : null;
    final sf = (spo2 != null && fio2 != null) ? spo2 / fio2 : null;

    Verdict pfLevel = Verdict.info;
    String pfMsg = 'Enter PaO₂ and FiO₂ for Berlin ARDS classification.';
    if (pf != null) {
      if (pf < 100) { pfLevel = Verdict.bad; pfMsg = 'P/F < 100 → severe ARDS.'; }
      else if (pf < 200) { pfLevel = Verdict.bad; pfMsg = 'P/F 100–200 → moderate ARDS.'; }
      else if (pf < 300) { pfLevel = Verdict.warn; pfMsg = 'P/F 200–300 → mild ARDS.'; }
      else { pfLevel = Verdict.ok; pfMsg = 'P/F ≥ 300 → no ARDS by Berlin.'; }
    }

    final pplat = st.input('v_pplat');
    final peep  = st.input('v_peep');
    final tv    = st.input('v_tv');
    final dp = (pplat != null && peep != null) ? pplat - peep : null;
    final cs = (tv != null && dp != null && dp > 0) ? tv / dp : null;
    Verdict dpLevel = Verdict.info;
    String dpMsg = 'Target driving pressure < 15 cmH₂O.';
    if (dp != null) {
      if (dp >= 15) { dpLevel = Verdict.bad; dpMsg = 'Driving pressure ≥ 15 → reduce TV or recruit.'; }
      else if (dp >= 13) { dpLevel = Verdict.warn; dpMsg = 'Driving pressure 13–14 → caution.'; }
      else { dpLevel = Verdict.ok; dpMsg = 'Driving pressure within safe range.'; }
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        InfoCard(
          title: 'Tidal Volume (Predicted BW)',
          subtitle: 'PBW (Devine) needs height & sex. Targets: 4 / 6 / 8 mL/kg.',
          children: [
            ResultRow('PBW', pbw == null ? '—' : '${fmt(pbw, d: 1)} kg', topDivider: false),
            ResultRow('TV 4 mL/kg (low)', pbw == null ? '—' : '${fmt(pbw * 4, d: 0)} mL'),
            ResultRow('TV 6 mL/kg (target)', pbw == null ? '—' : '${fmt(pbw * 6, d: 0)} mL', level: Verdict.ok),
            ResultRow('TV 8 mL/kg (max ARDS)', pbw == null ? '—' : '${fmt(pbw * 8, d: 0)} mL'),
          ],
        ),
        InfoCard(
          title: 'Oxygenation (P/F & SF)',
          children: [
            const FieldGrid(columns: 3, children: [
              NumField(stateKey: 'v_pao2', label: 'PaO₂', unit: 'mmHg'),
              NumField(stateKey: 'v_spo2', label: 'SpO₂', unit: '%'),
              NumField(stateKey: 'v_fio2', label: 'FiO₂', hint: '0.4 or 40'),
            ]),
            ResultRow('P/F ratio', pf == null ? '—' : fmt(pf, d: 0), level: pfLevel, topDivider: false),
            ResultRow('SpO₂/FiO₂', sf == null ? '—' : fmt(sf, d: 0)),
            VerdictBox(level: pfLevel, child: Text(pfMsg)),
          ],
        ),
        InfoCard(
          title: 'Driving Pressure & Compliance',
          children: [
            const FieldGrid(columns: 3, children: [
              NumField(stateKey: 'v_pplat', label: 'Pplat', unit: 'cmH₂O'),
              NumField(stateKey: 'v_peep', label: 'PEEP', unit: 'cmH₂O'),
              NumField(stateKey: 'v_tv', label: 'TV', unit: 'mL'),
            ]),
            ResultRow('Driving pressure', dp == null ? '—' : '${fmt(dp, d: 0)} cmH₂O', level: dpLevel, topDivider: false),
            ResultRow('Static compliance', cs == null ? '—' : '${fmt(cs, d: 1)} mL/cmH₂O'),
            VerdictBox(level: dpLevel, child: Text(dpMsg)),
          ],
        ),
      ],
    );
  }
}
