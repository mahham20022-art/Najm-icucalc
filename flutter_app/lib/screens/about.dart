import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/antibiotics.dart';
import '../services/storage.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const InfoCard(
          title: 'Designed by',
          subtitle: 'Author & clinical lead',
          children: [
            ResultRow('Name', 'Dr. Mohamed Najm', topDivider: false),
            ResultRow('Credentials', 'MBBS · PgDip EM · FEBN · MRCEM SECONDARY'),
            ResultRow('Version', '1.0.0'),
          ],
        ),
        InfoCard(
          title: 'Clinical References',
          subtitle: 'Sources for dose ranges, formulas, and score interpretations.',
          children: [
            for (var i = 0; i < references.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.border, width: 0.6)),
                  ),
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text('${i + 1}.',
                          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      ),
                      Expanded(
                        child: Text(references[i],
                          style: const TextStyle(fontSize: 13, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        InfoCard(
          title: 'Disclaimer',
          subtitle: 'Reference aid — not a medical device.',
          children: [
            const VerdictBox(
              level: Verdict.warn,
              child: Text(
                'All doses, calculations, and score interpretations presented in Najm ICUCalc '
                'are for clinical reference only. Every value must be independently verified '
                'by a qualified clinician against institutional protocols, drug labels, and '
                'the patient\'s clinical context. The author assumes no liability for clinical '
                'decisions made with this tool.',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          backgroundColor: AppColors.panel,
                          title: const Text('Wipe all local data?'),
                          content: const Text(
                            'This clears the patient bar, every calculator input, all score '
                            'selections, and shift notes on this device. Cannot be undone.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Wipe', style: TextStyle(color: AppColors.danger)),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        final st = context.read<AppState>();
                        await st.wipe();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All local data cleared'), duration: Duration(milliseconds: 1400)),
                          );
                        }
                      }
                    },
                    child: const Text('Wipe all local data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
