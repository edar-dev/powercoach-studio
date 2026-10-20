-- Add customerMaximal to coach_entities type CHECK (massimali custom per cliente).
-- Approved schema change for massimali PR2. Does not reintroduce exerciseRecord.
-- Apply remotely via Supabase MCP apply_migration or SQL Editor after merge.

alter table public.coach_entities
  drop constraint if exists coach_entities_type_check;

alter table public.coach_entities
  add constraint coach_entities_type_check check (
    type in (
      'customer',
      'workoutPlan',
      'measurement',
      'customExercise',
      'customerNote',
      'customerMaximal'
    )
  );
