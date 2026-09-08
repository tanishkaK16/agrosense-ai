import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/farm_photo_header.dart';
import '../../core/widgets/listen_button.dart';
import '../../generated/l10n/app_localizations.dart';

/// Home tab — Phase 0 foundation.
///
/// Shows a warm photo strip at the top, the farmer greeting,
/// and an empty-state card with a comingSoon label.
/// All functional content lands here in later phases.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Photo strip ─────────────────────────────────────────────
          FarmPhotoHeader(
            imagePath: 'assets/images/hero_field_sunrise.jpg',
            height: AppSizes.homePhotoStripHeight + topPad,
            child: Positioned(
              top: topPad + 8,
              left: AppSizes.paddingL,
              right: AppSizes.paddingS,
              child: Row(
                children: [
                  // App name mark
                  const Icon(
                    Icons.eco_rounded,
                    color: AppColors.onPhoto,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPhoto,
                    ),
                  ),
                  const Spacer(),
                  // Listen button — TTS placeholder
                  ListenButton(
                    onPhoto: true,
                    text: l10n.helloFarmer,
                  ),
                ],
              ),
            ),
          ),

          // ── Content area ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingL,
              AppSizes.paddingL,
              AppSizes.paddingL,
              // Extra bottom padding so the floating nav doesn't cover content
              AppSizes.navBarHeight + AppSizes.navBarBottomMargin + AppSizes.paddingL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.helloFarmer,
                  style: AppTextStyles.screenTitle(context),
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // Empty-state card
                _ComingSoonCard(l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Themed empty-state card — Phase 0 placeholder for feature cards.
class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            const Icon(
              Icons.spa_outlined,
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
    );
  }
}
