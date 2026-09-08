import '../models/home_snapshot.dart';

/// Centralized mapper between Home API JSON DTOs and [HomeSnapshot] domain models.
class HomeMapper {
  const HomeMapper._();

  static HomeSnapshot fromJson(
    Map<String, dynamic> json, {
    String? fallbackCrop,
    String? fallbackFieldName,
  }) {
    final healthStr = json['health'] as String? ?? 'good';
    FieldHealth health = FieldHealth.healthy;
    if (healthStr == 'watch') {
      health = FieldHealth.watch;
    } else if (healthStr == 'actNow') {
      health = FieldHealth.actNow;
    }

    final summary = json['summary_sentence'] as String? ??
        json['summary_key'] as String? ??
        (health == FieldHealth.healthy
            ? 'Looking healthy today.'
            : (health == FieldHealth.watch
                ? 'Check water and pests.'
                : 'Needs immediate attention.'));

    return HomeSnapshot(
      temperatureC: (json['temperature_c'] as num?)?.round() ?? 32,
      rainMm: (json['rain_mm'] as num?)?.round() ?? 0,
      windKmh: (json['wind_kmh'] as num?)?.round() ?? 12,
      fieldName: json['field_name'] as String? ?? fallbackFieldName ?? 'Main field',
      crop: json['crop'] as String? ?? fallbackCrop ?? 'wheat',
      health: health,
      summarySentence: summary,
      alertCount: (json['alert_count'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> toJson(HomeSnapshot snapshot) {
    String healthStr = 'good';
    if (snapshot.health == FieldHealth.watch) {
      healthStr = 'watch';
    } else if (snapshot.health == FieldHealth.actNow) {
      healthStr = 'actNow';
    }

    return {
      'temperature_c': snapshot.temperatureC,
      'rain_mm': snapshot.rainMm,
      'wind_kmh': snapshot.windKmh,
      'field_name': snapshot.fieldName,
      'crop': snapshot.crop,
      'health': healthStr,
      'summary_sentence': snapshot.summarySentence,
      'alert_count': snapshot.alertCount,
    };
  }
}
