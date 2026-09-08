import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../core/storage/app_prefs.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/phone_screen.dart';
import '../../features/auth/profile_screen.dart';
import '../../features/fields/add_field_screen.dart';
import '../../features/fields/fields_screen.dart';
import '../../features/fields/pin_field_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';

// Route path constants — use these everywhere, never hard-code strings.
abstract final class AppRoutes {
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String profile = '/profile';
  static const String home = '/';
  static const String fields = '/fields';
  static const String fieldsAdd = '/fields/add';
  static const String fieldsPin = '/fields/pin';
  static const String alerts = '/alerts';
}

/// Application router.
///
/// Flow:
///   - If no locale saved: /language
///   - If locale saved but onboarding incomplete: /onboarding
///   - If not signed in: /phone
///   - If signed in but profile incomplete: /profile
///   - If all done: / (home inside MainShell)
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
      final hasSession = appPrefs.hasSession;
      final hasProfile = appPrefs.hasProfile;
      final loc = state.matchedLocation;

      final onLanguage = loc == AppRoutes.language;
      final onOnboarding = loc == AppRoutes.onboarding;
      final onPhone = loc == AppRoutes.phone;
      final onOtp = loc == AppRoutes.otp;
      final onProfile = loc == AppRoutes.profile;

      // 1. If no locale saved: language screen first
      if (!hasLocale) {
        return onLanguage ? null : AppRoutes.language;
      }

      // 2. If locale saved but onboarding not finished: /onboarding
      if (!onboardingDone) {
        return onOnboarding ? null : AppRoutes.onboarding;
      }

      // 3. If not signed in: /phone (or /otp while entering verification code)
      if (!hasSession) {
        return (onPhone || onOtp) ? null : AppRoutes.phone;
      }

      // 4. If signed in but profile incomplete: /profile
      if (!hasProfile) {
        return onProfile ? null : AppRoutes.profile;
      }

      // 5. All done: MainShell Home (redirect away from onboarding/auth/language)
      if (onLanguage || onOnboarding || onPhone || onOtp || onProfile) {
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
      GoRoute(
        path: AppRoutes.phone,
        pageBuilder: (context, state) => NoTransitionPage(
          child: PhoneScreen(
            initialPhone: state.extra as String?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (context, state) => NoTransitionPage(
          child: OtpScreen(
            phoneNumber: state.extra as String? ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfileScreen(),
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
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return NoTransitionPage(
                    child: AddFieldScreen(
                      initialName: extra?['name'] as String?,
                      initialCrop: extra?['crop'] as String?,
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'pin',
                pageBuilder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return NoTransitionPage(
                    child: PinFieldScreen(
                      draftName: extra?['name'] as String?,
                      draftCrop: extra?['crop'] as String?,
                    ),
                  );
                },
              ),
            ],
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
