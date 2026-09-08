import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/listen_button.dart';
import '../../generated/l10n/app_localizations.dart';

/// My Fields tab — Phase 0 foundation.
///
/// Warm cream background, screen title, empty-state card.
/// Field CRUD and map view are future phases.
class FieldsScreen extends StatelessWidget {
  const FieldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar row ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                top: topPad > 0 ? 0 : AppSizes.paddingM,
                left: AppSizes.paddingL,
                right: AppSizes.paddingS,
                bottom: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.myFields,
                    style: AppTextStyles.screenTitle(context),
                  ),
                  const Spacer(),
                  ListenButton(text: l10n.myFields),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingL,
                  AppSizes.paddingM,
                  AppSizes.paddingL,
                  AppSizes.navBarHeight + AppSizes.navBarBottomMargin + AppSizes.paddingL,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    boxShadow: AppShadows.soft,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingXL),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            size: 48,
                            color: AppColors.primarySoft,
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            l10n.comingSoon,
                            style: AppTextStyles.labelLarge(context).copyWith(
                              color: AppColors.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
