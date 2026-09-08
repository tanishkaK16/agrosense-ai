import 'dart:convert';

import '../../home/models/home_snapshot.dart';

/// Represents a farmer's field.
class FarmField {
  const FarmField({
    required this.id,
    required this.name,
    required this.crop,
    required this.latitude,
    required this.longitude,
    required this.photoAsset,
    this.village,
    this.health = FieldHealth.healthy,
  });

  final String id;
  final String name;
  final String crop;
  final double latitude;
  final double longitude;
  final String photoAsset;
  final String? village;
  final FieldHealth? health;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'crop': crop,
        'latitude': latitude,
        'longitude': longitude,
        'photo_asset': photoAsset,
        'village': village,
        'health': health?.name,
      };

  factory FarmField.fromMap(Map<String, dynamic> map) {
    FieldHealth? parsedHealth;
    final healthString = map['health'] as String?;
    if (healthString != null) {
      for (final h in FieldHealth.values) {
        if (h.name == healthString) {
          parsedHealth = h;
          break;
        }
      }
    }

    return FarmField(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Main field',
      crop: map['crop'] as String? ?? 'wheat',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 18.5204,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 73.8567,
      photoAsset: map['photo_asset'] as String? ??
          'assets/images/hero_wheat_closeup.jpg',
      village: map['village'] as String?,
      health: parsedHealth ?? FieldHealth.healthy,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FarmField.fromJson(String source) =>
      FarmField.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Helper returning an authentic farm photo asset matching the crop.
String photoAssetForCrop(String? crop) {
  switch (crop?.toLowerCase()) {
    case 'wheat':
      return 'assets/images/hero_wheat_closeup.jpg';
    case 'rice':
      return 'assets/images/hero_field_sunrise.jpg';
    case 'cotton':
      return 'assets/images/hero_field_wide.jpg';
    case 'sugarcane':
      return 'assets/images/hero_canopy_green.jpg';
    case 'soybean':
      return 'assets/images/hero_field_wide.jpg';
    default:
      return 'assets/images/hero_canopy_green.jpg';
  }
}
