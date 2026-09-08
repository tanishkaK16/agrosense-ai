import '../../../core/network/api_client.dart';
import '../../../core/storage/app_prefs.dart';
import '../models/farmer_profile.dart';
import '../models/farmer_session.dart';
import 'auth_mapper.dart';
import 'auth_repository.dart';

/// Live HTTP implementation of [AuthRepository] talking to Django.
class LiveAuthRepository implements AuthRepository {
  LiveAuthRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<bool> requestOtp(String phone) async {
    await _apiClient.post(
      '/auth/otp/request',
      body: {'phone': phone.trim()},
    );
    return true;
  }

  @override
  Future<FarmerSession?> verifyOtp(String phone, String code) async {
    final res = await _apiClient.post(
      '/auth/otp/verify',
      body: {
        'phone': phone.trim(),
        'code': code.trim(),
      },
    );

    if (res is Map<String, dynamic>) {
      final session = AuthMapper.sessionFromVerifyJson(res, phoneNumber: phone.trim());
      await AppPrefs.instance.setSessionJson(session.toJson());
      return session;
    }
    return null;
  }

  @override
  Future<void> saveProfile(FarmerProfile profile) async {
    await _apiClient.put(
      '/me',
      body: AuthMapper.profileToJson(profile),
    );
    await AppPrefs.instance.setProfileJson(profile.toJson());
  }

  @override
  FarmerSession? currentSession() {
    final raw = AppPrefs.instance.sessionJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      return FarmerSession.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  FarmerProfile? currentProfile() {
    final raw = AppPrefs.instance.profileJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      return FarmerProfile.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  bool get isLoggedIn => currentSession() != null;
}
