import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/antibiotics.dart';
import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AntibioticsScreen extends StatelessWidget {
  const AntibioticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final crcl = st.patient.crCl;

    final activeClass = st.abxClass;
    final q = st.abxQuery.trim().toLowerCase();

    final filtered = antibiotics.where((a) {
      if (activeClass != 'all' && a.category != activeClass) return false;
      if (q.isEmpty) return true;
      return ('${a.name} ${a.category} ${a.indications}').toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // CrCl badge
        Row(
          children: [
            const Text(
              'Empiric doses with renal adjustment by CrCl.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: (crcl == null ? Verdict.info : crcl < 30 ? Verdict.bad : crcl < 60 ? Verdict.warn : Verdict.ok).bg,
                border: Border.all(color: (crcl == null ? Verdict.info : crcl < 30 ? Verdict.bad : crcl < 60 ? Verdict.warn : Verdict.ok).border),
              ),
              child: Text(
                crcl == null ? 'CrCl —' : 'CrCl ${fmt(crcl, d: 0)} mL/min',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: (crcl == null ? Verdict.info : crcl < 30 ? Verdict.bad : crcl < 60 ? Verdict.warn : Verdict.ok).color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (v) => context.read<AppState>().setAbxQuery(v),
          decoration: const InputDecoration(
            hintText: 'Search antibiotic (e.g. mero, vanco)…',
            prefixIcon: Icon(Icons.search, color: AppColors.muted, size: 20),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          controller: TextEditingController.fromValue(TextEditingValue(
            text: st.abxQuery,
            selection: TextSelection.collapsed(offset: st.abxQuery.length),
          )),
        ),
        const SizedBox(height: 10),
        ChipRow(
          options: antibioticClasses,
          selected: activeClass,
          onSelect: (c) => context.read<AppState>().setAbxClass(c),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const InfoCard(
            title: 'No antibiotic matches',
            subtitle: 'Clear the search or change the class.',
            children: [],
          )
        else
          for (final a in filtered) _card(a, crcl),
      ],
    );
  }

  Widget _card(Antibiotic a, double? crcl) {
    final (doseLabel, active) = a.doseFor(crcl);
    return InfoCard(
      title: a.name,
      subtitle: a.indications,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.brand.withOpacity(0.12),
          border: Border.all(color: AppColors.brand.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          a.category,
          style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w800,
            color: AppColors.brand2, letterSpacing: 0.5,
          ),
        ),
      ),
      children: [
        ResultRow('Standard dose', a.standardDose, topDivider: false),
        ResultRow(
          active ? 'For CrCl ${fmt(crcl, d: 0)}' : 'Adjusted dose',
          doseLabel,
          level: active ? Verdict.ok : Verdict.info,
        ),
        if (a.notes != null) VerdictBox(level: Verdict.warn, child: Text(a.notes!)),
      ],
    );
  }
}
