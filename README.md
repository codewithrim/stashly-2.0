# Stashly 2.0

A private, cross-device save-for-later app for notes, links, snippets, and images built with Flutter and Supabase.

## Architecture

- **State Management:** `flutter_riverpod`
- **Navigation:** `go_router` (deep link ready)
- **Local Cache & Outbox:** Drift SQLite (`drift` + `drift_flutter`)
- **Backend:** Supabase (Auth, PostgreSQL with strict Row Level Security, Storage, Edge Functions)

---

## Conflict Resolution Policy (Mission A)

Stashly follows an offline-first **optimistic concurrency** policy:

1. **Policy Principle:** *Most recently updated wins, with interactive warning.*
2. **Optimistic Locking:** When updating a record remotely, the client sends its known `updated_at` timestamp:
   ```dart
   final rows = await supabase
       .from('saved_items')
       .update(patch)
       .eq('id', id)
       .eq('updated_at', baseUpdatedAt)
       .select();
   ```
3. **Conflict Detection:** If the row was modified on another device, 0 rows match the update condition.
4. **Resolution Options:** When a remote modification collision is detected, the user is presented with three safe choices:
   - **Keep Mine (Overwrite):** Force updates remote row with the local edit.
   - **Use Theirs:** Discards local changes and loads the remote version into the editor.
   - **Save Mine as a Copy:** Creates a new item with the local content so no work is lost.
5. **Draft Preservation:** Form drafts in the local SQLite `drafts` table are never discarded automatically during remote refreshes.

---

## Security Guarantees

- **Postgres Row Level Security (RLS):** Every row in `saved_items` and `share_links` enforces ownership checks against `auth.uid()`.
- **Private Attachments:** Supabase Storage bucket `attachments` is private; objects are accessed only via short-lived signed URLs.
- **Cross-Account Cache Isolation:** Signing out immediately wipes the local Drift database to prevent data exposure across users.
- **Zero HTML Injection:** The static public viewer renders all content using `textContent` only.

---

## Running Locally

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://iodqhxejlviovoaivnke.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_Y4JMsINnkWaE9JLIi9vqQw_q_ON8E36
```