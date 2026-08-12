import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tecnoiso_demo/data/auth_repository.dart';
import 'package:tecnoiso_demo/data/equipment_repository.dart';
import 'package:tecnoiso_demo/data/hive_setup.dart';
import 'package:tecnoiso_demo/models/equipment.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('tecnoiso_hive_test_');
    await initHive(path: tempDir.path);
    registerAdapters();
    await openBoxes();
  });

  tearDown(() async {
    await closeHive();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Equipment buildEquipment({
    String id = 'test-1',
    String? certificateId,
  }) {
    return Equipment(
      id: id,
      name: 'Micrômetro Digital 0-25mm',
      client: 'Heineken',
      type: 'Medição Dimensional',
      brand: 'Mitutoyo',
      model: 'MDC-25PX',
      serialNumber: 'SN-2023-001',
      lastCalibration: DateTime(2025, 11, 15),
      nextCalibration: DateTime(2026, 5, 15),
      status: 'Atrasado',
      certificateId: certificateId,
    );
  }

  group('Equipment adapter round-trip', () {
    test('an Equipment written and read back is equal field-by-field', () async {
      final original = buildEquipment(certificateId: 'CERT-001');
      await equipmentsBox.put(original.id, original);
      final restored = equipmentsBox.get(original.id)!;

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.client, original.client);
      expect(restored.type, original.type);
      expect(restored.brand, original.brand);
      expect(restored.model, original.model);
      expect(restored.serialNumber, original.serialNumber);
      expect(restored.lastCalibration, original.lastCalibration);
      expect(restored.nextCalibration, original.nextCalibration);
      expect(restored.status, original.status);
      expect(restored.certificateId, original.certificateId);
    });

    test(
        'lastCalibration/nextCalibration survive as the same instant and isUtc flag',
        () async {
      final original = buildEquipment();
      await equipmentsBox.put(original.id, original);
      final restored = equipmentsBox.get(original.id)!;

      expect(restored.lastCalibration.isAtSameMomentAs(original.lastCalibration),
          isTrue);
      expect(restored.nextCalibration.isAtSameMomentAs(original.nextCalibration),
          isTrue);
      expect(restored.lastCalibration.isUtc, original.lastCalibration.isUtc);
      expect(restored.nextCalibration.isUtc, original.nextCalibration.isUtc);
      expect(restored.isOverdue, original.isOverdue);
      expect(restored.isUrgent, original.isUrgent);
      expect(restored.daysUntilCalibration, original.daysUntilCalibration);
    });

    test('a record with certificateId == null round-trips as null', () async {
      final original = buildEquipment(certificateId: null);
      await equipmentsBox.put(original.id, original);
      final restored = equipmentsBox.get(original.id)!;

      expect(restored.certificateId, isNull);
    });
  });

  group('EquipmentRepository', () {
    test('seedIfNeeded on a fresh box inserts exactly 8 records with ids 1..8',
        () async {
      await EquipmentRepository.instance.seedIfNeeded();
      final all = EquipmentRepository.instance.all();

      expect(all.length, 8);
      expect(
        all.map((e) => e.id).toSet(),
        {'1', '2', '3', '4', '5', '6', '7', '8'},
      );
    });

    test('calling seedIfNeeded twice leaves 8 records', () async {
      await EquipmentRepository.instance.seedIfNeeded();
      await EquipmentRepository.instance.seedIfNeeded();

      expect(EquipmentRepository.instance.all().length, 8);
    });

    test(
        'seeded ids 1..8 carry the exact name, client and status from the original hardcoded list',
        () async {
      await EquipmentRepository.instance.seedIfNeeded();
      const expected = {
        '1': ('Micrômetro Digital 0-25mm', 'Heineken', 'Atrasado'),
        '2': ('Termômetro Infravermelho', 'Coca-Cola', 'Atrasado'),
        '3': ('Balança Analítica 0.1mg', 'Docol', 'Atrasado'),
        '4': ('Manômetro Digital 0-100bar', 'Portos do Paraná', 'Urgente'),
        '5': ('Trena Metálica 5m', 'Descarpack', 'Urgente'),
        '6': ('Dinamômetro Digital 500N', 'Heineken', 'Em dia'),
        '7': ('Higrômetro Industrial', 'Coca-Cola', 'Em dia'),
        '8': ('Calibrador de Pressão', 'Porto Itapoa', 'Em dia'),
      };

      for (final entry in expected.entries) {
        final equipment = EquipmentRepository.instance.getById(entry.key);
        expect(equipment, isNotNull, reason: 'missing seeded id ${entry.key}');
        expect(equipment!.name, entry.value.$1, reason: 'id ${entry.key} name');
        expect(equipment.client, entry.value.$2, reason: 'id ${entry.key} client');
        expect(equipment.status, entry.value.$3, reason: 'id ${entry.key} status');
      }
    });

    test(
        'after deleting every record, seedIfNeeded inserts nothing (no resurrection)',
        () async {
      await EquipmentRepository.instance.seedIfNeeded();
      for (final equipment in EquipmentRepository.instance.all()) {
        await EquipmentRepository.instance.delete(equipment.id);
      }

      await EquipmentRepository.instance.seedIfNeeded();

      expect(EquipmentRepository.instance.all(), isEmpty);
    });

    test('add() then all() includes the new record', () async {
      final equipment = buildEquipment(id: 'new-1');
      await EquipmentRepository.instance.add(equipment);

      expect(
        EquipmentRepository.instance.all().map((e) => e.id),
        contains('new-1'),
      );
    });

    test('update() mutates in place without changing the count', () async {
      final equipment = buildEquipment(id: 'upd-1');
      await EquipmentRepository.instance.add(equipment);
      final countBefore = EquipmentRepository.instance.all().length;

      final updated = equipment.copyWith(status: 'Em dia');
      await EquipmentRepository.instance.update(updated);

      expect(EquipmentRepository.instance.all().length, countBefore);
      expect(EquipmentRepository.instance.getById('upd-1')!.status, 'Em dia');
    });

    test('delete(id) removes exactly one record', () async {
      final a = buildEquipment(id: 'del-a');
      final b = buildEquipment(id: 'del-b');
      await EquipmentRepository.instance.add(a);
      await EquipmentRepository.instance.add(b);
      final countBefore = EquipmentRepository.instance.all().length;

      await EquipmentRepository.instance.delete('del-a');

      expect(EquipmentRepository.instance.all().length, countBefore - 1);
      expect(EquipmentRepository.instance.getById('del-a'), isNull);
      expect(EquipmentRepository.instance.getById('del-b'), isNotNull);
    });

    test('getById returns null for an unknown id', () {
      expect(EquipmentRepository.instance.getById('does-not-exist'), isNull);
    });
  });

  group('AuthRepository', () {
    test(
        'register on a fresh box succeeds and the persisted record has no plaintext password or empty salt',
        () async {
      final user = await AuthRepository.instance.register('alice', 'hunter22');

      expect(user.username, 'alice');
      expect(user.salt, isNotEmpty);
      expect(user.passwordHash.contains('hunter22'), isFalse);
      expect(user.passwordHash, isNotEmpty);
    });

    test(
        'register with an already-existing (case-insensitive) username fails and does not create a second record',
        () async {
      await AuthRepository.instance.register('Alice', 'hunter22');

      expect(
        () => AuthRepository.instance.register('alice', 'other-pass'),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthErrorCode.usernameTaken,
        )),
      );

      expect(usersBox.values.length, 1);
    });

    test('login with correct credentials succeeds and sets currentUser',
        () async {
      await AuthRepository.instance.register('bob', 'correct-password');

      final user = await AuthRepository.instance.login('bob', 'correct-password');

      expect(user.username, 'bob');
      expect(AuthRepository.instance.currentUser?.username, 'bob');
    });

    test('login with a wrong password fails and leaves currentUser null',
        () async {
      await AuthRepository.instance.register('carol', 'correct-password');

      expect(
        () => AuthRepository.instance.login('carol', 'wrong-password'),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthErrorCode.invalidCredentials,
        )),
      );
      expect(AuthRepository.instance.currentUser, isNull);
    });

    test('login with an unknown username fails', () async {
      expect(
        () => AuthRepository.instance.login('ghost', 'whatever'),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthErrorCode.invalidCredentials,
        )),
      );
    });

    test(
        'currentUser reflects the session across a simulated restart without re-entering credentials',
        () async {
      await AuthRepository.instance.register('dave', 'dave-password');
      await AuthRepository.instance.login('dave', 'dave-password');

      await closeHive();
      await initHive(path: tempDir.path);
      registerAdapters();
      await openBoxes();

      expect(AuthRepository.instance.currentUser?.username, 'dave');
    });

    test('logout clears the session; currentUser is null afterwards',
        () async {
      await AuthRepository.instance.register('erin', 'erin-password');
      await AuthRepository.instance.login('erin', 'erin-password');

      await AuthRepository.instance.logout();

      expect(AuthRepository.instance.currentUser, isNull);
    });

    test(
        'a session id pointing at a deleted user resolves to null instead of crashing',
        () async {
      final user = await AuthRepository.instance.register('frank', 'frank-password');
      await AuthRepository.instance.login('frank', 'frank-password');
      await usersBox.delete(user.id);

      expect(AuthRepository.instance.currentUser, isNull);
    });
  });
}
