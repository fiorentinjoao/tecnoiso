import 'package:hive_ce/hive.dart';

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

  Equipment copyWith({
    String? id,
    String? name,
    String? client,
    String? type,
    String? brand,
    String? model,
    String? serialNumber,
    DateTime? lastCalibration,
    DateTime? nextCalibration,
    String? status,
    Object? certificateId = _unset,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      client: client ?? this.client,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      lastCalibration: lastCalibration ?? this.lastCalibration,
      nextCalibration: nextCalibration ?? this.nextCalibration,
      status: status ?? this.status,
      certificateId: identical(certificateId, _unset)
          ? this.certificateId
          : certificateId as String?,
    );
  }
}

/// Sentinel used by [Equipment.copyWith] so an explicit `null` passed for
/// certificateId is distinguishable from "not provided".
const Object _unset = Object();

/// Hand-written adapter using Hive's numbered-field wire format so the
/// schema stays forward-compatible without codegen.
class EquipmentAdapter extends TypeAdapter<Equipment> {
  @override
  final int typeId = 0;

  @override
  Equipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equipment(
      id: fields[0] as String,
      name: fields[1] as String,
      client: fields[2] as String,
      type: fields[3] as String,
      brand: fields[4] as String,
      model: fields[5] as String,
      serialNumber: fields[6] as String,
      lastCalibration:
          DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      nextCalibration:
          DateTime.fromMillisecondsSinceEpoch(fields[8] as int),
      status: fields[9] as String,
      certificateId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Equipment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.client)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.brand)
      ..writeByte(5)
      ..write(obj.model)
      ..writeByte(6)
      ..write(obj.serialNumber)
      ..writeByte(7)
      ..write(obj.lastCalibration.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.nextCalibration.millisecondsSinceEpoch)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.certificateId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
