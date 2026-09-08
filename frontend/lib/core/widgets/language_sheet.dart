import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../constants/app_sizes.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';
import '../voice/voice_service.dart';
import 'language_mark.dart';
import 'listen_button.dart';

/// Single language item descriptor for the bottom sheet.
class _SheetLangOption {
  const _SheetLangOption({
    required this.locale,
    required this.mark,
    required this.nativeName,
    required this.subtitleEn,
  });

  final Locale locale;
  final String mark;
  final String nativeName;
  final String subtitleEn;
}

const List<_SheetLangOption> _sheetOptions = [
  _SheetLangOption(
    locale: Locale('en'),
    mark: 'EN',
    nativeName: 'English',
    subtitleEn: 'English',
  ),
  _SheetLangOption(
    locale: Locale('hi'),
    mark: 'हि',
    nativeName: 'हिंदी',
    subtitleEn: 'Hindi',
  ),
  _SheetLangOption(
    locale: Locale('mr'),
    mark: 'मर',
    nativeName: 'मराठी',
    subtitleEn: 'Marathi',
  ),
];

/// Farmer-friendly bottom sheet to switch active language.
///
/// Features:
/// - Three huge selectable rows with Phase 0 LanguageMark badges (EN, हि, मर)
/// - Wheat/forest ring on selected row
/// - Dedicated Listen button reading the three options aloud
/// - Immediate reactivity across all screens and services
/// - High contrast EcoFarm aesthetic with 64+ tap targets
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  /// Helper to display this bottom sheet from any screen.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode =
        LocaleController.instance.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final speechPrompt = l10n.languagePrompt;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
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

          // Header: Title, Listen Button & Close
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.changeLanguage,
                  style: AppTextStyles.labelLarge(context).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListenButton(
                onPhoto: false,
                text: speechPrompt,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Semantics(
                label: 'Close language selection',
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

          // Three Huge Language Rows
          for (final option in _sheetOptions) ...[
            _buildLanguageRow(
              context: context,
              option: option,
              isSelected: option.locale.languageCode == currentCode,
            ),
            const SizedBox(height: AppSizes.paddingM),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageRow({
    required BuildContext context,
    required _SheetLangOption option,
    required bool isSelected,
  }) {
    return Semantics(
      label: '${option.nativeName}, ${option.subtitleEn}',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () async {
          await VoiceService.instance.stop();
          await LocaleController.instance.setLocale(option.locale);
          if (context.mounted) {
            Navigator.of(context).pop();
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
              LanguageMark(
                code: option.mark,
                size: 48,
              ),
              const SizedBox(width: AppSizes.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.nativeName,
                      style: AppTextStyles.labelLarge(context).copyWith(
                        fontSize: 20,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontFamily: option.locale.languageCode == 'en' ? 'Outfit' : null,
                      ),
                    ),
                    if (option.locale.languageCode != 'en') ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitleEn,
                        style: AppTextStyles.caption(context).copyWith(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
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
