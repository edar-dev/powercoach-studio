/// Stable rule identifiers emitted by [DataQualityScanner].
abstract final class DataQualityRuleIds {
  static const String emptyId = 'empty_id';
  static const String unknownType = 'unknown_type';
  static const String backupTypeMismatch = 'backup_type_mismatch';
  static const String orphanReference = 'orphan_reference';
  static const String parentCycle = 'parent_cycle';
  static const String planDataDecode = 'plan_data_decode';
  static const String planDataEmptyWeeks = 'plan_data_empty_weeks';
  static const String preferencesDecode = 'preferences_decode';
}
