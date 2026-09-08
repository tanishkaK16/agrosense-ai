import 'package:go_router/go_router.dart';

import '../../core/l10n/locale_controller.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/fields/fields_screen.dart';
import '../../features/alerts/alerts_screen.dart';

// Route path constants — use these everywhere, never hard-code strings.
abstract final class AppRoutes {
  static const String language = '/language';
  static const String home = '/';
  static const String fields = '/fields';
  static const String alerts = '/alerts';
}

/// Application router.
///
/// Redirect logic:
///   - If [LocaleController] has no saved locale → /language
///   - Otherwise → / (home inside MainShell)
GoRouter buildRouter() {
  final localeController = LocaleController.instance;

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: localeController,
    redirect: (context, state) {
      // Wait until controller is initialised from SharedPreferences.
      if (!localeController.initialized) return null;

      final onLanguageScreen = state.matchedLocation == AppRoutes.language;

      if (!localeController.hasLocale && !onLanguageScreen) {
        return AppRoutes.language;
      }
      if (localeController.hasLocale && onLanguageScreen) {
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
