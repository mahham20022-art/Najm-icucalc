import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/drugs.dart';
import '../models/drug.dart';
import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class InfusionsScreen extends StatelessWidget {
  const InfusionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final w = st.patient.weight;
    final q = st.drugQuery.trim().toLowerCase();
    final cat = st.drugCat;

    final filtered = drugs.where((d) {
      if (cat != 'all' && d.category != cat) return false;
      if (q.isEmpty) return true;
      return ('${d.name} ${d.category}').toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          onChanged: (v) => context.read<AppState>().setDrugQuery(v),
          decoration: InputDecoration(
            hintText: 'Search drug…',
            prefixIcon: const Icon(Icons.search, color: AppColors.muted, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          controller: TextEditingController.fromValue(TextEditingValue(
            text: st.drugQuery,
            selection: TextSelection.collapsed(offset: st.drugQuery.length),
          )),
        ),
        const SizedBox(height: 10),
        ChipRow(
          options: drugCategories,
          selected: cat,
          onSelect: (c) => context.read<AppState>().setDrugCat(c),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const InfoCard(
            title: 'No drugs match',
            subtitle: 'Clear the search or change the category.',
            children: [],
          )
        else
          for (final d in filtered) _drugCard(d, w),
      ],
    );
  }

  Widget _drugCard(Drug d, double? w) {
    final riskColor = d.riskLevel == 'high'
        ? Verdict.bad : d.riskLevel == 'low' ? Verdict.warn : Verdict.ok;

    final abs = d.absoluteFor(w);
    final rateLo = d.mlPerHour(d.min, w);
    final rateHi = d.mlPerHour(d.max, w);

    return InfoCard(
      title: d.name,
      subtitle: '${d.weightless ? "Fixed-rate" : "Weight-based"} · concentration: ${d.concLabel}',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.brand.withOpacity(0.12),
          border: Border.all(color: AppColors.brand.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          d.category,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.brand2, letterSpacing: 0.5),
        ),
      ),
      children: [
        ResultRow('Standard range', '${fmt(d.min, d: 2)} – ${fmt(d.max, d: 2)} ${d.unit}', level: riskColor, topDivider: false),
        if (abs != null && (w != null || d.weightless))
          if (!d.weightless)
            ResultRow('For ${w!.toStringAsFixed(0)} kg', '${fmt(abs.$1, d: 2)} – ${fmt(abs.$2, d: 2)} ${abs.$3}', level: riskColor),
        if (rateLo != null && rateHi != null)
          ResultRow('Drip @ ${d.concLabel}', '${fmt(rateLo, d: 2)} – ${fmt(rateHi, d: 1)} mL/hr'),
      ],
    );
  }
}
