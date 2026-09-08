import '../../home/models/home_snapshot.dart';
import '../models/farm_field.dart';

/// Centralized mapper between Fields API JSON DTOs and [FarmField] domain models.
class FieldsMapper {
  const FieldsMapper._();

  static FarmField fromJson(Map<String, dynamic> json) {
    final healthStr = json['health'] as String?;
    FieldHealth health = FieldHealth.healthy;
    if (healthStr == 'watch') {
      health = FieldHealth.watch;
    } else if (healthStr == 'actNow') {
      health = FieldHealth.actNow;
    } else if (healthStr == 'good' || healthStr == 'healthy') {
      health = FieldHealth.healthy;
    }

    final crop = json['crop'] as String? ?? 'wheat';
    final photo = json['photo_asset'] as String? ??
        photoAssetForCrop(crop);

    return FarmField(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Main field',
      crop: crop,
      latitude: (json['lat'] as num?)?.toDouble() ??
          (json['latitude'] as num?)?.toDouble() ??
          18.5204,
      longitude: (json['lng'] as num?)?.toDouble() ??
          (json['longitude'] as num?)?.toDouble() ??
          73.8567,
      photoAsset: photo,
      village: json['village'] as String?,
      health: health,
    );
  }

  static Map<String, dynamic> toJson(FarmField field) {
    String healthStr = 'good';
    if (field.health == FieldHealth.watch) {
      healthStr = 'watch';
    } else if (field.health == FieldHealth.actNow) {
      healthStr = 'actNow';
    }

    return {
      'id': field.id,
      'name': field.name,
      'crop': field.crop,
      'lat': field.latitude,
      'lng': field.longitude,
      'village': field.village,
      'health': healthStr,
    };
  }

  static Map<String, dynamic> toCreatePayload(FarmField field) {
    return {
      'name': field.name,
      'crop': field.crop,
      'lat': field.latitude,
      'lng': field.longitude,
    };
  }
}
