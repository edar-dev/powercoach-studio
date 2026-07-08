import '../../../../l10n/app_localizations.dart';

const List<({String value, String labelKey})> customerExerciseRecordUnits = [
  (value: 'kg', labelKey: 'recordUnitKg'),
  (value: 'reps', labelKey: 'recordUnitReps'),
  (value: 'sec', labelKey: 'recordUnitSec'),
  (value: 'min', labelKey: 'recordUnitMin'),
  (value: 'other', labelKey: 'recordUnitOther'),
];

String customerExerciseRecordUnitLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'recordUnitKg':
      return l10n.recordUnitKg;
    case 'recordUnitReps':
      return l10n.recordUnitReps;
    case 'recordUnitSec':
      return l10n.recordUnitSec;
    case 'recordUnitMin':
      return l10n.recordUnitMin;
    case 'recordUnitOther':
      return l10n.recordUnitOther;
    default:
      return labelKey;
  }
}
