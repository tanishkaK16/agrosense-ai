import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/mic_button.dart';
import 'package:agrosense_ai/core/voice/voice_command_parser.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/alerts/alerts_screen.dart';
import 'package:agrosense_ai/features/alerts/data/mock_alerts_repository.dart';
import 'package:agrosense_ai/features/fields/data/local_fields_repository.dart';
import 'package:agrosense_ai/features/fields/fields_screen.dart';
import 'package:agrosense_ai/features/home/home_screen.dart';
import 'package:agrosense_ai/generated/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  const MethodChannel sttChannel = MethodChannel('plugin.csd.com/speech_to_text');

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall methodCall) async {
      return 1;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sttChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'initialize') return true;
      if (methodCall.method == 'listen') return true;
      if (methodCall.method == 'stop') return true;
      if (methodCall.method == 'cancel') return true;
      if (methodCall.method == 'locales') return <String>['en_IN', 'hi_IN', 'mr_IN'];
      return null;
    });

    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    await LocaleController.instance.init();
    await LocalFieldsRepository.instance.clear();
    await MockAlertsRepository.instance.clear();
  });

  tearDown(() async {
    await AppPrefs.instance.clear();
    await LocaleController.instance.clear();
    await LocalFieldsRepository.instance.clear();
    await MockAlertsRepository.instance.clear();
    await VoiceService.instance.stop();
  });

  group('VoiceCommandParser English Tests', () {
    test('Parses English navigation commands', () {
      expect(
        VoiceCommandParser.parse('go to home').action,
        equals(VoiceActionType.navigateHome),
      );
      expect(
        VoiceCommandParser.parse('show my fields').action,
        equals(VoiceActionType.navigateFields),
      );
      expect(
        VoiceCommandParser.parse('check alerts').action,
        equals(VoiceActionType.navigateAlerts),
      );
    });

    test('Parses English action and read commands', () {
      expect(
        VoiceCommandParser.parse('what to do today').action,
        equals(VoiceActionType.whatToDo),
      );
      expect(
        VoiceCommandParser.parse('listen to this screen').action,
        equals(VoiceActionType.triggerListen),
      );
    });

    test('Parses English telemetry status queries', () {
      expect(
        VoiceCommandParser.parse('how is the water').action,
        equals(VoiceActionType.statusWater),
      );
      expect(
        VoiceCommandParser.parse('pest check').action,
        equals(VoiceActionType.statusPest),
      );
      expect(
        VoiceCommandParser.parse('crop health condition').action,
        equals(VoiceActionType.statusHealth),
      );
    });

    test('Parses English help and unknown phrases', () {
      expect(
        VoiceCommandParser.parse('help please').action,
        equals(VoiceActionType.help),
      );
      expect(
        VoiceCommandParser.parse('buy new tractor').action,
        equals(VoiceActionType.unknown),
      );
      expect(
        VoiceCommandParser.parse('').action,
        equals(VoiceActionType.unknown),
      );
    });
  });

  group('VoiceCommandParser Hindi Tests', () {
    test('Parses Hindi navigation keywords', () {
      expect(
        VoiceCommandParser.parse('घर जाओ').action,
        equals(VoiceActionType.navigateHome),
      );
      expect(
        VoiceCommandParser.parse('मुख्य पृष्ठ').action,
        equals(VoiceActionType.navigateHome),
      );
      expect(
        VoiceCommandParser.parse('मेरे खेत दिखाओ').action,
        equals(VoiceActionType.navigateFields),
      );
      expect(
        VoiceCommandParser.parse('चेतावनी क्या है').action,
        equals(VoiceActionType.navigateAlerts),
      );
    });

    test('Parses Hindi advice and read commands', () {
      expect(
        VoiceCommandParser.parse('आज क्या करें').action,
        equals(VoiceActionType.whatToDo),
      );
      expect(
        VoiceCommandParser.parse('सुनो').action,
        equals(VoiceActionType.triggerListen),
      );
    });

    test('Parses Hindi telemetry status queries', () {
      expect(
        VoiceCommandParser.parse('पानी की स्थिति').action,
        equals(VoiceActionType.statusWater),
      );
      expect(
        VoiceCommandParser.parse('कीट का खतरा').action,
        equals(VoiceActionType.statusPest),
      );
      expect(
        VoiceCommandParser.parse('फसल की सेहत').action,
        equals(VoiceActionType.statusHealth),
      );
      expect(
        VoiceCommandParser.parse('मदद चाहिए').action,
        equals(VoiceActionType.help),
      );
    });
  });

  group('VoiceCommandParser Marathi Tests', () {
    test('Parses Marathi navigation keywords', () {
      expect(
        VoiceCommandParser.parse('घर').action,
        equals(VoiceActionType.navigateHome),
      );
      expect(
        VoiceCommandParser.parse('माझी शेते दाखवा').action,
        equals(VoiceActionType.navigateFields),
      );
      expect(
        VoiceCommandParser.parse('इशारा काय आहे').action,
        equals(VoiceActionType.navigateAlerts),
      );
    });

    test('Parses Marathi advice and read commands', () {
      expect(
        VoiceCommandParser.parse('आज काय करायचे').action,
        equals(VoiceActionType.whatToDo),
      );
      expect(
        VoiceCommandParser.parse('ऐका').action,
        equals(VoiceActionType.triggerListen),
      );
    });

    test('Parses Marathi status queries and help', () {
      expect(
        VoiceCommandParser.parse('पाणी किती आहे').action,
        equals(VoiceActionType.statusWater),
      );
      expect(
        VoiceCommandParser.parse('कीड लागली आहे का').action,
        equals(VoiceActionType.statusPest),
      );
      expect(
        VoiceCommandParser.parse('पिकाचे आरोग्य').action,
        equals(VoiceActionType.statusHealth),
      );
      expect(
        VoiceCommandParser.parse('मदत करा').action,
        equals(VoiceActionType.help),
      );
    });
  });

  group('MicButton UI Widget Tests', () {
    testWidgets('MicButton renders with 64x64 tap target on Home, Fields, and Alerts',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Home Screen has MicButton
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MicButton), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

      // 2. Fields Screen has MicButton
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FieldsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MicButton), findsOneWidget);

      // 3. Alerts Screen has MicButton
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AlertsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MicButton), findsOneWidget);
    });
  });
}
