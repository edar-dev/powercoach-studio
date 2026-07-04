/// Workout Builder layout variant (Stitch screen IDs in feature docs).
enum WorkoutBuilderVariant {
  mobility,
  multiset,
  superset,
  intuitiveSuperset,
}

extension WorkoutBuilderVariantX on WorkoutBuilderVariant {
  bool get showsMobilityTab => this == WorkoutBuilderVariant.mobility;
}
