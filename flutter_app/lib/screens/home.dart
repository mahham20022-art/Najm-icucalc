import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/patient_bar.dart';
import 'abg.dart';
import 'electrolytes.dart';
import 'hemodynamics.dart';
import 'infusions.dart';
import 'notes.dart';
import 'renal.dart';
import 'scores.dart';
import 'ventilator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _titles = [
    'Infusions', 'Hemodynamics', 'Ventilator', 'ABG',
    'Electrolytes', 'Renal & Fluids', 'Scores', 'Notes',
  ];

  static const _screens = [
    InfusionsScreen(), HemoScreen(), VentilatorScreen(), AbgScreen(),
    ElectrolytesScreen(), RenalScreen(), ScoresScreen(), NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final i = st.tab.clamp(0, _screens.length - 1);

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
                    _titles[i],
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.muted),
            color: AppColors.panel,
            onSelected: (v) {
              if (v == 'privacy') _showPrivacy(context);
              if (v == 'about') _showAbout(context);
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'privacy', child: Text('Privacy policy')),
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const PatientBar(),
          Expanded(child: _screens[i]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => context.read<AppState>().setTab(v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.medication_outlined),   selectedIcon: Icon(Icons.medication),   label: 'Drips'),
          NavigationDestination(icon: Icon(Icons.monitor_heart_outlined),selectedIcon: Icon(Icons.monitor_heart),label: 'Hemo'),
          NavigationDestination(icon: Icon(Icons.air),                   selectedIcon: Icon(Icons.air),          label: 'Vent'),
          NavigationDestination(icon: Icon(Icons.science_outlined),      selectedIcon: Icon(Icons.science),      label: 'ABG'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined),         selectedIcon: Icon(Icons.bolt),         label: 'Lytes'),
          NavigationDestination(icon: Icon(Icons.water_drop_outlined),   selectedIcon: Icon(Icons.water_drop),   label: 'Renal'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined),   selectedIcon: Icon(Icons.assessment),   label: 'Scores'),
          NavigationDestination(icon: Icon(Icons.notes_outlined),        selectedIcon: Icon(Icons.notes),        label: 'Notes'),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: AppColors.panel,
      title: const Text('Privacy'),
      content: const SingleChildScrollView(child: Text(
        'Najm ICUCalc collects, transmits, and shares no personal data. Patient '
        'inputs and notes are stored only on this device and never leave it. The '
        'app requests no runtime permissions and functions fully offline after '
        'installation.\n\nReference aid only — not a medical device. Always '
        'verify calculations against institutional protocols and drug labels.',
        style: TextStyle(height: 1.5),
      )),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
    ));
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Najm ICUCalc',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Najm ICUCalc\n\nReference aid only — not a medical device.',
    );
  }
}
