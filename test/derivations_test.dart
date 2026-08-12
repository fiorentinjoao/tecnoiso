import 'package:flutter_test/flutter_test.dart';
import 'package:tecnoiso_demo/data/client_directory.dart';
import 'package:tecnoiso_demo/data/derivations.dart';
import 'package:tecnoiso_demo/models/equipment.dart';
import 'package:tecnoiso_demo/utils/date_labels.dart';

void main() {
  Equipment buildEquipment({
    required String id,
    required String client,
    String name = 'Equipamento Teste',
    DateTime? nextCalibration,
  }) {
    final next = nextCalibration ?? DateTime.now().add(const Duration(days: 200));
    return Equipment(
      id: id,
      name: name,
      client: client,
      type: 'Tipo',
      brand: 'Marca',
      model: 'Modelo',
      serialNumber: 'SN-$id',
      lastCalibration: next.subtract(const Duration(days: 180)),
      nextCalibration: next,
      status: 'Em dia',
    );
  }

  final overdueDate = DateTime.now().subtract(const Duration(days: 27));
  final urgentDate = DateTime.now().add(const Duration(days: 10));
  final okDate = DateTime.now().add(const Duration(days: 200));

  group('buildClientSummaries', () {
    test('two equipment sharing a client produce one summary with count 2', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Heineken', nextCalibration: okDate),
        buildEquipment(id: '2', client: 'Heineken', nextCalibration: urgentDate),
      ];
      final summaries = buildClientSummaries(equipments);
      expect(summaries.length, 1);
      expect(summaries.first.equipmentCount, 2);
    });

    test('empty equipment list produces empty summary list', () {
      expect(buildClientSummaries(const []), isEmpty);
    });

    test('all in-day equipment has agendaCount 0 but real equipmentCount', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Docol', nextCalibration: okDate),
        buildEquipment(id: '2', client: 'Docol', nextCalibration: okDate),
      ];
      final summary = buildClientSummaries(equipments).first;
      expect(summary.agendaCount, 0);
      expect(summary.equipmentCount, 2);
    });

    test('nextCalibration is the earliest in the group', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Heineken', nextCalibration: okDate),
        buildEquipment(id: '2', client: 'Heineken', nextCalibration: urgentDate),
      ];
      final summary = buildClientSummaries(equipments).first;
      expect(summary.nextCalibration, urgentDate);
    });

    test('unknown client name yields placeholder identity and null logo', () {
      final equipments = [buildEquipment(id: '1', client: 'Cliente Desconhecido')];
      final summary = buildClientSummaries(equipments).first;
      expect(summary.cnpj, kUnknownClientCnpj);
      expect(summary.logoAsset, isNull);
    });

    test('known client name yields directory cnpj and asset', () {
      final equipments = [buildEquipment(id: '1', client: 'Docol')];
      final summary = buildClientSummaries(equipments).first;
      expect(summary.cnpj, kClientDirectory['Docol']!.cnpj);
      expect(summary.logoAsset, kClientDirectory['Docol']!.logoAsset);
    });

    test('summaries sort most-urgent-first by nextCalibration ascending', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Docol', nextCalibration: okDate),
        buildEquipment(id: '2', client: 'Heineken', nextCalibration: overdueDate),
      ];
      final summaries = buildClientSummaries(equipments);
      expect(summaries.first.name, 'Heineken');
      expect(summaries.last.name, 'Docol');
    });

    test('ties in nextCalibration break alphabetically by name', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Zeta', nextCalibration: urgentDate),
        buildEquipment(id: '2', client: 'Alfa', nextCalibration: urgentDate),
      ];
      final summaries = buildClientSummaries(equipments);
      expect(summaries.first.name, 'Alfa');
      expect(summaries.last.name, 'Zeta');
    });
  });

  group('buildScheduleEntries', () {
    test('excludes equipment neither overdue nor urgent', () {
      final equipments = [buildEquipment(id: '1', client: 'Docol', nextCalibration: okDate)];
      expect(buildScheduleEntries(equipments), isEmpty);
    });

    test('includes overdue and urgent, sorted earliest first', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Heineken', nextCalibration: urgentDate),
        buildEquipment(id: '2', client: 'Docol', nextCalibration: overdueDate),
      ];
      final entries = buildScheduleEntries(equipments);
      expect(entries.length, 2);
      expect(entries.first.clientName, 'Docol');
      expect(entries.last.clientName, 'Heineken');
    });

    test('maps severity correctly', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Heineken', nextCalibration: overdueDate),
        buildEquipment(id: '2', client: 'Docol', nextCalibration: urgentDate),
      ];
      final entries = buildScheduleEntries(equipments);
      final overdueEntry = entries.firstWhere((e) => e.clientName == 'Heineken');
      final urgentEntry = entries.firstWhere((e) => e.clientName == 'Docol');
      expect(overdueEntry.severity, CalibrationSeverity.overdue);
      expect(urgentEntry.severity, CalibrationSeverity.urgent);
    });

    test('daysUntil is negative for an overdue entry', () {
      final equipments = [buildEquipment(id: '1', client: 'Heineken', nextCalibration: overdueDate)];
      final entry = buildScheduleEntries(equipments).first;
      expect(entry.daysUntil, lessThan(0));
    });

    test('all in-day list produces empty entries', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Heineken', nextCalibration: okDate),
        buildEquipment(id: '2', client: 'Docol', nextCalibration: okDate),
      ];
      expect(buildScheduleEntries(equipments), isEmpty);
    });
  });

  group('buildNotifications', () {
    test('overdue record produces late-titled notification naming equipment and client', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Heineken', name: 'Micrômetro', nextCalibration: overdueDate),
      ];
      final notifications = buildNotifications(equipments);
      expect(notifications.length, 1);
      expect(notifications.first.title, contains('Atrasada'));
      expect(notifications.first.body, contains('Micrômetro'));
      expect(notifications.first.body, contains('Heineken'));
    });

    test('urgent record produces urgent-titled notification', () {
      final equipments = [buildEquipment(id: '1', client: 'Docol', nextCalibration: urgentDate)];
      final notifications = buildNotifications(equipments);
      expect(notifications.length, 1);
      expect(notifications.first.title, contains('Urgente'));
    });

    test('in-day record produces no notification, all in-day list returns empty', () {
      final equipments = [buildEquipment(id: '1', client: 'Docol', nextCalibration: okDate)];
      expect(buildNotifications(equipments), isEmpty);
    });

    test('overdue notifications sort before urgent ones', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Docol', nextCalibration: urgentDate),
        buildEquipment(id: '2', client: 'Heineken', nextCalibration: overdueDate),
      ];
      final notifications = buildNotifications(equipments);
      expect(notifications.first.severity, CalibrationSeverity.overdue);
      expect(notifications.last.severity, CalibrationSeverity.urgent);
    });

    test('one notification per qualifying equipment', () {
      final equipments = [
        buildEquipment(id: '1', client: 'Docol', nextCalibration: overdueDate),
        buildEquipment(id: '2', client: 'Heineken', nextCalibration: urgentDate),
        buildEquipment(id: '3', client: 'Coca-Cola', nextCalibration: okDate),
      ];
      final qualifying = equipments.where((e) => e.isOverdue || e.isUrgent).length;
      expect(buildNotifications(equipments).length, qualifying);
    });
  });

  group('date_labels', () {
    test('formatDayMonth renders zero-padded day/month', () {
      expect(formatDayMonth(DateTime(2026, 7, 1)), '01/07');
      expect(formatDayMonth(DateTime(2026, 12, 25)), '25/12');
    });

    test('relativeDueLabel distinguishes overdue/today/tomorrow/future', () {
      expect(relativeDueLabel(-5), contains('Atrasado'));
      expect(relativeDueLabel(0), 'Hoje');
      expect(relativeDueLabel(1), 'Amanhã');
      expect(relativeDueLabel(5), contains('5'));
    });

    test('currentWeekDays returns 7 consecutive Monday-Sunday dates containing the input', () {
      final now = DateTime(2026, 7, 8);
      final week = currentWeekDays(now);
      expect(week.length, 7);
      expect(week.first.weekday, DateTime.monday);
      expect(week.last.weekday, DateTime.sunday);
      expect(
        week.any((d) => d.year == now.year && d.month == now.month && d.day == now.day),
        isTrue,
      );
      for (var i = 1; i < week.length; i++) {
        expect(week[i].difference(week[i - 1]).inDays, 1);
      }
    });
  });
}
