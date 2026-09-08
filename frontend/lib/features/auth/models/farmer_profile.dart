import 'dart:convert';

/// Represents farmer profile information collected during onboarding.
class FarmerProfile {
  const FarmerProfile({
    required this.name,
    required this.village,
    required this.mainCrop,
    this.smsOptIn = true,
  });

  final String name;
  final String village;
  final String mainCrop;
  final bool smsOptIn;

  /// Profile is complete once the main crop is selected.
  bool get isComplete => mainCrop.trim().isNotEmpty;

  FarmerProfile copyWith({
    String? name,
    String? village,
    String? mainCrop,
    bool? smsOptIn,
  }) =>
      FarmerProfile(
        name: name ?? this.name,
        village: village ?? this.village,
        mainCrop: mainCrop ?? this.mainCrop,
        smsOptIn: smsOptIn ?? this.smsOptIn,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'village': village,
        'main_crop': mainCrop,
        'sms_opt_in': smsOptIn,
      };

  factory FarmerProfile.fromMap(Map<String, dynamic> map) => FarmerProfile(
        name: map['name'] as String? ?? 'Farmer',
        village: map['village'] as String? ?? '',
        mainCrop: map['main_crop'] as String? ?? '',
        smsOptIn: map['sms_opt_in'] as bool? ?? true,
      );

  String toJson() => jsonEncode(toMap());

  factory FarmerProfile.fromJson(String source) =>
      FarmerProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
