import '../models/home_snapshot.dart';

/// Contract for loading farmer home snapshot data.
abstract class HomeRepository {
  /// Fetch current snapshot, using [defaultCrop], [fieldName], and [fieldHealth] if available.
  Future<HomeSnapshot> getHomeSnapshot({
    String? defaultCrop,
    String? fieldName,
    FieldHealth? fieldHealth,
  });
}
