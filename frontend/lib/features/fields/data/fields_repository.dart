import '../models/farm_field.dart';

/// Repository interface for managing a farmer's fields.
abstract class FieldsRepository {
  /// Returns the list of fields for the current farmer.
  Future<List<FarmField>> getFields();

  /// Saves or updates a field.
  Future<void> saveField(FarmField field);

  /// Deletes a field by [id].
  Future<void> deleteField(String id);
}
