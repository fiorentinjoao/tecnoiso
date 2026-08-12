import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/equipment.dart';
import 'hive_setup.dart';

/// Single source of truth for equipment data, backed by the already-open
/// `Box<Equipment>` from [hive_setup]. Every record is keyed by the
/// equipment's own `id`, so update/delete are direct key operations.
class EquipmentRepository {
  EquipmentRepository._();

  static final EquipmentRepository instance = EquipmentRepository._();

  Box<Equipment> get _box => equipmentsBox;

  List<Equipment> all() => _box.values.toList();

  Equipment? getById(String id) => _box.get(id);

  Future<void> add(Equipment equipment) => _box.put(equipment.id, equipment);

  Future<void> update(Equipment equipment) =>
      _box.put(equipment.id, equipment);

  Future<void> delete(String id) => _box.delete(id);

  ValueListenable<Box<Equipment>> listenable() => _box.listenable();

  /// Id generator for records created from the UI. Cannot collide with the
  /// seed ids '1'..'8'.
  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Seeds the box, on first launch only, with the exact 8 records that
  /// were previously hardcoded in home_page.dart / equipment_list_page.dart
  /// so the UI looks unchanged. Guarded on the `equipmentsSeeded` session
  /// flag (NOT merely on the box being empty), so deleted demo records do
  /// not resurrect.
  Future<void> seedIfNeeded() async {
    final alreadySeeded =
        sessionBox.get(SessionKeys.equipmentsSeeded, defaultValue: false)
            as bool;
    if (alreadySeeded) return;

    for (final equipment in _seedData()) {
      await _box.put(equipment.id, equipment);
    }
    await sessionBox.put(SessionKeys.equipmentsSeeded, true);
  }

  List<Equipment> _seedData() {
    return [
      Equipment(
        id: '1',
        name: 'Micrômetro Digital 0-25mm',
        client: 'Heineken',
        type: 'Medição Dimensional',
        brand: 'Mitutoyo',
        model: 'MDC-25PX',
        serialNumber: 'SN-2023-001',
        lastCalibration: DateTime(2025, 11, 15),
        nextCalibration: DateTime(2026, 5, 15),
        status: 'Atrasado',
      ),
      Equipment(
        id: '2',
        name: 'Termômetro Infravermelho',
        client: 'Coca-Cola',
        type: 'Temperatura',
        brand: 'Fluke',
        model: '62 MAX',
        serialNumber: 'SN-2023-002',
        lastCalibration: DateTime(2025, 12, 10),
        nextCalibration: DateTime(2026, 6, 10),
        status: 'Atrasado',
      ),
      Equipment(
        id: '3',
        name: 'Balança Analítica 0.1mg',
        client: 'Docol',
        type: 'Massa',
        brand: 'Mettler Toledo',
        model: 'ME204',
        serialNumber: 'SN-2023-003',
        lastCalibration: DateTime(2026, 1, 20),
        nextCalibration: DateTime(2026, 7, 20),
        status: 'Atrasado',
      ),
      Equipment(
        id: '4',
        name: 'Manômetro Digital 0-100bar',
        client: 'Portos do Paraná',
        type: 'Pressão',
        brand: 'WIKA',
        model: 'S-20',
        serialNumber: 'SN-2024-001',
        lastCalibration: DateTime(2026, 3, 1),
        nextCalibration: DateTime(2026, 7, 1),
        status: 'Urgente',
      ),
      Equipment(
        id: '5',
        name: 'Trena Metálica 5m',
        client: 'Descarpack',
        type: 'Medição Dimensional',
        brand: 'Starrett',
        model: '606M',
        serialNumber: 'SN-2024-002',
        lastCalibration: DateTime(2026, 3, 15),
        nextCalibration: DateTime(2026, 7, 15),
        status: 'Urgente',
      ),
      Equipment(
        id: '6',
        name: 'Dinamômetro Digital 500N',
        client: 'Heineken',
        type: 'Força',
        brand: 'Shimpo',
        model: 'FGP-500N',
        serialNumber: 'SN-2024-003',
        lastCalibration: DateTime(2026, 4, 1),
        nextCalibration: DateTime(2026, 10, 1),
        status: 'Em dia',
      ),
      Equipment(
        id: '7',
        name: 'Higrômetro Industrial',
        client: 'Coca-Cola',
        type: 'Umidade',
        brand: 'Vaisala',
        model: 'HMT120',
        serialNumber: 'SN-2024-004',
        lastCalibration: DateTime(2026, 4, 10),
        nextCalibration: DateTime(2026, 10, 10),
        status: 'Em dia',
      ),
      Equipment(
        id: '8',
        name: 'Calibrador de Pressão',
        client: 'Porto Itapoa',
        type: 'Pressão',
        brand: 'Druck',
        model: 'DPI 104',
        serialNumber: 'SN-2024-005',
        lastCalibration: DateTime(2026, 5, 1),
        nextCalibration: DateTime(2026, 11, 1),
        status: 'Em dia',
      ),
    ];
  }
}
