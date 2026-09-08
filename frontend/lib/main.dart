import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/l10n/locale_controller.dart';
import 'core/storage/app_prefs.dart';
import 'core/theme/text_scale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — farmer app is portrait-first
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status and navigation bars so photos bleed to edges
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load persisted preferences, locale, and text scale before first frame
  await AppPrefs.instance.init();
  await LocaleController.instance.init();
  await TextScaleController.instance.init();

  runApp(const AgroSenseApp());
}
