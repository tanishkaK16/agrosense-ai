import '../models/home_snapshot.dart';

/// Contract for loading farmer home snapshot data.
abstract class HomeRepository {
  /// Fetch current snapshot, using [defaultCrop] if available from farmer profile.
  Future<HomeSnapshot> getHomeSnapshot({String? defaultCrop});
}
