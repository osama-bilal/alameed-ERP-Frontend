// here is helper functions like date formatters, validators, converters, etc

/// ---- Helpers ----
DateTime? parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.parse(v as String);
}
String? dateTimeToIso(DateTime? dt) => dt?.toIso8601String();