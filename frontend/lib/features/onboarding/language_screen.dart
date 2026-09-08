import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/routing/app_router.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/farm_photo_header.dart';
import '../../core/widgets/language_mark.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';

/// Supported locale options shown on the language selection screen.
const List<_LangOption> _langOptions = [
  _LangOption(
    locale: Locale('en'),
    mark: 'EN',
    nativeName: 'English',
    subtitleEn: 'English',
    spokenPrompt: 'English. Tap continue when ready.',
  ),
  _LangOption(
    locale: Locale('hi'),
    mark: 'हि',
    nativeName: 'हिंदी',
    subtitleEn: 'Hindi',
    spokenPrompt: 'हिंदी. तैयार होने पर आगे बढ़ें दबाएं.',
  ),
  _LangOption(
    locale: Locale('mr'),
    mark: 'मर',
    nativeName: 'मराठी',
    subtitleEn: 'Marathi',
    spokenPrompt: 'मराठी. तयार झाल्यावर पुढे जा दाबा.',
  ),
];

class _LangOption {
  const _LangOption({
    required this.locale,
    required this.mark,
    required this.nativeName,
    required this.subtitleEn,
    required this.spokenPrompt,
  });

  final Locale locale;
  final String mark;
  final String nativeName;
  final String subtitleEn;
  final String spokenPrompt;
}

/// First-launch language selection screen.
///
/// Features:
/// - Full-bleed farm photo hero with warm dark scrim
/// - Working Listen button in top right reading screen aloud in active language
/// - Three large language cards with dedicated volume playback and check mark
/// - Changing language updates all screen copy and speech immediately
/// - Continue pill leads to Onboarding until completed
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale? _selected;

  @override
  void initState() {
    super.initState();
    _selected = LocaleController.instance.locale;
  }

  @override
  void dispose() {
    VoiceService.instance.stop();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_selected == null) return;
    await VoiceService.instance.stop();
    await LocaleController.instance.setLocale(_selected!);
    if (!mounted) return;
    if (AppPrefs.instance.isOnboardingDone) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLocale = _selected ??
        LocaleController.instance.locale ??
        Localizations.localeOf(context);

    // Transparent status bar — photo bleeds behind it
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Localizations.override(
      context: context,
      locale: effectiveLocale,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final screenHeight = MediaQuery.sizeOf(context).height;
          final screenSpeech =
              '${l10n.welcomeTitle}. ${l10n.welcomeSubtitle}. ${l10n.chooseLanguage}.';

          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                // ── Hero photo ─────────────────────────────────────────────
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

                      // Screen-level Listen button — top right
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 10,
                        right: AppSizes.paddingL,
                        child: ListenButton(
                          onPhoto: true,
                          text: screenSpeech,
                          languageCode: effectiveLocale.languageCode,
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

                // ── Language cards ─────────────────────────────────────────
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
                            padding:
                                const EdgeInsets.only(bottom: AppSizes.paddingS),
                            child: _LanguageCard(
                              option: opt,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _selected = opt.locale);
                              },
                              onListen: () {
                                VoiceService.instance.toggle(
                                  text: opt.spokenPrompt,
                                  languageCode: opt.locale.languageCode,
                                );
                              },
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
        },
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
    required this.onListen,
  });

  final _LangOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onListen;

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

                // Listen aloud button for this language
                Semantics(
                  label: 'Listen to language',
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onListen,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: ListenableBuilder(
                          listenable: VoiceService.instance,
                          builder: (context, _) {
                            final isSpeakingThis =
                                VoiceService.instance.isSpeaking &&
                                VoiceService.instance.lastSpokenText ==
                                    option.spokenPrompt;
                            return Icon(
                              isSpeakingThis
                                  ? Icons.stop_rounded
                                  : Icons.volume_up_rounded,
                              color: isSpeakingThis
                                  ? AppColors.primary
                                  : AppColors.muted,
                              size: AppSizes.iconMedium,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Selection radio / check indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.surface,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
