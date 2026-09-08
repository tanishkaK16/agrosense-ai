import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/theme/text_scale_controller.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/core/widgets/text_size_sheet.dart';
import 'package:agrosense_ai/generated/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall methodCall) async {
      return 1;
    });

    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    await TextScaleController.instance.init();
  });

  tearDown(() async {
    await AppPrefs.instance.clear();
    await TextScaleController.instance.clear();
    await VoiceService.instance.stop();
  });

  group('Phase 10: TextScaleController & Persistence', () {
    test('Defaults to standard scale (1.0)', () {
      expect(TextScaleController.instance.currentScale, equals(AppTextScale.standard));
      expect(TextScaleController.instance.factor, equals(1.0));
    });

    test('setScale to small persists "small" and updates controller', () async {
      await TextScaleController.instance.setScale(AppTextScale.small);

      expect(TextScaleController.instance.currentScale, equals(AppTextScale.small));
      expect(TextScaleController.instance.factor, equals(0.9));
      expect(AppPrefs.instance.textScale, equals('small'));
    });

    test('setScale to large persists "large" and updates controller', () async {
      await TextScaleController.instance.setScale(AppTextScale.large);

      expect(TextScaleController.instance.currentScale, equals(AppTextScale.large));
      expect(TextScaleController.instance.factor, equals(1.25));
      expect(AppPrefs.instance.textScale, equals('large'));
    });

    test('TextScaler clamps excessive system scales to max 1.4', () {
      // With standard app scale (1.0), system scale 1.5 should be clamped to 1.4
      final clampedStandard = TextScaleController.instance.effectiveScale(1.5);
      expect(clampedStandard, equals(1.4));

      // With large app scale (1.25), system scale 1.2 should be 1.5 -> clamped to 1.4
      TextScaleController.instance.setScale(AppTextScale.large);
      final clampedLarge = TextScaleController.instance.effectiveScale(1.2);
      expect(clampedLarge, equals(1.4));
    });

    test('TextScaler clamps very small system scales to min 0.85', () {
      // With small scale (0.9), system scale 0.8 would be 0.72 -> clamped to 0.85
      TextScaleController.instance.setScale(AppTextScale.small);
      final clampedSmall = TextScaleController.instance.effectiveScale(0.8);
      expect(clampedSmall, equals(0.85));
    });

    test('FromFactor correctly resolves AppTextScale enum', () {
      expect(AppTextScale.fromFactor(0.9), equals(AppTextScale.small));
      expect(AppTextScale.fromFactor(1.0), equals(AppTextScale.standard));
      expect(AppTextScale.fromFactor(1.25), equals(AppTextScale.large));
      expect(AppTextScale.fromFactor(null), equals(AppTextScale.standard));
      expect(AppTextScale.fromFactor(2.0), equals(AppTextScale.standard));
    });
  });

  group('Phase 10: TextSizeSheet Widget Test', () {
    testWidgets('Renders all three text size options and selects one', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TextSizeSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and all 3 options exist
      expect(find.text('Text size'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      // Tap on Large option
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();

      // Check that controller and prefs updated
      expect(TextScaleController.instance.currentScale, equals(AppTextScale.large));
      expect(AppPrefs.instance.textScale, equals('large'));
    });
  });
}
