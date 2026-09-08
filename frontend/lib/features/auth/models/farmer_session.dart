import 'dart:convert';

/// Represents an active farmer login session.
class FarmerSession {
  const FarmerSession({
    required this.phoneNumber,
    required this.token,
    required this.createdAt,
  });

  final String phoneNumber;
  final String token;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'phone_number': phoneNumber,
        'token': token,
        'created_at': createdAt.toIso8601String(),
      };

  factory FarmerSession.fromMap(Map<String, dynamic> map) => FarmerSession(
        phoneNumber: map['phone_number'] as String? ?? '',
        token: map['token'] as String? ?? '',
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  String toJson() => jsonEncode(toMap());

  factory FarmerSession.fromJson(String source) =>
      FarmerSession.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
