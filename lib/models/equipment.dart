class Equipment {
  final String id;
  final String name;
  final String client;
  final String type;
  final String brand;
  final String model;
  final String serialNumber;
  final DateTime lastCalibration;
  final DateTime nextCalibration;
  final String status;
  final String? certificateId;

  Equipment({
    required this.id,
    required this.name,
    required this.client,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.lastCalibration,
    required this.nextCalibration,
    required this.status,
    this.certificateId,
  });

  int get daysUntilCalibration {
    final now = DateTime.now();
    return nextCalibration.difference(now).inDays;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(nextCalibration);
  }

  bool get isUrgent {
    return daysUntilCalibration <= 30 && !isOverdue;
  }
}
