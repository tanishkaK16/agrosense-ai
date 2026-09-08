import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/storage/app_prefs.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/fields/fields_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';

// Route path constants — use these everywhere, never hard-code strings.
abstract final class AppRoutes {
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String fields = '/fields';
  static const String alerts = '/alerts';
}

/// Application router.
///
/// Flow:
///   - If no locale saved: /language
///   - If locale saved but onboarding incomplete: /onboarding
///   - If both done: / (home inside MainShell)
GoRouter buildRouter() {
  final localeController = LocaleController.instance;
  final appPrefs = AppPrefs.instance;

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: Listenable.merge([localeController, appPrefs]),
    redirect: (context, state) {
      if (!localeController.initialized || !appPrefs.isInitialized) {
        return null;
      }

      final hasLocale = localeController.hasLocale;
      final onboardingDone = appPrefs.isOnboardingDone;
      final loc = state.matchedLocation;

      final onLanguage = loc == AppRoutes.language;
      final onOnboarding = loc == AppRoutes.onboarding;

      // 1. If no locale saved: language screen first
      if (!hasLocale) {
        return onLanguage ? null : AppRoutes.language;
      }

      // 2. If locale saved but onboarding not finished: /onboarding
      if (!onboardingDone) {
        return onOnboarding ? null : AppRoutes.onboarding;
      }

      // 3. Both done: MainShell Home (redirect away from onboarding / language)
      if (onLanguage || onOnboarding) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.language,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LanguageScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.fields,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FieldsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.alerts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlertsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
