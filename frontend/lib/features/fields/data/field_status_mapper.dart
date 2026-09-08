import '../models/field_status.dart';

/// Centralized mapper between Field Status API JSON DTOs and [FieldStatus] domain models.
class FieldStatusMapper {
  const FieldStatusMapper._();

  static FieldStatus fromJson(Map<String, dynamic> json, {required String fieldId}) {
    final healthStr = json['health'] as String? ?? 'good';
    final waterStr = json['water'] as String? ?? 'good';
    final pestStr = json['pest'] as String? ?? 'good';
    final overlayStr = json['overlay_hint'] as String? ?? 'none';
    final summary = json['summary_sentence'] as String? ?? json['summary_key'] as String?;

    final health = HealthLevel.values.firstWhere(
      (h) => h.name == healthStr,
      orElse: () => HealthLevel.good,
    );

    final water = WaterLevel.values.firstWhere(
      (w) => w.name == waterStr,
      orElse: () => WaterLevel.good,
    );

    final pest = PestLevel.values.firstWhere(
      (p) => p.name == pestStr,
      orElse: () => PestLevel.good,
    );

    final overlay = OverlayHint.values.firstWhere(
      (o) => o.name == overlayStr,
      orElse: () => OverlayHint.none,
    );

    return FieldStatus(
      fieldId: fieldId,
      health: health,
      water: water,
      pest: pest,
      overlayHint: overlay,
      summarySentence: summary,
    );
  }

  static Map<String, dynamic> toJson(FieldStatus status) {
    return {
      'field_id': status.fieldId,
      'health': status.health.name,
      'water': status.water.name,
      'pest': status.pest.name,
      'overlay_hint': status.overlayHint.name,
      'summary_sentence': status.summarySentence,
    };
  }
}
