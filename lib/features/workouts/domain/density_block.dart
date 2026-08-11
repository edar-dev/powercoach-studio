import '../data/workout_routine_model.dart';

/// Programming density for a linked exercise group (superset / circuit / EMOM).
enum DensityBlockType { superset, circuit, emom }

/// Additive metadata for a [Day] group keyed by `supersetGroupId`.
class DensityBlockConfig {
  const DensityBlockConfig({
    required this.type,
    this.rounds,
    this.restSeconds,
    this.intervalSeconds,
    this.durationMinutes,
  });

  final DensityBlockType type;
  final int? rounds;
  final int? restSeconds;
  final int? intervalSeconds;
  final int? durationMinutes;

  static const DensityBlockConfig defaultCircuit = DensityBlockConfig(
    type: DensityBlockType.circuit,
    rounds: 3,
  );

  static const DensityBlockConfig defaultEmom = DensityBlockConfig(
    type: DensityBlockType.emom,
    intervalSeconds: 60,
  );

  DensityBlockConfig copyWith({
    DensityBlockType? type,
    int? rounds,
    int? restSeconds,
    int? intervalSeconds,
    int? durationMinutes,
    bool clearRounds = false,
    bool clearRestSeconds = false,
    bool clearIntervalSeconds = false,
    bool clearDurationMinutes = false,
  }) =>
      DensityBlockConfig(
        type: type ?? this.type,
        rounds: clearRounds ? null : (rounds ?? this.rounds),
        restSeconds:
            clearRestSeconds ? null : (restSeconds ?? this.restSeconds),
        intervalSeconds: clearIntervalSeconds
            ? null
            : (intervalSeconds ?? this.intervalSeconds),
        durationMinutes: clearDurationMinutes
            ? null
            : (durationMinutes ?? this.durationMinutes),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (rounds != null) 'rounds': rounds,
        if (restSeconds != null) 'restSeconds': restSeconds,
        if (intervalSeconds != null) 'intervalSeconds': intervalSeconds,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
      };

  /// Unknown / missing types fall back to [DensityBlockType.superset].
  static DensityBlockConfig fromJson(Map<String, dynamic> json) {
    final type = _parseType(json['type']?.toString());
    return DensityBlockConfig(
      type: type,
      rounds: (json['rounds'] as num?)?.toInt(),
      restSeconds: (json['restSeconds'] as num?)?.toInt(),
      intervalSeconds: (json['intervalSeconds'] as num?)?.toInt(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );
  }

  static DensityBlockType _parseType(String? raw) {
    switch (raw) {
      case 'circuit':
        return DensityBlockType.circuit;
      case 'emom':
        return DensityBlockType.emom;
      case 'superset':
        return DensityBlockType.superset;
      default:
        return DensityBlockType.superset;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DensityBlockConfig &&
          type == other.type &&
          rounds == other.rounds &&
          restSeconds == other.restSeconds &&
          intervalSeconds == other.intervalSeconds &&
          durationMinutes == other.durationMinutes;

  @override
  int get hashCode => Object.hash(
        type,
        rounds,
        restSeconds,
        intervalSeconds,
        durationMinutes,
      );
}

DensityBlockConfig? resolveDensityBlock(Day day, String groupId) {
  if (groupId.isEmpty) return null;
  return day.densityBlocks?[groupId];
}

/// Short English subtitle for UI (prefer [localizedDensityBlockSubtitle] in widgets).
String densityBlockSubtitle(DensityBlockConfig config) {
  switch (config.type) {
    case DensityBlockType.superset:
      return '';
    case DensityBlockType.circuit:
      final parts = <String>[];
      if (config.rounds != null) parts.add('${config.rounds} rounds');
      if (config.restSeconds != null) {
        parts.add('${config.restSeconds}s rest');
      }
      return parts.join(' · ');
    case DensityBlockType.emom:
      final parts = <String>[];
      if (config.intervalSeconds != null) {
        parts.add('EMOM ${config.intervalSeconds}s');
      }
      if (config.durationMinutes != null) {
        parts.add('${config.durationMinutes} min');
      }
      return parts.join(' · ');
  }
}

/// Compact params for PDF/Excel headers (locale-neutral numbers).
String densityBlockExportDetail(DensityBlockConfig config) {
  switch (config.type) {
    case DensityBlockType.superset:
      return '';
    case DensityBlockType.circuit:
      final parts = <String>[];
      if (config.rounds != null) parts.add('${config.rounds}×');
      if (config.restSeconds != null) parts.add('${config.restSeconds}s');
      return parts.join(' · ');
    case DensityBlockType.emom:
      final parts = <String>[];
      if (config.intervalSeconds != null) {
        parts.add('${config.intervalSeconds}s');
      }
      if (config.durationMinutes != null) {
        parts.add('${config.durationMinutes}min');
      }
      return parts.join(' · ');
  }
}

Map<String, DensityBlockConfig>? decodeDensityBlocks(dynamic raw) {
  if (raw is! Map) return null;
  if (raw.isEmpty) return null;
  final parsed = <String, DensityBlockConfig>{};
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    if (key.isEmpty) continue;
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      parsed[key] = DensityBlockConfig.fromJson(value);
    } else if (value is Map) {
      parsed[key] = DensityBlockConfig.fromJson(value.cast<String, dynamic>());
    }
  }
  return parsed.isEmpty ? null : parsed;
}

Map<String, dynamic>? encodeDensityBlocks(
  Map<String, DensityBlockConfig>? blocks,
) {
  if (blocks == null || blocks.isEmpty) return null;
  return {
    for (final entry in blocks.entries) entry.key: entry.value.toJson(),
  };
}

/// Stable fingerprint fragment for dirty tracking.
String serializeDensityBlocksFingerprint(
  Map<String, DensityBlockConfig>? blocks,
) {
  if (blocks == null || blocks.isEmpty) return '';
  final keys = blocks.keys.toList()..sort();
  final buffer = StringBuffer();
  for (final key in keys) {
    final c = blocks[key]!;
    buffer
      ..write(key)
      ..write('=')
      ..write(c.type.name)
      ..write(',')
      ..write(c.rounds ?? '')
      ..write(',')
      ..write(c.restSeconds ?? '')
      ..write(',')
      ..write(c.intervalSeconds ?? '')
      ..write(',')
      ..write(c.durationMinutes ?? '')
      ..write(';');
  }
  return buffer.toString();
}
