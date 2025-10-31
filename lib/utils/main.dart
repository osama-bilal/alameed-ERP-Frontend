import 'package:intl/intl.dart';
// here is helper functions like date formatters, validators, converters, etc

/// ---- Helpers ----
DateTime? parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v as String);
}

String? dateTimeToIso(DateTime? dt) => dt?.toIso8601String();

/// Formats a value as either a time (if it's the same day as [reference] / now)
/// or as the weekday name with the date. If the year differs from [reference],
/// the year is included in the output.
/// - `v` can be a DateTime or an ISO-8601 string (uses existing parseDateTime).
/// - `use24Hour` toggles 24h vs 12h clock for same-day times.
String? formatDateTimeSmart(
  dynamic v, {
  bool use24Hour = false,
  DateTime? reference,
  bool showTime = true,
}) {
  final dt = parseDateTime(v);
  if (dt == null) return null;

  final ref = (reference ?? DateTime.now()).toLocal();
  final localDt = dt.toLocal();

  final sameDay =
      localDt.year == ref.year &&
      localDt.month == ref.month &&
      localDt.day == ref.day;
  final timeFmt = use24Hour ? DateFormat.Hm() : DateFormat.jm();
  if (sameDay) {
    return timeFmt.format(localDt);
  }

  final differentYear = localDt.year != ref.year;
  final datePattern = differentYear ? 'EEEE, MMM d, y' : 'EEEE, MMM d';

  final dateFmt = showTime
      ? timeFmt.addPattern(datePattern)
      : DateFormat(datePattern);
  return dateFmt.format(dt);
}
