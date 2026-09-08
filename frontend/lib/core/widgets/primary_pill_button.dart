import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../constants/app_sizes.dart';

/// Full-width rounded pill CTA button used for primary actions.
///
/// - Disabled until [enabled] is true
/// - Shows an animated opacity change when enabled state changes
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          boxShadow: enabled ? AppShadows.medium : [],
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppSizes.minTapTarget,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPhoto,
              disabledBackgroundColor: AppColors.primarySoft,
              disabledForegroundColor: AppColors.onPhoto,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSizes.iconMedium),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
