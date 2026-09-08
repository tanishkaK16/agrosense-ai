/// Supported voice command action types.
enum VoiceActionType {
  navigateHome,
  navigateFields,
  navigateAlerts,
  openSmsInfo,
  openAccount,
  triggerListen,
  whatToDo,
  statusWater,
  statusPest,
  statusHealth,
  help,
  unknown,
}

/// Parsed result of a farmer's spoken command.
class VoiceCommandResult {
  const VoiceCommandResult({
    required this.action,
    required this.rawTranscript,
    this.matchedKeyword,
  });

  final VoiceActionType action;
  final String rawTranscript;
  final String? matchedKeyword;

  @override
  String toString() =>
      'VoiceCommandResult(action: $action, keyword: $matchedKeyword, transcript: "$rawTranscript")';
}

/// Simple, robust keyword-based voice command parser supporting English, Hindi, and Marathi.
/// Designed for low-literacy farmer accessibility without complex NLP or network dependencies.
class VoiceCommandParser {
  const VoiceCommandParser._();

  /// Parse the farmer's raw speech transcript into a recognized [VoiceActionType].
  static VoiceCommandResult parse(String? transcript) {
    if (transcript == null || transcript.trim().isEmpty) {
      return const VoiceCommandResult(
        action: VoiceActionType.unknown,
        rawTranscript: '',
      );
    }

    final cleaned = _normalize(transcript);

    // 1. "What to do" / Advice queries (Check before general words)
    // English: "what to do", "what should i do", "action", "today"
    // Hindi: "क्या करें", "क्या करना है", "क्या करू"
    // Marathi: "काय करायचे", "काय करू", "काय करावं"
    if (_matchesAny(cleaned, [
      'what to do',
      'what should i do',
      'what do i do',
      'action today',
      'kya kare',
      'kya karna',
      'kya karu',
      'क्या करें',
      'क्या करना है',
      'क्या करू',
      'kay karayche',
      'kay karu',
      'kay karave',
      'काय करायचे',
      'काय करू',
      'काय करावं',
      'काय करावे',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.whatToDo,
        rawTranscript: transcript,
        matchedKeyword: 'what_to_do',
      );
    }

    // 2. Status: Water
    // English: "water", "irrigation", "moisture"
    // Hindi: "पानी", "जल", "नमी"
    // Marathi: "पाणी", "ओलावा"
    if (_matchesAny(cleaned, [
      'water',
      'irrigation',
      'moisture',
      'pani',
      'paani',
      'पानी',
      'जल',
      'नमी',
      'पाणी',
      'ओलावा',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.statusWater,
        rawTranscript: transcript,
        matchedKeyword: 'water',
      );
    }

    // 3. Status: Pest
    // English: "pest", "bug", "insect"
    // Hindi: "कीट", "कीड़ा", "कीड़े"
    // Marathi: "कीड", "किडे"
    if (_matchesAny(cleaned, [
      'pest',
      'bug',
      'insect',
      'keet',
      'keeda',
      'keede',
      'kid',
      'kide',
      'कीट',
      'कीड़ा',
      'कीड़े',
      'कीड',
      'किड',
      'किडे',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.statusPest,
        rawTranscript: transcript,
        matchedKeyword: 'pest',
      );
    }

    // 4. Status: Health
    // English: "health", "crop health", "condition"
    // Hindi: "सेहत", "स्वास्थ्य", "फसल"
    // Marathi: "आरोग्य", "तब्येत", "पीक"
    if (_matchesAny(cleaned, [
      'health',
      'condition',
      'sehat',
      'swasthya',
      'fasal',
      'सेहत',
      'स्वास्थ्य',
      'आरोग्य',
      'तब्येत',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.statusHealth,
        rawTranscript: transcript,
        matchedKeyword: 'health',
      );
    }

    // 5. SMS / Message Screen
    // English: "sms", "message"
    // Hindi: "एसएमएस", "संदेश", "मैसेज", "मेसेज"
    // Marathi: "एसएमएस", "संदेश", "मेसेज"
    if (_matchesAny(cleaned, [
      'sms',
      'message',
      'sandesh',
      'meseg',
      'संदेश',
      'मेसेज',
      'मैसेज',
      'एसएमएस',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.openSmsInfo,
        rawTranscript: transcript,
        matchedKeyword: 'sms',
      );
    }

    // 5b. Account / Profile Screen
    // English: "account", "profile"
    // Hindi: "खाता", "प्रोफाइल"
    // Marathi: "खाते", "प्रोफाइल"
    if (_matchesAny(cleaned, [
      'account',
      'profile',
      'khata',
      'khate',
      'खाता',
      'खाते',
      'प्रोफाइल',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.openAccount,
        rawTranscript: transcript,
        matchedKeyword: 'account',
      );
    }

    // 6. Navigate: Alerts
    // English: "alert", "alerts", "warning", "warnings", "notices"
    // Hindi: "चेतावनी", "सूचना", "अलर्ट"
    // Marathi: "इशारा", "इशारे", "सूचना"
    if (_matchesAny(cleaned, [
      'alert',
      'alerts',
      'warning',
      'warnings',
      'notice',
      'notices',
      'chetawani',
      'suchna',
      'ishara',
      'ishare',
      'चेतावनी',
      'सूचना',
      'अलर्ट',
      'इशारा',
      'इशारे',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.navigateAlerts,
        rawTranscript: transcript,
        matchedKeyword: 'alerts',
      );
    }

    // 6. Navigate: Fields
    // English: "field", "fields", "farm", "my fields"
    // Hindi: "खेत", "मेरे खेत", "फार्म"
    // Marathi: "शेत", "माझी शेते", "शेती"
    if (_matchesAny(cleaned, [
      'field',
      'fields',
      'my fields',
      'farm',
      'khet',
      'mere khet',
      'shet',
      'mazi shete',
      'खेत',
      'मेरे खेत',
      'शेत',
      'माझी शेते',
      'शेती',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.navigateFields,
        rawTranscript: transcript,
        matchedKeyword: 'fields',
      );
    }

    // 7. Navigate: Home
    // English: "home", "main", "dashboard", "back to home"
    // Hindi: "घर", "मुख्य", "होम", "होमपेज"
    // Marathi: "घर", "मुख्य", "होम"
    if (_matchesAny(cleaned, [
      'home',
      'main',
      'dashboard',
      'homepage',
      'ghar',
      'mukhya',
      'घर',
      'मुख्य',
      'होम',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.navigateHome,
        rawTranscript: transcript,
        matchedKeyword: 'home',
      );
    }

    // 8. Read: Listen / Speak screen
    // English: "listen", "read", "speak", "read screen", "speak aloud"
    // Hindi: "सुनो", "पढ़ो", "सुनाओ", "बोल"
    // Marathi: "ऐका", "वाचा", "सांगा"
    if (_matchesAny(cleaned, [
      'listen',
      'read',
      'speak',
      'tell me',
      'suno',
      'padho',
      'sunao',
      'bol',
      'सुनो',
      'पढ़ो',
      'सुनाओ',
      'बोल',
      'aika',
      'vacha',
      'sanga',
      'ऐका',
      'वाचा',
      'सांगा',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.triggerListen,
        rawTranscript: transcript,
        matchedKeyword: 'listen',
      );
    }

    // 9. Help
    // English: "help", "how to use", "options"
    // Hindi: "मदद", "सहायता"
    // Marathi: "मदत", "मदत करा"
    if (_matchesAny(cleaned, [
      'help',
      'options',
      'madad',
      'sahayata',
      'madat',
      'मदद',
      'सहायता',
      'मदत',
    ])) {
      return VoiceCommandResult(
        action: VoiceActionType.help,
        rawTranscript: transcript,
        matchedKeyword: 'help',
      );
    }

    return VoiceCommandResult(
      action: VoiceActionType.unknown,
      rawTranscript: transcript,
    );
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0900-\u097F]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _matchesAny(String text, List<String> targets) {
    final words = text.split(' ');
    for (final target in targets) {
      final normalizedTarget = target.toLowerCase().trim();
      if (text == normalizedTarget) return true;
      if (normalizedTarget.contains(' ')) {
        if (text.contains(normalizedTarget)) return true;
      } else {
        if (words.contains(normalizedTarget)) return true;
      }
    }
    return false;
  }
}
