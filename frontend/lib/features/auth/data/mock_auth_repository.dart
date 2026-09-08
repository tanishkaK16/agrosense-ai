import 'dart:math';

import '../../../core/storage/app_prefs.dart';
import '../models/farmer_profile.dart';
import '../models/farmer_session.dart';
import 'auth_repository.dart';

/// Flag to control showing demo OTP hint in UI.
/// Set to false when ready for real SMS/backend deployment.
const bool kShowDemoOtp = true;

/// Mock implementation of [AuthRepository] for development and testing.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository._();

  static final MockAuthRepository instance = MockAuthRepository._();

  static const String demoOtpCode = '1234';

  @override
  Future<bool> requestOtp(String phone) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<FarmerSession?> verifyOtp(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (code.trim() == demoOtpCode) {
      final token = 'mock_token_${Random().nextInt(999999)}';
      final session = FarmerSession(
        phoneNumber: phone.trim(),
        token: token,
        createdAt: DateTime.now(),
      );
      await AppPrefs.instance.setSessionJson(session.toJson());
      return session;
    }
    return null;
  }

  @override
  Future<void> saveProfile(FarmerProfile profile) async {
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
  bool get isLoggedIn => AppPrefs.instance.hasSession;
}
