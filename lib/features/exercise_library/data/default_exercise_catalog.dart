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

  /// Strength / hypertrophy + powerlifting competition lifts and accessories.
  /// Names are Italian (primary locale); common English cues kept where coaches
  /// search that way (e.g. Spoto, SSB, RDL).
  final standardFamilies = <({String name, List<String> variants})>[
    // --- Competition lower ---
    (
      name: 'Squat con bilanciere',
      variants: [
        'High bar',
        'Low bar',
        'Con pausa',
        'Tempo 3-1-1',
        'Box squat',
        'Pin squat',
        'Con catene',
        'Con bande',
      ],
    ),
    (
      name: 'Front squat',
      variants: [
        'Presa clean',
        'Braccia incrociate',
        'Con pausa',
        'Tempo 3-1-1',
        'Con bilanciere di sicurezza',
      ],
    ),
    (
      name: 'Safety bar squat (SSB)',
      variants: [
        'High bar feel',
        'Con pausa',
        'Box squat',
        'Camminata in rack',
      ],
    ),
    (
      name: 'Stacco da terra',
      variants: [
        'Classico',
        'Sumo',
        'Deficit',
        'Con pausa',
        'Block pull',
        'Rack pull',
        'Snatch grip',
        'Con catene',
      ],
    ),
    (
      name: 'Stacco rumeno (RDL)',
      variants: [
        'Bilanciere',
        'Manubri',
        'Gamba singola',
        'Con pausa al ginocchio',
        'Deficit',
      ],
    ),
    (
      name: 'Trap bar deadlift',
      variants: [
        'Maniglie alte',
        'Maniglie basse',
        'Deficit',
        'Con pausa',
      ],
    ),
    (
      name: 'Good morning',
      variants: [
        'Bilanciere in piedi',
        'Seduto',
        'Arch back',
        'Con banda',
        'Safety bar',
      ],
    ),
    (
      name: 'Hip hinge accessori',
      variants: [
        'Pull through al cavo',
        'Kettlebell swing',
        'Stacco a gambe tese',
        '45° back extension',
        'GHD back extension',
      ],
    ),
    // --- Competition upper / press ---
    (
      name: 'Panca piana',
      variants: [
        'Presa media',
        'Presa larga',
        'Presa stretta',
        'Con fermo al petto',
        'Touch and go',
        'Spoto press',
        'Pin press',
        'Board press',
        'Floor press',
        'Con catene',
        'Con bande',
        'Tempo 3-1-1',
      ],
    ),
    (
      name: 'Panca inclinata',
      variants: [
        'Bilanciere',
        'Manubri',
        'Smith machine',
        'Presa neutra',
        'Con pausa',
      ],
    ),
    (
      name: 'Panca declinata',
      variants: [
        'Bilanciere',
        'Manubri',
        'Presa stretta',
        'Con pausa',
      ],
    ),
    (
      name: 'Floor press',
      variants: [
        'Bilanciere',
        'Manubri',
        'Presa stretta',
        'Con fermo',
      ],
    ),
    (
      name: 'Military press',
      variants: [
        'In piedi bilanciere',
        'Seduto manubri',
        'Push press',
        'Arnold press',
        'Z press',
      ],
    ),
    (
      name: 'Lento avanti',
      variants: [
        'Bilanciere',
        'Manubri alternati',
        'Unilaterale',
        'Con pausa in alto',
      ],
    ),
    // --- Pull / back ---
    (
      name: 'Trazioni alla sbarra',
      variants: [
        'Presa prona',
        'Presa supina',
        'Presa neutra',
        'Zavorrate',
      ],
    ),
    (
      name: 'Lat machine',
      variants: [
        'Presa larga',
        'Presa stretta',
        'Presa neutra',
        'Monobraccio',
      ],
    ),
    (
      name: 'Rematore bilanciere',
      variants: [
        'Pendlay',
        'Yates',
        'Presa inversa',
        'Con fermo',
        'Chest supported',
      ],
    ),
    (
      name: 'Rematore manubrio',
      variants: [
        'Su panca',
        'A busto libero',
        'Unilaterale',
        'Con pausa',
      ],
    ),
    (
      name: 'Seal row',
      variants: [
        'Bilanciere',
        'Manubri',
        'Presa prona',
        'Presa neutra',
      ],
    ),
    (
      name: 'Pulley basso',
      variants: [
        'Impugnatura stretta',
        'Impugnatura larga',
        'Corda',
        'Monobraccio',
      ],
    ),
    // --- Legs accessories ---
    (
      name: 'Leg press',
      variants: [
        'Piedi alti',
        'Piedi bassi',
        'Presa stretta',
        'Monolaterale',
      ],
    ),
    (
      name: 'Hack squat',
      variants: [
        'Piedi alti',
        'Piedi bassi',
        'Con pausa',
        'Monolaterale',
      ],
    ),
    (
      name: 'Belt squat',
      variants: [
        'Libero',
        'Con pausa',
        'Tempo lento',
        'Camminata',
      ],
    ),
    (
      name: 'Affondi',
      variants: [
        'Camminati',
        'Indietro',
        'Bulgari',
        'Laterali',
      ],
    ),
    (
      name: 'Step up',
      variants: [
        'Manubri',
        'Bilanciere',
        'Panca alta',
        'Panca bassa',
      ],
    ),
    (
      name: 'Hip thrust',
      variants: [
        'Bilanciere',
        'Manubrio',
        'Banda elastica',
        'Monolaterale',
      ],
    ),
    (
      name: 'Glute bridge',
      variants: [
        'Bilanciere',
        'A corpo libero',
        'Con fermo',
        'Monolaterale',
      ],
    ),
    (
      name: 'Leg curl',
      variants: [
        'Sdraiato',
        'Seduto',
        'Nordic curl',
        'Monolaterale',
      ],
    ),
    (
      name: 'Leg extension',
      variants: [
        'Seduto',
        'Monolaterale',
        'Con fermo in alto',
        'Tempo lento',
      ],
    ),
    (
      name: 'Calf raise',
      variants: [
        'In piedi',
        'Seduto',
        'Leg press calf',
        'Monolaterale',
      ],
    ),
    // --- Shoulders / arms ---
    (
      name: 'Alzate laterali',
      variants: [
        'Manubri',
        'Cavo',
        'Unilaterali',
        'Parziali',
      ],
    ),
    (
      name: 'Alzate frontali',
      variants: [
        'Manubri',
        'Bilanciere',
        'Disco',
        'Cavo',
      ],
    ),
    (
      name: 'Face pull',
      variants: [
        'Corda alta',
        'Corda bassa',
        'Con extra rotazione',
        'Unilaterale',
      ],
    ),
    (
      name: 'Curl bicipiti',
      variants: [
        'Bilanciere',
        'Manubri alternati',
        'Hammer curl',
        'Panca inclinata',
      ],
    ),
    (
      name: 'Curl al cavo',
      variants: [
        'Barra dritta',
        'Barra EZ',
        'Corda',
        'Unilaterale',
      ],
    ),
    (
      name: 'Estensioni tricipiti',
      variants: [
        'French press',
        'Corda al cavo',
        'Overhead manubrio',
        'JM press',
        'Skull crusher',
      ],
    ),
    (
      name: 'Dip alle parallele',
      variants: [
        'A corpo libero',
        'Zavorrate',
        'Assisted machine',
        'Con pausa',
      ],
    ),
    // --- Core / bracing (powerlifting) ---
    (
      name: 'Core bracing',
      variants: [
        'Plank',
        'Dead bug',
        'Pallof press',
        'Ab wheel',
        'GHD sit-up',
        'Hanging leg raise',
      ],
    ),
  ];

  final mobilityFamilies = <({String name, List<String> variants})>[
    (
      name: 'Mobilita anca',
      variants: [
        'Transizioni 90/90',
        'Stretch del piccione',
        'Couch stretch',
        'CARs anca',
      ],
    ),
    (
      name: 'Mobilita caviglia',
      variants: [
        'Knee to wall',
        'Dorsiflessione con banda',
        'Stretch polpaccio',
        'Affondo dinamico caviglia',
      ],
    ),
    (
      name: 'Mobilita toracica',
      variants: [
        'Open book',
        'Thread the needle',
        'Estensione su foam roller',
        'Rotazioni in quadrupedia',
      ],
    ),
    (
      name: 'Mobilita spalla',
      variants: [
        'Wall slide',
        'Pass through con bastone',
        'Sleeper stretch',
        'CARs spalla',
      ],
    ),
    (
      name: 'Mobilita femorali',
      variants: [
        'Slanci dinamici',
        'Stretch seduto',
        'Jefferson curl leggero',
        'PNF femorali',
      ],
    ),
    (
      name: 'Mobilita adduttori',
      variants: [
        'Cossack squat',
        'Frog stretch',
        'Rock back adduttori',
        'Affondo laterale dinamico',
      ],
    ),
    (
      name: 'Attivazione glutei',
      variants: [
        'Clamshell con banda',
        'Monster walk',
        'Glute bridge isometrico',
        'Fire hydrant',
      ],
    ),
    (
      name: 'Stabilita core',
      variants: [
        'Dead bug',
        'Bird dog',
        'Pallof press',
        'Plank respirato',
      ],
    ),
    (
      name: 'Controllo scapolare',
      variants: [
        'Scap push up',
        'Scap pull up',
        'Y raise prono',
        'Wall angels',
      ],
    ),
    (
      name: 'Riscaldamento totale',
      variants: [
        'World greatest stretch',
        'Inchworm walkout',
        'Deep squat pry',
        'Cat-cow dinamico',
      ],
    ),
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

/// Number of nodes produced by [buildDefaultExerciseCatalogJson] (roots + variants).
int defaultExerciseCatalogNodeCount() =>
    buildDefaultExerciseCatalogJson().length;
