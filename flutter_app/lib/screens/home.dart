import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/patient_bar.dart';
import 'abg.dart';
import 'about.dart';
import 'antibiotics.dart';
import 'electrolytes.dart';
import 'hemodynamics.dart';
import 'infusions.dart';
import 'notes.dart';
import 'renal.dart';
import 'scores.dart';
import 'ventilator.dart';

class _ModuleDef {
  final String title;
  final IconData icon;
  final Widget screen;
  const _ModuleDef(this.title, this.icon, this.screen);
}

const _modules = <_ModuleDef>[
  _ModuleDef('Infusions',     Icons.medication,      InfusionsScreen()),
  _ModuleDef('Antibiotics',   Icons.vaccines,        AntibioticsScreen()),
  _ModuleDef('Hemodynamics',  Icons.monitor_heart,   HemoScreen()),
  _ModuleDef('Ventilator',    Icons.air,             VentilatorScreen()),
  _ModuleDef('ABG',           Icons.science,         AbgScreen()),
  _ModuleDef('Electrolytes',  Icons.bolt,            ElectrolytesScreen()),
  _ModuleDef('Renal & Fluids',Icons.water_drop,      RenalScreen()),
  _ModuleDef('Scores',        Icons.assessment,      ScoresScreen()),
  _ModuleDef('Notes',         Icons.notes,           NotesScreen()),
  _ModuleDef('About',         Icons.info_outline,    AboutScreen()),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final i = st.tab.clamp(0, _modules.length - 1);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.brand, AppColors.accent],
                ),
              ),
              child: const Icon(Icons.favorite, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _modules[i].title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Najm ICUCalc',
                    style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.panel,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Modules',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 1),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _modules.length,
                  itemBuilder: (c, idx) {
                    final selected = idx == i;
                    return ListTile(
                      leading: Icon(_modules[idx].icon,
                        color: selected ? AppColors.brand2 : AppColors.muted),
                      title: Text(_modules[idx].title, style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.text : AppColors.text.withOpacity(0.85),
                      )),
                      selected: selected,
                      selectedTileColor: AppColors.brand.withOpacity(0.12),
                      onTap: () {
                        Navigator.pop(c);
                        context.read<AppState>().setTab(idx);
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Najm ICUCalc · v1.0.0\nDesigned by Dr. Mohamed Najm',
                  style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const PatientBar(),
          _quickTabsBar(context, i),
          Expanded(child: _modules[i].screen),
        ],
      ),
    );
  }

  /// Horizontal scrollable tab bar right under the patient bar, giving quick
  /// access to every module without opening the drawer.
  Widget _quickTabsBar(BuildContext context, int active) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            for (var idx = 0; idx < _modules.length; idx++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _quickTab(context, idx, active),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickTab(BuildContext context, int idx, int active) {
    final m = _modules[idx];
    final selected = idx == active;
    return Material(
      color: selected ? AppColors.brand : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.read<AppState>().setTab(idx),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(m.icon, size: 16,
                color: selected ? const Color(0xFF001018) : AppColors.muted),
              const SizedBox(width: 6),
              Text(m.title, style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFF001018) : AppColors.text,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
