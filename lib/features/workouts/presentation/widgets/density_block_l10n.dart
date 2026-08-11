import '../../../../l10n/app_localizations.dart';
import '../../domain/density_block.dart';

/// Localized density subtitle for builder panels (IT/EN).
String localizedDensityBlockSubtitle(
  AppLocalizations l10n,
  DensityBlockConfig config,
) {
  switch (config.type) {
    case DensityBlockType.superset:
      return '';
    case DensityBlockType.circuit:
      final parts = <String>[];
      if (config.rounds != null) {
        parts.add(l10n.densityCircuitRounds(config.rounds!));
      }
      if (config.restSeconds != null) {
        parts.add(l10n.densityCircuitRest(config.restSeconds!));
      }
      return parts.join(' · ');
    case DensityBlockType.emom:
      final parts = <String>[];
      if (config.intervalSeconds != null) {
        parts.add(l10n.densityEmomInterval(config.intervalSeconds!));
      }
      if (config.durationMinutes != null) {
        parts.add(l10n.densityEmomDuration(config.durationMinutes!));
      }
      return parts.join(' · ');
  }
}
