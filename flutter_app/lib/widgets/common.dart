import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// A titled card used to group related inputs and outputs on each screen.
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.panel, AppColors.panel2],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: AppColors.text, letterSpacing: -0.2,
                    )),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: const TextStyle(
                        fontSize: 12, color: AppColors.muted, height: 1.4,
                      )),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// A key/value row like "MAP  ...  78 mmHg" separated by a dashed line.
class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Verdict? level;
  final bool topDivider;

  const ResultRow(this.label, this.value, {
    super.key, this.level, this.topDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = level == null ? AppColors.text : level!.color;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: topDivider
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, style: BorderStyle.solid, width: 0.6)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.muted))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colored verdict box (info/ok/warn/bad).
class VerdictBox extends StatelessWidget {
  final Widget child;
  final Verdict level;

  const VerdictBox({super.key, required this.child, this.level = Verdict.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: level.bg,
        border: Border.all(color: level.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 13.5, color: AppColors.text, height: 1.5),
        child: child,
      ),
    );
  }
}

/// A number field that reads / writes an AppState input key.
class NumField extends StatelessWidget {
  final String stateKey;
  final String label;
  final String? unit;
  final String? hint;

  const NumField({
    super.key,
    required this.stateKey,
    required this.label,
    this.unit,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final current = st.inputStr(stateKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.5,
        )),
        const SizedBox(height: 4),
        TextFormField(
          key: ValueKey('nf-$stateKey'),
          initialValue: current,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]'))],
          decoration: InputDecoration(
            hintText: hint ?? unit,
            suffixText: unit,
            suffixStyle: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          onChanged: (v) => context.read<AppState>().setInput(stateKey, v),
        ),
      ],
    );
  }
}

/// A row of NumField widgets that flows into a grid.
class FieldGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  const FieldGrid({super.key, required this.children, this.columns = 2});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (var c = 0; c < columns; c++) {
        final idx = i + c;
        if (idx < children.length) {
          rowChildren.add(Expanded(child: children[idx]));
        } else {
          rowChildren.add(const Spacer());
        }
        if (c < columns - 1) rowChildren.add(const SizedBox(width: 8));
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowChildren),
      ));
    }
    return Column(children: rows);
  }
}

/// A small horizontally-scrollable chip row.
class ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final void Function(String) onSelect;
  final String Function(String)? labelFor;

  const ChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.labelFor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(labelFor == null ? (o == 'all' ? 'All' : o) : labelFor!(o)),
                selected: o == selected,
                onSelected: (_) => onSelect(o),
                labelStyle: TextStyle(
                  color: o == selected ? const Color(0xFF001018) : AppColors.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                selectedColor: AppColors.brand,
                backgroundColor: AppColors.panel3,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}
