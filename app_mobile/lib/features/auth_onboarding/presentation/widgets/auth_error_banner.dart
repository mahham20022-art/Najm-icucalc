import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failure.dart';

/// Non-blocking inline banner for an auth failure — never a modal alert
/// for an expected input mistake, per `MED100_UI_UX_SPEC.md` §3/§19.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.danger, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              failure.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
