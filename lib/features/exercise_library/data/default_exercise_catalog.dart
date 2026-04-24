List<Map<String, dynamic>> buildDefaultExerciseCatalogJson() {
  final items = <Map<String, dynamic>>[];

  void addFamily({
    required String key,
    required String rootName,
    required List<String> variants,
    required bool isMobility,
  }) {
    final rootId = '${key}_root';
    items.add(<String, dynamic>{
      'id': rootId,
      'name': rootName,
      'description': null,
      'parentId': null,
      'sortOrder': 0,
      'isMobility': isMobility,
    });

    for (var i = 0; i < variants.length; i++) {
      items.add(<String, dynamic>{
        'id': '${key}_v${i + 1}',
        'name': variants[i],
        'description': null,
        'parentId': rootId,
        'sortOrder': i,
        'isMobility': isMobility,
      });
    }
  }

  final standardFamilies = <({String name, List<String> variants})>[
    (name: 'Back Squat', variants: ['High Bar', 'Low Bar', 'Pause']),
    (name: 'Front Squat', variants: ['Clean Grip', 'Cross Arm', 'Tempo']),
    (name: 'Deadlift', variants: ['Conventional', 'Sumo', 'Deficit']),
    (name: 'Romanian Deadlift', variants: ['Barbell', 'Dumbbell', 'Single Leg']),
    (name: 'Bench Press', variants: ['Competition', 'Close Grip', 'Spoto']),
    (name: 'Incline Bench Press', variants: ['Barbell', 'Dumbbell', 'Smith Machine']),
    (name: 'Overhead Press', variants: ['Standing Barbell', 'Seated Dumbbell', 'Push Press']),
    (name: 'Pull Up', variants: ['Pronated', 'Neutral Grip', 'Weighted']),
    (name: 'Barbell Row', variants: ['Pendlay', 'Yates', 'Underhand']),
    (name: 'Lat Pulldown', variants: ['Wide Grip', 'Neutral Grip', 'Single Arm']),
    (name: 'Leg Press', variants: ['High Foot', 'Low Foot', 'Single Leg']),
    (name: 'Lunge', variants: ['Walking', 'Reverse', 'Bulgarian Split Squat']),
    (name: 'Hip Thrust', variants: ['Barbell', 'Dumbbell', 'Banded']),
    (name: 'Biceps Curl', variants: ['Barbell', 'Dumbbell Alternating', 'Hammer']),
    (name: 'Triceps Extension', variants: ['Overhead Dumbbell', 'Cable Rope', 'Skull Crusher']),
  ];

  final mobilityFamilies = <({String name, List<String> variants})>[
    (name: 'Hip Mobility', variants: ['90/90 Transitions', 'Pigeon Stretch', 'Couch Stretch']),
    (name: 'Ankle Mobility', variants: ['Knee to Wall', 'Banded Dorsiflexion', 'Calf Stretch']),
    (name: 'Thoracic Mobility', variants: ['Open Book', 'Thread the Needle', 'Foam Roller Extension']),
    (name: 'Shoulder Mobility', variants: ['Wall Slides', 'PVC Pass Through', 'Sleeper Stretch']),
    (name: 'Hamstring Mobility', variants: ['Dynamic Leg Swings', 'Seated Hamstring Stretch', 'Jefferson Curl Light']),
    (name: 'Adductor Mobility', variants: ['Cossack Squat', 'Frog Stretch', 'Copenhagen Prep']),
    (name: 'Glute Activation', variants: ['Banded Clamshell', 'Monster Walk', 'Glute Bridge Iso']),
    (name: 'Core Stability', variants: ['Dead Bug', 'Bird Dog', 'Pallof Press']),
    (name: 'Scapular Control', variants: ['Scap Push Up', 'Scap Pull Up', 'Prone Y Raise']),
    (name: 'Full Body Warmup', variants: ['World Greatest Stretch', 'Inchworm Walkout', 'Deep Squat Pry']),
  ];

  for (var i = 0; i < standardFamilies.length; i++) {
    final family = standardFamilies[i];
    addFamily(
      key: 'std_${(i + 1).toString().padLeft(2, '0')}',
      rootName: family.name,
      variants: family.variants,
      isMobility: false,
    );
  }

  for (var i = 0; i < mobilityFamilies.length; i++) {
    final family = mobilityFamilies[i];
    addFamily(
      key: 'mob_${(i + 1).toString().padLeft(2, '0')}',
      rootName: family.name,
      variants: family.variants,
      isMobility: true,
    );
  }

  return items;
}
