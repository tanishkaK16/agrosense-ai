import 'dart:convert';

/// Status level for crop health meter.
enum HealthLevel {
  good,
  watch,
  actNow,
}

/// Status level for soil / crop water meter.
enum WaterLevel {
  good,
  low,
  actNow,
}

/// Status level for pest risk meter.
enum PestLevel {
  good,
  watch,
  actNow,
}

/// Indicates which sector or corner of the field photo receives a soft visual wash.
enum OverlayHint {
  none,
  left,
  right,
  far,
}

/// Status and telemetry summary for a single farmer field.
class FieldStatus {
  const FieldStatus({
    required this.fieldId,
    required this.health,
    required this.water,
    required this.pest,
    required this.overlayHint,
    this.summarySentence,
  });

  final String fieldId;
  final HealthLevel health;
  final WaterLevel water;
  final PestLevel pest;
  final OverlayHint overlayHint;
  final String? summarySentence;

  Map<String, dynamic> toMap() => {
        'field_id': fieldId,
        'health': health.name,
        'water': water.name,
        'pest': pest.name,
        'overlay_hint': overlayHint.name,
        'summary_sentence': summarySentence,
      };

  factory FieldStatus.fromMap(Map<String, dynamic> map) {
    return FieldStatus(
      fieldId: map['field_id'] as String? ?? '',
      health: _parseEnum(HealthLevel.values, map['health'], HealthLevel.good),
      water: _parseEnum(WaterLevel.values, map['water'], WaterLevel.good),
      pest: _parseEnum(PestLevel.values, map['pest'], PestLevel.good),
      overlayHint: _parseEnum(
        OverlayHint.values,
        map['overlay_hint'],
        OverlayHint.none,
      ),
      summarySentence: map['summary_sentence'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FieldStatus.fromJson(String source) =>
      FieldStatus.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static T _parseEnum<T extends Enum>(
    List<T> values,
    dynamic value,
    T fallback,
  ) {
    if (value is String) {
      for (final v in values) {
        if (v.name == value) return v;
      }
    }
    return fallback;
  }
}
