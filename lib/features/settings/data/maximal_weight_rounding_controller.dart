import 'package:flutter/foundation.dart';

import 'user_preferences_repository.dart';

/// Coach-global maximal load rounding preference (kg).
///
/// Domain math ([applyPercentRounded]) stays pure: callers pass
/// [incrementKg]. This singleton caches the SharedPreferences value so
/// Settings and the workout builder can read it without duplicating keys.
class MaximalWeightRoundingController extends ChangeNotifier {
  MaximalWeightRoundingController._();

  static final MaximalWeightRoundingController instance =
      MaximalWeightRoundingController._();

  double _incrementKg = kDefaultMaximalWeightRoundingKg;

  /// Current rounding increment in kg (`0.5` / `1` / `2.5`).
  double get incrementKg => _incrementKg;

  /// Loads the preference from SharedPreferences into the in-memory cache.
  Future<void> load() async {
    _incrementKg =
        await UserPreferencesRepository.instance.getMaximalWeightRoundingKg();
    notifyListeners();
  }

  /// Persists [kg] (normalized to an allowed increment) and updates the cache.
  Future<void> setIncrementKg(double kg) async {
    await UserPreferencesRepository.instance.setMaximalWeightRoundingKg(kg);
    _incrementKg =
        await UserPreferencesRepository.instance.getMaximalWeightRoundingKg();
    notifyListeners();
  }
}
