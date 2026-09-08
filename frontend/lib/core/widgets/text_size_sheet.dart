import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../constants/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';
import '../theme/text_scale_controller.dart';
import '../voice/voice_service.dart';
import 'listen_button.dart';

/// Farmer-friendly bottom sheet to choose between Small, Default, and Large text.
class TextSizeSheet extends StatelessWidget {
  const TextSizeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TextSizeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentScale = TextScaleController.instance.scale;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
        boxShadow: AppShadows.medium,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        bottomPad + AppSizes.paddingL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.textSize,
                  style: AppTextStyles.labelLarge(context).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListenButton(
                onPhoto: false,
                text: l10n.textSizePrompt,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Semantics(
                label: l10n.semanticsClose,
                button: true,
                child: InkWell(
                  onTap: () {
                    VoiceService.instance.stop();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.ink,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Option 1: Small
          _buildRow(
            context: context,
            title: l10n.textSizeSmall,
            description: l10n.textSizeSmallDesc,
            scale: AppTextScale.small,
            sampleSize: 17,
            isSelected: currentScale == AppTextScale.small,
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Option 2: Default
          _buildRow(
            context: context,
            title: l10n.textSizeDefault,
            description: l10n.textSizeDefaultDesc,
            scale: AppTextScale.standard,
            sampleSize: 20,
            isSelected: currentScale == AppTextScale.standard,
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Option 3: Large
          _buildRow(
            context: context,
            title: l10n.textSizeLarge,
            description: l10n.textSizeLargeDesc,
            scale: AppTextScale.large,
            sampleSize: 24,
            isSelected: currentScale == AppTextScale.large,
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildRow({
    required BuildContext context,
    required String title,
    required String description,
    required AppTextScale scale,
    required double sampleSize,
    required bool isSelected,
  }) {
    return Semantics(
      label: '$title, $description',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () async {
          await VoiceService.instance.stop();
          await TextScaleController.instance.setScale(scale);
          if (context.mounted) {
            Navigator.of(context).maybePop();
          }
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(
              color: isSelected ? AppColors.sageRing : AppColors.surfaceVariant,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected ? AppShadows.soft : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.healthyContainer : AppColors.surfaceVariant.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: sampleSize,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.primary : AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge(context).copyWith(
                        fontSize: sampleSize,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.caption(context).copyWith(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.surface,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
