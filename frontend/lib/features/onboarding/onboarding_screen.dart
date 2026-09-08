import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/voice/voice_service.dart';
import '../../core/widgets/farm_photo_header.dart';
import '../../core/widgets/listen_button.dart';
import '../../core/widgets/primary_pill_button.dart';
import '../../generated/l10n/app_localizations.dart';
import 'onboarding_page.dart';

/// Picture-first 3-step farmer onboarding screen.
///
/// Features:
/// - Full-bleed real farm photography with warm scrim
/// - Farmer-plain language (zero jargon)
/// - Step dots (1 of 3)
/// - High-contrast Listen button in top right corner (reads title + body)
/// - 64px tap targets
/// - No skip on screen 1; Skip on screens 2 & 3
/// - Start & Skip both complete onboarding and navigate to Home
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    VoiceService.instance.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    VoiceService.instance.stop();
    setState(() => _currentPage = index);
  }

  Future<void> _completeOnboarding() async {
    await VoiceService.instance.stop();
    await AppPrefs.instance.setOnboardingDone(true);
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _onNext() {
    if (_currentPage < kOnboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final page = kOnboardingPages[_currentPage];
    final title = page.getTitle(l10n);
    final body = page.getBody(l10n);
    final speechText = '$title. $body';

    // Status bar transparent to let photos bleed
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Paged photo & content ─────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: kOnboardingPages.length,
            itemBuilder: (context, index) {
              final item = kOnboardingPages[index];
              final itemTitle = item.getTitle(l10n);
              final itemBody = item.getBody(l10n);

              return Column(
                children: [
                  // Real farm photo with scrim
                  FarmPhotoHeader(
                    imagePath: item.imagePath,
                    height: screenHeight * 0.52,
                  ),

                  // Content container
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.paddingL,
                        AppSizes.paddingL,
                        AppSizes.paddingL,
                        AppSizes.paddingM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          // Title
                          Text(
                            itemTitle,
                            style: AppTextStyles.screenTitle(context).copyWith(
                              fontSize: 26,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),

                          // Plain body text
                          Text(
                            itemBody,
                            style: AppTextStyles.body(context).copyWith(
                              fontSize: 16,
                              color: AppColors.muted,
                              height: 1.45,
                            ),
                          ),

                          const Spacer(flex: 2),

                          // Step dots
                          Row(
                            children: List.generate(
                              kOnboardingPages.length,
                              (dotIndex) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(right: 8),
                                width: dotIndex == _currentPage ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: dotIndex == _currentPage
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSizes.paddingL),

                          // Big primary pill button
                          PrimaryPillButton(
                            label: item.getButtonLabel(l10n),
                            onPressed: _onNext,
                            icon: index == kOnboardingPages.length - 1
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                          ),

                          // Large Skip button (only for screens 2 & 3)
                          if (item.canSkip)
                            Center(
                              child: SizedBox(
                                height: 48,
                                child: TextButton(
                                  onPressed: _completeOnboarding,
                                  child: Text(
                                    l10n.skip,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 48),

                          const SizedBox(height: AppSizes.paddingS),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Top header bar (App mark & Listen control) ────────────────────
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: AppSizes.paddingL,
            right: AppSizes.paddingL,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leaf mark and app title
                Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.onPhoto,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPhoto,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                // Working Listen button in consistent top-right corner
                ListenButton(
                  onPhoto: true,
                  text: speechText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
