/// Pure-Dart derivation layer: turns the flat list of `Equipment` records
/// from `EquipmentRepository` into the aggregate view-models the Clients,
/// Schedule and Notifications screens render. This file imports no
/// `package:flutter/material.dart` or other Flutter widget/paint type —
/// severity travels as an enum and colours stay in the page layer — which
/// is what keeps this module unit-testable in `test/derivations_test.dart`.
library;

import '../models/equipment.dart';
import '../utils/date_labels.dart';
import 'client_directory.dart';

/// Calibration urgency, shared by every derived view-model in this file.
enum CalibrationSeverity { overdue, urgent, ok }

/// Single definition of agenda membership, reused by every function below
/// so the clients AGEND. count, the schedule list and the notification
/// list can never disagree with each other or with the dashboard.
bool isOnAgenda(Equipment e) => e.isOverdue || e.isUrgent;

/// Maps an equipment record to its calibration severity using the same
/// `Equipment` model getters the dashboard already relies on.
CalibrationSeverity severityOf(Equipment e) {
  if (e.isOverdue) return CalibrationSeverity.overdue;
  if (e.isUrgent) return CalibrationSeverity.urgent;
  return CalibrationSeverity.ok;
}

class ClientSummary {
  final String name;
  final String cnpj;
  final String? logoAsset;
  final int equipmentCount;
  final int agendaCount;
  final DateTime? nextCalibration;
  final CalibrationSeverity severity;

  const ClientSummary({
    required this.name,
    required this.cnpj,
    required this.logoAsset,
    required this.equipmentCount,
    required this.agendaCount,
    required this.nextCalibration,
    required this.severity,
  });
}

class ScheduleEntry {
  final String equipmentName;
  final String clientName;
  final DateTime nextCalibration;
  final int daysUntil;
  final CalibrationSeverity severity;

  const ScheduleEntry({
    required this.equipmentName,
    required this.clientName,
    required this.nextCalibration,
    required this.daysUntil,
    required this.severity,
  });
}

class AppNotification {
  final String title;
  final String body;
  final String meta;
  final CalibrationSeverity severity;

  const AppNotification({
    required this.title,
    required this.body,
    required this.meta,
    required this.severity,
  });
}

/// Groups [equipments] by the raw `Equipment.client` string, computing live
/// counts and identity metadata per group. A client name with zero
/// matching equipment records never produces a summary — the static
/// directory alone is never a source of client cards (D-02, D-03).
List<ClientSummary> buildClientSummaries(List<Equipment> equipments) {
  final groups = <String, List<Equipment>>{};
  for (final e in equipments) {
    groups.putIfAbsent(e.client, () => []).add(e);
  }

  final summaries = <ClientSummary>[];
  for (final entry in groups.entries) {
    final name = entry.key;
    final items = entry.value;
    final agendaCount = items.where(isOnAgenda).length;

    Equipment? earliest;
    for (final e in items) {
      if (earliest == null ||
          e.nextCalibration.isBefore(earliest.nextCalibration)) {
        earliest = e;
      }
    }

    final info = lookupClient(name);
    summaries.add(ClientSummary(
      name: name,
      cnpj: info?.cnpj ?? kUnknownClientCnpj,
      logoAsset: info?.logoAsset,
      equipmentCount: items.length,
      agendaCount: agendaCount,
      nextCalibration: earliest?.nextCalibration,
      severity: earliest == null ? CalibrationSeverity.ok : severityOf(earliest),
    ));
  }

  summaries.sort((a, b) {
    final aDate = a.nextCalibration;
    final bDate = b.nextCalibration;
    if (aDate != null && bDate != null) {
      final cmp = aDate.compareTo(bDate);
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    }
    if (aDate == null && bDate == null) return a.name.compareTo(b.name);
    return aDate == null ? 1 : -1;
  });

  return summaries;
}

/// Filters to overdue/urgent equipment and sorts earliest-due first so the
/// most overdue item leads the agenda (D-04). Carries no time-of-day
/// field — the model has none, and inventing one would re-introduce the
/// fixed data this task removes.
List<ScheduleEntry> buildScheduleEntries(List<Equipment> equipments) {
  final entries = equipments.where(isOnAgenda).map((e) {
    return ScheduleEntry(
      equipmentName: e.name,
      clientName: e.client,
      nextCalibration: e.nextCalibration,
      daysUntil: e.daysUntilCalibration,
      severity: severityOf(e),
    );
  }).toList();

  entries.sort((a, b) => a.nextCalibration.compareTo(b.nextCalibration));
  return entries;
}

/// Emits one notification per overdue record and one per urgent record —
/// never a fabricated event-log entry (D-05). Overdue notifications sort
/// before urgent ones; within each group, soonest `nextCalibration` first.
List<AppNotification> buildNotifications(List<Equipment> equipments) {
  final overdue = equipments.where((e) => e.isOverdue).toList()
    ..sort((a, b) => a.nextCalibration.compareTo(b.nextCalibration));
  final urgent = equipments.where((e) => e.isUrgent).toList()
    ..sort((a, b) => a.nextCalibration.compareTo(b.nextCalibration));

  final notifications = <AppNotification>[];

  for (final e in overdue) {
    final daysLate = -e.daysUntilCalibration;
    notifications.add(AppNotification(
      title: 'Calibração Atrasada',
      body:
          'O ${e.name} da ${e.client} está com calibração atrasada há $daysLate dias.',
      meta: formatDayMonth(e.nextCalibration),
      severity: CalibrationSeverity.overdue,
    ));
  }

  for (final e in urgent) {
    notifications.add(AppNotification(
      title: 'Calibração Urgente',
      body:
          'O ${e.name} da ${e.client} precisa ser calibrado até ${formatDayMonth(e.nextCalibration)}.',
      meta: formatDayMonth(e.nextCalibration),
      severity: CalibrationSeverity.urgent,
    ));
  }

  return notifications;
}
