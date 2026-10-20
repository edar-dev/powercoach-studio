/// Parse a coach-entered kg string (`"80"`, `"80,5"`, `"80.5"`).
double? parseMaximalKgInput(String? raw) {
  if (raw == null) return null;
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

/// Format kg for a text field (no trailing `.0` for whole numbers).
String formatMaximalKgInput(double kg) {
  final asInt = kg.round();
  if ((kg - asInt).abs() < 1e-6) return asInt.toString();
  return kg.toString();
}
