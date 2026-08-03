import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/nav_card.dart';
import '../assessment/assessment_wizard_screen.dart';
import '../library/library_screen.dart';
import '../localization/localization_screen.dart';
import '../pearls/pearls_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                children: [
                  const Center(child: AppLogo(size: 104)),
                  const SizedBox(height: AppSpacing.s5),
                  const Center(
                    child: Text(
                      'SEIZUREMETER',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Clinical Decision Support for Seizure Assessment',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 13.5, letterSpacing: 0.2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  NavCard(
                    icon: Icons.fact_check_outlined,
                    title: 'Seizure Assessment',
                    subtitle: 'A 5-step wizard estimating epileptic vs. PNES vs. syncope vs. other mimic.',
                    accent: AppColors.brand3,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AssessmentWizardScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  NavCard(
                    icon: Icons.route_outlined,
                    title: 'Localization',
                    subtitle: 'Explore aura, semiology, EEG and MRI patterns by lobe of onset.',
                    accent: AppColors.pnes,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LocalizationScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  NavCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Seizure Library',
                    subtitle: 'Searchable reference of seizure types and epilepsy syndromes.',
                    accent: AppColors.ok,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LibraryScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  NavCard(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Clinical Pearls',
                    subtitle: 'Short, evidence-based teaching notes.',
                    accent: AppColors.warn,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PearlsScreen()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const DisclaimerBanner(compact: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
