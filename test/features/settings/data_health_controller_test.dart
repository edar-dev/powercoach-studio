import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/data_quality/data_quality.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/features/exercise_library/data/pinned_exercises_store.dart';
import 'package:powercoach_studio/features/exercise_library/data/recent_exercises_store.dart';
import 'package:powercoach_studio/features/settings/presentation/data_health_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('DataHealthController.preferenceOrphanTargetIds', () {
    test('collects unique prefs orphan target ids only', () {
      final report = DataQualityReport(
        scannedEntityCount: 0,
        generatedAt: DateTime.utc(2026, 1, 1),
        findings: [
          const DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'prefs orphan a',
            details: <String, dynamic>{
              'source': 'preferences',
              'targetId': 'ghost-a',
              'fieldPath': SettingsPrefsKeys.pinnedExerciseIdsJson,
            },
          ),
          const DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'prefs orphan a duplicate',
            details: <String, dynamic>{
              'source': 'preferences',
              'targetId': 'ghost-a',
              'fieldPath': SettingsPrefsKeys.recentExerciseIdsJson,
            },
          ),
          const DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'entity fk orphan — must be ignored',
            entityId: 'plan-1',
            details: <String, dynamic>{
              'targetId': 'ghost-entity',
              'fieldPath': 'payload.exerciseId',
            },
          ),
          const DataQualityFinding(
            ruleId: DataQualityRuleIds.preferencesDecode,
            severity: DataQualitySeverity.info,
            message: 'decode issue',
            details: <String, dynamic>{
              'source': 'preferences',
              'fieldPath': SettingsPrefsKeys.pinnedExerciseIdsJson,
            },
          ),
          const DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'prefs orphan b',
            details: <String, dynamic>{
              'source': 'preferences',
              'targetId': 'ghost-b',
            },
          ),
          const DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'prefs orphan missing target',
            details: <String, dynamic>{
              'source': 'preferences',
            },
          ),
        ],
      );

      expect(
        DataHealthController.preferenceOrphanTargetIds(report),
        {'ghost-a', 'ghost-b'},
      );
      expect(DataHealthController.hasPreferenceOrphans(report), isTrue);
    });

    test('returns empty when no prefs orphans', () {
      final report = DataQualityReport(
        scannedEntityCount: 1,
        generatedAt: DateTime.utc(2026, 1, 1),
        findings: const [
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'entity orphan',
            details: <String, dynamic>{
              'targetId': 'x',
              'fieldPath': 'payload.exerciseId',
            },
          ),
        ],
      );
      expect(DataHealthController.preferenceOrphanTargetIds(report), isEmpty);
      expect(DataHealthController.hasPreferenceOrphans(report), isFalse);
    });
  });

  group('DataHealthController.clearPreferencesOrphans', () {
    test('removes orphan ids from pin and recent stores only', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SettingsPrefsKeys.pinnedExerciseIdsJson:
            jsonEncode(['keep-pin', 'ghost-a', 'ghost-b']),
        SettingsPrefsKeys.recentExerciseIdsJson:
            jsonEncode(['ghost-a', 'keep-recent', 'ghost-c']),
      });

      final report = DataQualityReport(
        scannedEntityCount: 0,
        generatedAt: DateTime.utc(2026, 1, 1),
        findings: const [
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'a',
            details: <String, dynamic>{
              'source': 'preferences',
              'targetId': 'ghost-a',
            },
          ),
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'b',
            details: <String, dynamic>{
              'source': 'preferences',
              'targetId': 'ghost-b',
            },
          ),
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'entity orphan ignored',
            details: <String, dynamic>{
              'targetId': 'keep-pin',
              'fieldPath': 'payload.x',
            },
          ),
        ],
      );

      final controller = DataHealthController();
      final cleared = await controller.clearPreferencesOrphans(report);

      expect(cleared, 2);
      expect(
        await PinnedExercisesStore.instance.getPinnedIds(),
        {'keep-pin'},
      );
      expect(
        await RecentExercisesStore.instance.getRecentIds(),
        ['keep-recent', 'ghost-c'],
      );
    });

    test('returns 0 and leaves stores untouched when no prefs orphans', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SettingsPrefsKeys.pinnedExerciseIdsJson: jsonEncode(['keep']),
        SettingsPrefsKeys.recentExerciseIdsJson: jsonEncode(['keep']),
      });

      final report = DataQualityReport(
        scannedEntityCount: 0,
        generatedAt: DateTime.utc(2026, 1, 1),
        findings: const [
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'entity orphan',
            details: <String, dynamic>{
              'targetId': 'keep',
              'fieldPath': 'payload.exerciseId',
            },
          ),
        ],
      );

      final cleared =
          await DataHealthController().clearPreferencesOrphans(report);

      expect(cleared, 0);
      expect(await PinnedExercisesStore.instance.getPinnedIds(), {'keep'});
      expect(await RecentExercisesStore.instance.getRecentIds(), ['keep']);
      expect(DataHealthController.hasPreferenceOrphans(report), isFalse);
    });
  });
}
