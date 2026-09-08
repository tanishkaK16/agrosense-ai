import '../models/farmer_profile.dart';
import '../models/farmer_session.dart';

/// Centralized mapper between Auth/Profile JSON DTOs and domain models.
class AuthMapper {
  const AuthMapper._();

  static FarmerSession sessionFromVerifyJson(
    Map<String, dynamic> json, {
    required String phoneNumber,
  }) {
    final token = json['token'] as String? ?? '';
    return FarmerSession(
      phoneNumber: phoneNumber,
      token: token,
      createdAt: DateTime.now(),
    );
  }

  static FarmerProfile profileFromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      name: json['name'] as String? ?? '',
      village: json['village'] as String? ?? '',
      mainCrop: json['crop'] as String? ?? 'wheat',
    );
  }

  static Map<String, dynamic> profileToJson(FarmerProfile profile) {
    return {
      'name': profile.name,
      'village': profile.village,
      'crop': profile.mainCrop,
    };
  }
}
