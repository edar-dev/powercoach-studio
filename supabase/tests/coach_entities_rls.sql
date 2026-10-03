-- Manual / CI-adjacent RLS assertions for public.coach_entities.
-- Run against a local Supabase stack with two authenticated JWTs (user A / user B).
-- Expected: each user only sees and mutates their own rows; anon has no access.
--
-- Prerequisites:
--   1. Apply migrations including 20261003200000_coach_entities.sql
--   2. Create auth users A and B (or use existing test users)
--   3. Set request.jwt.claim.sub via set_config for each role switch

-- As authenticated user A (replace <user_a_uuid>):
--   select set_config('request.jwt.claim.sub', '<user_a_uuid>', true);
--   set local role authenticated;

-- Seed A row
-- insert into public.coach_entities (user_id, type, id, scope_id, payload)
-- values (
--   '<user_a_uuid>'::uuid,
--   'customer',
--   'cust_a1',
--   '<user_a_uuid>',
--   '{"id":"cust_a1","userId":"<user_a_uuid>","firstName":"A"}'::jsonb
-- );

-- Assert A can read own row
-- select count(*) = 1 as a_sees_own
-- from public.coach_entities where id = 'cust_a1';

-- Assert A cannot insert with B's user_id (with check fails)
-- insert into public.coach_entities (user_id, type, id, scope_id, payload)
-- values (
--   '<user_b_uuid>'::uuid,
--   'customer',
--   'cust_b_forged',
--   '<user_b_uuid>',
--   '{}'::jsonb
-- );
-- -- expect: ERROR / 0 rows

-- Switch to user B
--   select set_config('request.jwt.claim.sub', '<user_b_uuid>', true);

-- Assert B cannot select A's row
-- select count(*) = 0 as b_cannot_see_a
-- from public.coach_entities where id = 'cust_a1';

-- Assert B cannot update A's row
-- update public.coach_entities
-- set deleted = true
-- where id = 'cust_a1';
-- -- expect: 0 rows affected

-- Assert B cannot delete A's row
-- delete from public.coach_entities where id = 'cust_a1';
-- -- expect: 0 rows affected

-- As anon (no JWT):
--   set local role anon;
-- select count(*) from public.coach_entities;
-- -- expect: permission denied or 0 rows (no SELECT grant)

-- Soft-delete semantics (app path): UPDATE deleted=true, not hard DELETE.
-- Hard DELETE is RLS-allowed for own rows but the Flutter client uses soft-delete.
