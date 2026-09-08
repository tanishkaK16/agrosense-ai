import '../models/farm_alert.dart';

/// Centralized mapper between Alerts API JSON DTOs and [FarmAlert] domain models.
class AlertsMapper {
  const AlertsMapper._();

  static FarmAlert fromJson(Map<String, dynamic> json) {
    final kindStr = json['kind'] as String? ?? 'water';
    final severityStr = json['severity'] as String? ?? 'watch';

    final kind = AlertKind.values.firstWhere(
      (k) => k.name == kindStr,
      orElse: () => AlertKind.water,
    );

    final severity = AlertSeverity.values.firstWhere(
      (s) => s.name == severityStr,
      orElse: () => AlertSeverity.watch,
    );

    return FarmAlert(
      id: json['id'] as String? ?? '',
      fieldId: json['field_id'] as String? ?? '',
      kind: kind,
      severity: severity,
      createdLabel: json['created_label'] as String? ?? 'Today',
      seen: json['seen'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(FarmAlert alert) {
    return {
      'id': alert.id,
      'field_id': alert.fieldId,
      'kind': alert.kind.name,
      'severity': alert.severity.name,
      'created_label': alert.createdLabel,
      'seen': alert.seen,
    };
  }
}
