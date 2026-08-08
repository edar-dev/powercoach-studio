---
name: local-first-persistence-v1
overview: "Tre onde: eccellenza backup local-first + soft cleanup; snapshot opzionali su Supabase Storage con reminder; migration Drift drop PendingOperations/SyncMeta."
todos:
  - id: wave-a-backup-prefs
    content: "Wave A: prefs complete in backup envelope + ignore legacy pending/syncMeta on write/restore"
    status: completed
  - id: wave-a-soft-cleanup
    content: "Wave A: dashboard/sync dead code, GymBlog comments, web onboarding/sign-out polish, plan frontmatter"
    status: completed
  - id: wave-b-storage
    content: "Wave B: Supabase bucket+RLS, CloudBackupRepository, Settings/sign-out UI"
    status: completed
  - id: wave-b-reminder
    content: "Wave B: 7-day backup age reminder + snooze + copy/FAQ/legal"
    status: completed
  - id: wave-c-schema-drop
    content: "Wave C: Drift migration drop PendingOperations + SyncMeta after A validated"
    status: completed
isProject: false
---

# Persistenza local-first + quasi-cloud + cleanup

Vedi anche il piano esecutivo Cursor `local-first_persistence_6f6b2685.plan.md`.

Decisioni: Supabase Storage manuale + reminder 7 giorni (niente auto-upload); soft cleanup prima del drop schema.

Branch: `feat/local-first-persistence`.
