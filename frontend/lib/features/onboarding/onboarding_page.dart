import '../../generated/l10n/app_localizations.dart';

/// Data model representing a single picture-first onboarding step.
class OnboardingPageData {
  const OnboardingPageData({
    required this.imagePath,
    required this.getTitle,
    required this.getBody,
    required this.getButtonLabel,
    required this.canSkip,
  });

  /// Path to a high-resolution farm photograph in assets.
  final String imagePath;

  /// Localized title string accessor.
  final String Function(AppLocalizations l10n) getTitle;

  /// Localized body string accessor.
  final String Function(AppLocalizations l10n) getBody;

  /// Localized CTA button text ('Next' or 'Start').
  final String Function(AppLocalizations l10n) getButtonLabel;

  /// Whether the user can skip this step (false on screen 1, true on screens 2 and 3).
  final bool canSkip;
}

/// The three picture-first onboarding steps.
final List<OnboardingPageData> kOnboardingPages = [
  // Screen 1 — See the field
  OnboardingPageData(
    imagePath: 'assets/images/hero_field_wide.jpg',
    getTitle: (l10n) => l10n.onboarding1Title,
    getBody: (l10n) => l10n.onboarding1Body,
    getButtonLabel: (l10n) => l10n.next,
    canSkip: false,
  ),
  // Screen 2 — Warning early
  OnboardingPageData(
    imagePath: 'assets/images/hero_canopy_green.jpg',
    getTitle: (l10n) => l10n.onboarding2Title,
    getBody: (l10n) => l10n.onboarding2Body,
    getButtonLabel: (l10n) => l10n.next,
    canSkip: true,
  ),
  // Screen 3 — One action
  OnboardingPageData(
    imagePath: 'assets/images/hero_soil_hands.jpg',
    getTitle: (l10n) => l10n.onboarding3Title,
    getBody: (l10n) => l10n.onboarding3Body,
    getButtonLabel: (l10n) => l10n.start,
    canSkip: true,
  ),
];
