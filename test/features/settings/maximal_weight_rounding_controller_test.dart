import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/features/settings/data/maximal_weight_rounding_controller.dart';
import 'package:powercoach_studio/features/settings/data/user_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Reset singleton cache so tests do not leak selection across cases.
    await MaximalWeightRoundingController.instance.load();
  });

  test('load defaults to 2.5 kg', () async {
    final controller = MaximalWeightRoundingController.instance;
    await controller.load();
    expect(controller.incrementKg, kDefaultMaximalWeightRoundingKg);
  });

  test('setIncrementKg persists and notifies', () async {
    final controller = MaximalWeightRoundingController.instance;
    var notified = 0;
    void listener() => notified++;
    controller.addListener(listener);
    addTearDown(() => controller.removeListener(listener));

    await controller.setIncrementKg(0.5);
    expect(controller.incrementKg, 0.5);
    expect(notified, greaterThan(0));
    expect(
      await UserPreferencesRepository.instance.getMaximalWeightRoundingKg(),
      0.5,
    );

    await controller.setIncrementKg(1);
    expect(controller.incrementKg, 1.0);
  });

  test('load reads existing SharedPreferences value', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SettingsPrefsKeys.maximalWeightRoundingKg: 1.0,
    });
    final controller = MaximalWeightRoundingController.instance;
    await controller.load();
    expect(controller.incrementKg, 1.0);
  });
}
