import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HemoScreen extends StatelessWidget {
  const HemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final sbp = st.input('hd_sbp'), dbp = st.input('hd_dbp'), hr = st.input('hd_hr');
    final map = (sbp != null && dbp != null) ? (sbp + 2 * dbp) / 3 : null;
    final pp = (sbp != null && dbp != null) ? sbp - dbp : null;
    final si = (hr != null && sbp != null && sbp > 0) ? hr / sbp : null;
    final msi = (hr != null && map != null && map > 0) ? hr / map : null;

    Verdict mapLevel;
    List<String> msgs = [];
    if (map == null) { mapLevel = Verdict.info; msgs.add('Enter SBP/DBP to interpret.'); }
    else if (map < 65) { mapLevel = Verdict.bad; msgs.add('MAP < 65 → inadequate perfusion.'); }
    else if (map > 110) { mapLevel = Verdict.warn; msgs.add('MAP > 110 → check sedation, pain, fluid overload.'); }
    else { mapLevel = Verdict.ok; msgs.add('MAP in target range.'); }
    if (si != null && si >= 1) msgs.add('Shock index ≥ 1 → consider occult shock.');
    else if (si != null && si >= 0.7) msgs.add('Shock index borderline (0.7–1).');

    // CPP
    final icp = st.input('cpp_icp');
    final mapOv = st.input('cpp_map');
    final effMap = mapOv ?? map;
    final cpp = (effMap != null && icp != null) ? effMap - icp : null;
    Verdict cppLevel = Verdict.info;
    String cppMsg = 'Enter ICP to compute (MAP auto-fills).';
    if (cpp != null) {
      if (cpp < 50) { cppLevel = Verdict.bad; cppMsg = 'CPP < 50 → critical ischemia risk.'; }
      else if (cpp < 60) { cppLevel = Verdict.warn; cppMsg = 'CPP 50–60 → borderline.'; }
      else { cppLevel = Verdict.ok; cppMsg = 'CPP ≥ 60 → adequate cerebral perfusion.'; }
    }

    // NE equivalents
    final ne  = st.input('ne_norepi') ?? 0;
    final epi = st.input('ne_epi') ?? 0;
    final phn = st.input('ne_phenyl') ?? 0;
    final dpa = st.input('ne_dop') ?? 0;
    final vas = st.input('ne_vaso') ?? 0;
    final anyNE = ne + epi + phn + dpa + vas > 0;
    final total = ne + epi + (phn / 10) + (dpa / 100) + (vas * 2.5);
    Verdict neLevel = Verdict.info;
    String neMsg = 'Sum of norepi-equivalent vasopressor support.';
    if (anyNE) {
      if (total >= 0.5) { neLevel = Verdict.bad; neMsg = 'Very high pressor load (≥ 0.5).'; }
      else if (total >= 0.25) { neLevel = Verdict.warn; neMsg = 'High pressor load (≥ 0.25).'; }
      else { neLevel = Verdict.ok; neMsg = 'Moderate / low pressor support.'; }
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        InfoCard(
          title: 'Blood Pressure',
          subtitle: 'Enter cuff or arterial line values.',
          children: [
            const FieldGrid(columns: 3, children: [
              NumField(stateKey: 'hd_sbp', label: 'SBP', unit: 'mmHg'),
              NumField(stateKey: 'hd_dbp', label: 'DBP', unit: 'mmHg'),
              NumField(stateKey: 'hd_hr', label: 'HR', unit: 'bpm'),
            ]),
            ResultRow('MAP', map == null ? '—' : '${fmt(map, d: 0)} mmHg', level: mapLevel, topDivider: false),
            ResultRow('Pulse Pressure', pp == null ? '—' : '${fmt(pp, d: 0)} mmHg'),
            ResultRow('Shock Index (HR/SBP)', si == null ? '—' : fmt(si, d: 2)),
            ResultRow('Modified SI (HR/MAP)', msi == null ? '—' : fmt(msi, d: 2)),
            VerdictBox(level: mapLevel, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final m in msgs) Text('• $m')],
            )),
          ],
        ),
        InfoCard(
          title: 'Cerebral Perfusion',
          subtitle: 'CPP = MAP − ICP. Target adults ≥ 60 mmHg.',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'cpp_icp', label: 'ICP', unit: 'mmHg'),
              NumField(stateKey: 'cpp_map', label: 'MAP override', hint: 'auto', unit: 'mmHg'),
            ]),
            ResultRow('CPP', cpp == null ? '—' : '${fmt(cpp, d: 0)} mmHg', level: cppLevel, topDivider: false),
            VerdictBox(level: cppLevel, child: Text(cppMsg)),
          ],
        ),
        InfoCard(
          title: 'Norepi Equivalents',
          subtitle: 'Rough comparator of vasopressor load (μg/kg/min equivalents).',
          children: [
            const FieldGrid(children: [
              NumField(stateKey: 'ne_norepi', label: 'Norepi', unit: 'μg/kg/min'),
              NumField(stateKey: 'ne_epi', label: 'Epi', unit: 'μg/kg/min'),
              NumField(stateKey: 'ne_phenyl', label: 'Phenyleph', unit: 'μg/kg/min'),
              NumField(stateKey: 'ne_dop', label: 'Dopamine', unit: 'μg/kg/min'),
              NumField(stateKey: 'ne_vaso', label: 'Vasopressin', unit: 'U/min'),
            ]),
            ResultRow('NE equivalent', anyNE ? '${fmt(total, d: 2)} mcg/kg/min' : '—', level: neLevel, topDivider: false),
            VerdictBox(level: neLevel, child: Text(neMsg)),
          ],
        ),
      ],
    );
  }
}
