import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/farm_field.dart';
import 'fields_repository.dart';

/// Local device persistence for [FarmField] items via [SharedPreferences].
class LocalFieldsRepository extends ChangeNotifier implements FieldsRepository {
  LocalFieldsRepository._();

  static final LocalFieldsRepository instance = LocalFieldsRepository._();

  static const String keyFields = 'saved_farm_fields';

  @override
  Future<List<FarmField>> getFields() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyFields);
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => FarmField.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveField(FarmField field) async {
    final fields = (await getFields()).toList();
    final index = fields.indexWhere((f) => f.id == field.id);
    if (index >= 0) {
      fields[index] = field;
    } else {
      fields.add(field);
    }

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(fields.map((f) => f.toMap()).toList());
    await prefs.setString(keyFields, encoded);
    notifyListeners();
  }

  @override
  Future<void> deleteField(String id) async {
    final fields = (await getFields()).where((f) => f.id != id).toList();
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(fields.map((f) => f.toMap()).toList());
    await prefs.setString(keyFields, encoded);
    notifyListeners();
  }

  /// Clears stored fields (used in testing or resets).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyFields);
    notifyListeners();
  }
}
