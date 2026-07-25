import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../services/formatters.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Sticky patient bar shown at the top of every screen.
class PatientBar extends StatelessWidget {
  const PatientBar({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final p = st.patient;

    return Material(
      color: AppColors.panel2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _numField(
                  context, 'Weight', 'kg', p.weight,
                  onChanged: (v) => context.read<AppState>().updatePatient(
                    (x) => x.copyWith(weight: v, clearWeight: v == null),
                  ),
                ),
                _numField(
                  context, 'Height', 'cm', p.height,
                  onChanged: (v) => context.read<AppState>().updatePatient(
                    (x) => x.copyWith(height: v, clearHeight: v == null),
                  ),
                ),
                _numField(
                  context, 'Age', 'yr', p.age,
                  onChanged: (v) => context.read<AppState>().updatePatient(
                    (x) => x.copyWith(age: v, clearAge: v == null),
                  ),
                ),
                _sexField(context, p),
                _numField(
                  context, 'Cr', 'mg/dL', p.creatinine,
                  onChanged: (v) => context.read<AppState>().updatePatient(
                    (x) => x.copyWith(creatinine: v, clearCr: v == null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _derived(context, 'IBW', p.pbw, 'kg'),
                _derived(context, 'BSA', p.bsa, 'm²', decimals: 2),
                _derived(context, 'CrCl', p.crCl, 'mL/min'),
                const Spacer(),
                _clearBtn(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(
    BuildContext ctx,
    String label,
    String unit,
    double? current, {
    required void Function(double?) onChanged,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.muted, letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            TextFormField(
              initialValue: current == null ? '' : (
                current == current.roundToDouble() ? current.toInt().toString() : current.toString()
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: unit,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              onChanged: (s) {
                if (s.isEmpty) { onChanged(null); return; }
                final v = double.tryParse(s);
                if (v != null) onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sexField(BuildContext ctx, Patient p) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SEX',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.muted, letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            DropdownButtonFormField<String>(
              value: p.sex.isEmpty ? null : p.sex,
              isDense: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                hintText: '—',
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
              dropdownColor: AppColors.panel,
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Male')),
                DropdownMenuItem(value: 'F', child: Text('Female')),
              ],
              onChanged: (v) => ctx.read<AppState>().updatePatient(
                (x) => x.copyWith(sex: v ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _derived(BuildContext ctx, String label, double? v, String unit, {int decimals = 1}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.brand.withOpacity(0.08),
          border: Border.all(color: AppColors.brand.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.muted, letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                v == null ? '—' : fmt(v, d: decimals),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.brand2,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _clearBtn(BuildContext ctx) {
    return OutlinedButton(
      onPressed: () {
        ctx.read<AppState>().clearPatient();
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Patient cleared'), duration: Duration(milliseconds: 1200)),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.muted,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: const Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
