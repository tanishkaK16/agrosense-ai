import 'dart:convert';

/// Categories of farm alerts.
enum AlertKind {
  water,
  pest,
  health,
}

/// Urgency level of a farm alert.
enum AlertSeverity {
  watch,
  actNow,
}

/// Represents an actionable recommendation for a specific field.
class FarmAlert {
  const FarmAlert({
    required this.id,
    required this.fieldId,
    required this.kind,
    required this.severity,
    this.createdLabel = 'Today',
    this.seen = false,
  });

  final String id;
  final String fieldId;
  final AlertKind kind;
  final AlertSeverity severity;
  final String createdLabel;
  final bool seen;

  FarmAlert copyWith({
    String? id,
    String? fieldId,
    AlertKind? kind,
    AlertSeverity? severity,
    String? createdLabel,
    bool? seen,
  }) {
    return FarmAlert(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      kind: kind ?? this.kind,
      severity: severity ?? this.severity,
      createdLabel: createdLabel ?? this.createdLabel,
      seen: seen ?? this.seen,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'field_id': fieldId,
        'kind': kind.name,
        'severity': severity.name,
        'created_label': createdLabel,
        'seen': seen,
      };

  factory FarmAlert.fromMap(Map<String, dynamic> map) {
    return FarmAlert(
      id: map['id'] as String? ?? '',
      fieldId: map['field_id'] as String? ?? '',
      kind: AlertKind.values.firstWhere(
        (k) => k.name == map['kind'],
        orElse: () => AlertKind.water,
      ),
      severity: AlertSeverity.values.firstWhere(
        (s) => s.name == map['severity'],
        orElse: () => AlertSeverity.watch,
      ),
      createdLabel: map['created_label'] as String? ?? 'Today',
      seen: map['seen'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FarmAlert.fromJson(String source) =>
      FarmAlert.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
