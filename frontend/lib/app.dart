import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/locale_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/text_scale_controller.dart';
import 'generated/l10n/app_localizations.dart';

/// Root application widget.
///
/// Listens to [LocaleController] and [TextScaleController] so:
///   - Language changes take effect immediately across all screens
///   - Text scale preference changes take effect immediately with clamped scaling
///   - The router refreshes and redirects when a new locale is saved
class AgroSenseApp extends StatefulWidget {
  const AgroSenseApp({super.key});

  @override
  State<AgroSenseApp> createState() => _AgroSenseAppState();
}

class _AgroSenseAppState extends State<AgroSenseApp> {
  late final _router = buildRouter();

  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onPreferenceChange);
    TextScaleController.instance.addListener(_onPreferenceChange);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onPreferenceChange);
    TextScaleController.instance.removeListener(_onPreferenceChange);
    super.dispose();
  }

  void _onPreferenceChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleController.instance.locale;

    return MaterialApp.router(
      title: 'AgroSense',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),

      // Builder applying clamped text scaler (honoring system scale up to 1.4)
      builder: (context, child) {
        final textScaler = TextScaleController.instance.textScaler(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      // Active locale (null = system default while on language screen)
      locale: locale,

      // Supported locales
      supportedLocales: AppLocalizations.supportedLocales,

      // Delegate chain — generated l10n first, then Material / Cupertino / Widgets
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // go_router
      routerConfig: _router,
    );
  }
}
