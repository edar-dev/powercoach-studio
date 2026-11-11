import 'package:flutter/foundation.dart';

import '../data/workout_routine_model.dart';
import '../domain/workout_mobility_mutations.dart';
import 'workout_builder_session_controller.dart';

/// Mobility section selection and routine mutations for the workout builder.
class MobilityBuilderController extends ChangeNotifier {
  MobilityBuilderController(this._session);

  final WorkoutBuilderSessionController _session;
  int _selectedMobilitySectionIndex = 0;

  WorkoutRoutine get routine => _session.routine;
  List<MobilitySection> get sections => routine.mobilitySections;
  int get selectedSectionIndex => _selectedMobilitySectionIndex;

  String? get selectedSectionId {
    final list = sections;
    if (list.isEmpty) return null;
    final idx = _selectedMobilitySectionIndex.clamp(0, list.length - 1);
    return list[idx].id;
  }

  List<MobilityItem> get itemsForSelectedSection {
    final sid = selectedSectionId;
    if (sid == null) return const [];
    return routine.mobilityItems.where((e) => e.sectionId == sid).toList();
  }

  void selectSection(int index) {
    final next = sections.isEmpty
        ? 0
        : index.clamp(0, sections.length - 1);
    if (next == _selectedMobilitySectionIndex) return;
    _selectedMobilitySectionIndex = next;
    notifyListeners();
  }

  void resetSectionSelection() {
    _selectedMobilitySectionIndex = 0;
    notifyListeners();
  }

  bool addSection({required String name, String? sectionId}) {
    // Empty name is intentional ("unset"); UI shows localized "Sezione N".
    final trimmed = name.trim();
    final id = sectionId ?? 'sec_${DateTime.now().millisecondsSinceEpoch}';
    _session.setRoutine(
      addMobilitySectionToRoutine(
        routine: routine,
        section: MobilitySection(id: id, name: trimmed),
      ),
    );
    _selectedMobilitySectionIndex = sections.length - 1;
    notifyListeners();
    return true;
  }

  bool updateSection({
    required String sectionId,
    required String name,
    required String scheduleHint,
  }) {
    final updated = updateMobilitySectionInRoutine(
      routine: routine,
      sectionId: sectionId,
      name: name,
      scheduleHint: scheduleHint,
    );
    if (updated == routine) return false;
    _session.setRoutine(updated);
    notifyListeners();
    return true;
  }

  bool deleteSection(int index) {
    final updated = deleteMobilitySectionFromRoutine(
      routine: routine,
      sectionIndex: index,
    );
    if (updated == null) return false;
    _session.setRoutine(updated);
    _selectedMobilitySectionIndex = _selectedMobilitySectionIndex.clamp(
      0,
      sections.isEmpty ? 0 : sections.length - 1,
    );
    notifyListeners();
    return true;
  }

  bool addItem(MobilityItem item) {
    if (selectedSectionId == null) return false;
    _session.setRoutine(
      addMobilityItemToRoutine(routine: routine, item: item),
    );
    notifyListeners();
    return true;
  }

  bool removeItem(String itemId) {
    _session.setRoutine(
      removeMobilityItemFromRoutine(routine: routine, itemId: itemId),
    );
    notifyListeners();
    return true;
  }

  bool insertItemAt({
    required MobilityItem item,
    required int indexInSection,
  }) {
    _session.setRoutine(
      insertMobilityItemAtIndexInRoutine(
        routine: routine,
        item: item,
        indexInSection: indexInSection,
      ),
    );
    notifyListeners();
    return true;
  }

  bool reorderItems(int oldIndex, int newIndex) {
    final sectionId = selectedSectionId;
    if (sectionId == null) return false;
    _session.setRoutine(
      reorderMobilityItemsInSection(
        routine: routine,
        sectionId: sectionId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      ),
    );
    notifyListeners();
    return true;
  }

  bool updateItem(MobilityItem item) {
    _session.setRoutine(
      updateMobilityItemInRoutine(routine: routine, item: item),
    );
    notifyListeners();
    return true;
  }

  bool addSetToItem(String itemId) {
    final updated = addSetToMobilityItemInRoutine(
      routine: routine,
      itemId: itemId,
    );
    if (updated == null) return false;
    _session.setRoutine(updated);
    notifyListeners();
    return true;
  }

  bool updateItemSet({
    required String itemId,
    required int setIndex,
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) {
    final updated = updateMobilityItemSetInRoutine(
      routine: routine,
      itemId: itemId,
      setIndex: setIndex,
      line: line,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
    );
    if (updated == null) return false;
    _session.setRoutine(updated);
    notifyListeners();
    return true;
  }

  bool removeSetFromItem({
    required String itemId,
    required int setIndex,
  }) {
    final updated = removeSetFromMobilityItemInRoutine(
      routine: routine,
      itemId: itemId,
      setIndex: setIndex,
    );
    if (updated == null) return false;
    _session.setRoutine(updated);
    notifyListeners();
    return true;
  }
}
