import '../models/farmer_profile.dart';
import '../models/farmer_session.dart';

/// Contract for farmer authentication and profile persistence.
///
/// Designed so MockAuthRepository can later be replaced with an API repository.
abstract class AuthRepository {
  /// Request an OTP to be sent to [phone].
  Future<bool> requestOtp(String phone);

  /// Verify [code] against [phone]. Returns [FarmerSession] on success, null on failure.
  Future<FarmerSession?> verifyOtp(String phone, String code);

  /// Persist the farmer's profile.
  Future<void> saveProfile(FarmerProfile profile);

  /// Get the current active session if any.
  FarmerSession? currentSession();

  /// Get the current saved profile if any.
  FarmerProfile? currentProfile();

  /// Whether a farmer is currently signed in.
  bool get isLoggedIn;
}
