/// Pure Dart date-label helpers for pt-BR display strings. No Flutter
/// import here — this keeps the module trivially unit-testable and mirrors
/// the same constraint applied to `lib/data/derivations.dart`. Name/weekday
/// lookups are backed by small const tables, which is why no `intl`
/// dependency is needed for this task.
library;

const List<String> _monthNamesPtBr = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

const List<String> _weekdayAbbrevPtBr = [
  'SEG',
  'TER',
  'QUA',
  'QUI',
  'SEX',
  'SÁB',
  'DOM',
];

/// Returns e.g. "Julho 2026" for the given date.
String monthYearLabelPtBr(DateTime date) {
  return '${_monthNamesPtBr[date.month - 1]} ${date.year}';
}

/// Returns the three-letter pt-BR weekday abbreviation for
/// `DateTime.monday`..`DateTime.sunday` (1..7).
String weekdayAbbrevPtBr(int weekday) {
  return _weekdayAbbrevPtBr[weekday - 1];
}

/// Returns a zero-padded `dd/MM` string.
String formatDayMonth(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

/// Returns a short pt-BR phrase describing `daysUntil` (negative = overdue,
/// 0 = today, 1 = tomorrow, otherwise "Em N dias").
String relativeDueLabel(int daysUntil) {
  if (daysUntil < 0) {
    final days = -daysUntil;
    return days == 1 ? 'Atrasado há 1 dia' : 'Atrasado há $days dias';
  }
  if (daysUntil == 0) return 'Hoje';
  if (daysUntil == 1) return 'Amanhã';
  return 'Em $daysUntil dias';
}

/// Returns the seven consecutive `DateTime`s (Monday..Sunday, normalized to
/// midnight) of the week containing `now`.
List<DateTime> currentWeekDays(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}
