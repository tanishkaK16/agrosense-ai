/// Crop health status of a farmer's field.
enum FieldHealth {
  healthy,
  watch,
  actNow,
}

/// Snapshot of key farm data displayed on the farmer home screen.
class HomeSnapshot {
  const HomeSnapshot({
    required this.temperatureC,
    required this.rainMm,
    required this.windKmh,
    required this.fieldName,
    required this.crop,
    required this.health,
    required this.summarySentence,
    required this.alertCount,
  });

  final int temperatureC;
  final int rainMm;
  final int windKmh;
  final String fieldName;
  final String crop;
  final FieldHealth health;
  final String summarySentence;
  final int alertCount;
}
