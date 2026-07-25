import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/scores.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ScoresScreen extends StatelessWidget {
  const ScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [for (final s in scores) _ScoreCard(def: s)],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final ScoreDef def;
  const _ScoreCard({required this.def});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final selections = st.scores[def.key] ?? const {};
    num total = 0;
    var any = false;
    for (var i = 0; i < def.items.length; i++) {
      final v = selections[i];
      if (v != null) { total += v; any = true; }
    }
    Verdict level = Verdict.info;
    String msg = '—';
    if (any) {
      final r = def.interpret(total);
      msg = r.$1; level = r.$2;
    }

    return InfoCard(
      title: def.name,
      subtitle: def.subtitle,
      children: [
        for (var i = 0; i < def.items.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.border, width: 0.6)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(def.items[i].label, style: const TextStyle(fontSize: 13, color: AppColors.muted))),
                const SizedBox(width: 8),
                Flexible(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<num?>(
                      value: selections[i],
                      isDense: true,
                      hint: const Text('—', style: TextStyle(color: AppColors.muted)),
                      dropdownColor: AppColors.panel,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                      items: [
                        const DropdownMenuItem<num?>(value: null, child: Text('—')),
                        for (final o in def.items[i].options)
                          DropdownMenuItem<num?>(value: o.value, child: Text(o.label)),
                      ],
                      onChanged: (v) => context.read<AppState>().setScore(def.key, i, v ?? -9999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        VerdictBox(
          level: level,
          child: Row(
            children: [
              const Text('Total: ', style: TextStyle(fontWeight: FontWeight.w800)),
              Text(any ? '$total' : '—',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: level.color)),
              const SizedBox(width: 10),
              Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700))),
            ],
          ),
        ),
      ],
    );
  }
}
