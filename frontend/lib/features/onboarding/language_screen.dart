import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/farm_photo_header.dart';
import '../../core/widgets/language_mark.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';

/// Supported locale options shown on the language selection screen.
const List<_LangOption> _langOptions = [
  _LangOption(
    locale: Locale('en'),
    mark: 'EN',
    nativeName: 'English',
    subtitleEn: 'English',
  ),
  _LangOption(
    locale: Locale('hi'),
    mark: 'हि',
    nativeName: 'हिंदी',
    subtitleEn: 'Hindi',
  ),
  _LangOption(
    locale: Locale('mr'),
    mark: 'मर',
    nativeName: 'मराठी',
    subtitleEn: 'Marathi',
  ),
];

class _LangOption {
  const _LangOption({
    required this.locale,
    required this.mark,
    required this.nativeName,
    required this.subtitleEn,
  });

  final Locale locale;
  final String mark;
  final String nativeName; // text in its own script
  final String subtitleEn; // English subtitle
}

/// First-launch language selection screen.
///
/// Full-bleed farm photo hero, three large language cards, Continue pill.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale? _selected;

  Future<void> _onContinue() async {
    if (_selected == null) return;
    await LocaleController.instance.setLocale(_selected!);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Transparent status bar — photo bleeds behind it
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Hero photo ─────────────────────────────────────────────────
          FarmPhotoHeader(
            imagePath: 'assets/images/hero_wheat_closeup.jpg',
            height: screenHeight * 0.42,
            child: Stack(
              children: [
                // App name + leaf mark — top left
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 16,
                  left: AppSizes.paddingL,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: AppColors.onPhoto,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.appName,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPhoto,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Welcome title + subtitle over scrim
                Positioned(
                  left: AppSizes.paddingL,
                  right: AppSizes.paddingL,
                  bottom: AppSizes.paddingXL,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.welcomeTitle,
                        style: AppTextStyles.onPhoto(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.welcomeSubtitle,
                        style: AppTextStyles.onPhotoSub(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Language cards ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingL,
                AppSizes.paddingL,
                AppSizes.paddingL,
                AppSizes.paddingXXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chooseLanguage,
                    style: AppTextStyles.labelLarge(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selected == null ? l10n.tapToStart : '',
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Language option cards
                  ...List.generate(_langOptions.length, (i) {
                    final opt = _langOptions[i];
                    final isSelected = _selected == opt.locale;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                      child: _LanguageCard(
                        option: opt,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selected = opt.locale),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSizes.paddingL),

                  // Continue pill button
                  PrimaryPillButton(
                    label: l10n.continueLabel,
                    onPressed: _onContinue,
                    enabled: _selected != null,
                    icon: Icons.arrow_forward_rounded,
                  ),

                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single language option card.
class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _LangOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: isSelected ? AppColors.sageRing : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: isSelected ? AppShadows.medium : AppShadows.soft,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: SizedBox(
          height: AppSizes.languageCardHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            child: Row(
              children: [
                // Language mark circle
                LanguageMark(
                  code: option.mark,
                  size: 44,
                ),
                const SizedBox(width: AppSizes.paddingM),

                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option.nativeName,
                        style: AppTextStyles.labelLarge(context).copyWith(
                          fontFamily: option.locale.languageCode == 'en'
                              ? 'Outfit'
                              : null,
                        ),
                      ),
                      if (option.locale.languageCode != 'en')
                        Text(
                          option.subtitleEn,
                          style: AppTextStyles.caption(context),
                        ),
                    ],
                  ),
                ),

                // Selection indicator / volume icon
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.volume_up_rounded,
                  color: isSelected ? AppColors.primary : AppColors.muted,
                  size: AppSizes.iconMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
