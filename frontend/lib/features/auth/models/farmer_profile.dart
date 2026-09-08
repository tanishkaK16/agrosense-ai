import 'dart:convert';

/// Represents farmer profile information collected during onboarding.
class FarmerProfile {
  const FarmerProfile({
    required this.name,
    required this.village,
    required this.mainCrop,
  });

  final String name;
  final String village;
  final String mainCrop;

  /// Profile is complete once the main crop is selected.
  bool get isComplete => mainCrop.trim().isNotEmpty;

  Map<String, dynamic> toMap() => {
        'name': name,
        'village': village,
        'main_crop': mainCrop,
      };

  factory FarmerProfile.fromMap(Map<String, dynamic> map) => FarmerProfile(
        name: map['name'] as String? ?? 'Farmer',
        village: map['village'] as String? ?? '',
        mainCrop: map['main_crop'] as String? ?? '',
      );

  String toJson() => jsonEncode(toMap());

  factory FarmerProfile.fromJson(String source) =>
      FarmerProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
