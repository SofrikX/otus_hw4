# PetConnect Production Backend Verification

Date: 23 June 2026, MSK

Production Supabase project ref: `fivtpxsjcjirddogngtl`

## Summary

Production backend deployment is complete for migrations `001`-`006`.

The deployment applied pet photo Storage support and two corrective migrations discovered during production verification:

- `005_harden_remote_rls_policies.sql` aligns production RLS with the hardened local policy model.
- `006_fix_pet_images_storage_policy_path.sql` fixes `pet-images` Storage policy path extraction.

No secrets, service role keys, database passwords, Supabase access tokens or `.env` files were added to the repository.

## Verification SQL

Public tables:

```sql
select table_name
from information_schema.tables
where table_schema = 'public'
order by table_name;
```

Pets columns:

```sql
select column_name, data_type, is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name = 'pets'
order by ordinal_position;
```

Public RLS policies:

```sql
select
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
order by tablename, policyname;
```

Storage buckets:

```sql
select id, name, public, file_size_limit, allowed_mime_types
from storage.buckets
order by name;
```

Storage policies:

```sql
select
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'storage'
order by tablename, policyname;
```

## Verification Results

Public tables found:

```text
chat_participants
chats
comments
messages
pets
post_likes
posts
profiles
walk_participants
walks
```

`pets` columns found:

```text
id uuid NO
owner_id uuid NO
owner_name text YES
name text NO
animal_type text NO
breed text YES
age integer YES
description text YES
photo_url text YES
photo_emoji text YES
created_at timestamp with time zone NO
updated_at timestamp with time zone NO
```

Storage buckets found:

| Bucket | Public | Notes |
|---|---:|---|
| `avatars` | false | Prepared private bucket. |
| `pet-images` | true | Expected public-read pet profile image bucket. |
| `pet-photos` | false | Historical/prepared private bucket. |
| `post-images` | false | Prepared private bucket for future post images. |

RLS verification highlights:

- `posts_read_authenticated` now requires `deleted_at is null` and either public visibility or own author id.
- `posts_insert_own` and `posts_update_own` require `author_id = auth.uid()` and an owned pet.
- `comments_read_authenticated` and `comments_insert_own` check target post visibility.
- `post_likes_read_authenticated` and `post_likes_insert_own` check target post visibility.
- `walk_participants_insert_self` requires `user_id = auth.uid()` and an active walk.
- Chat and message policies remain participant-scoped through `is_chat_participant`.

Storage verification highlights:

- `storage_read_public_pet_images` allows `anon` and `authenticated` reads only for bucket `pet-images`.
- `storage_insert_own_pet_images`, `storage_update_own_pet_images` and `storage_delete_own_pet_images` require bucket `pet-images`, first path segment `auth.uid()`, and second path segment matching a `public.pets.id` owned by `auth.uid()`.
- Corrected production policy output references `storage.foldername(objects.name)` for the pet id segment.

## Local Validation

Executed after deployment:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Results:

- `flutter pub get`: passed.
- `dart format --set-exit-if-changed .`: passed, `91` files checked, `0` changed.
- `flutter analyze`: passed, `No issues found!`.
- `flutter test`: passed, `109` tests.

## Production Backend QA Checklist

- [x] Migrations are applied to hosted Supabase.
- [x] Public schema tables match PetConnect backend model.
- [x] `pets.photo_url` exists for pet image display.
- [x] RLS policies are hardened and owner/visibility scoped.
- [x] Storage bucket `pet-images` exists and is public-read.
- [x] Storage write policies use authenticated owner/pet-scoped object paths.
- [x] No production seed was executed.
- [x] No RLS disabling or data deletion was performed.
- [ ] Run browser QA: sign in, create pet, upload pet photo, create post, like/comment, create/join/leave walk.
- [ ] Verify Google OAuth redirect URLs in Supabase Dashboard.
- [ ] Run production E2E after the final Netlify frontend deploy.

## Frontend Deployment Sync

Checked after backend deployment:

- Netlify publish directory is `build/web`.
- Netlify functions directory is `netlify/functions`.
- `/api/health` redirects to `/.netlify/functions/health` before the SPA fallback.
- SPA fallback redirects `/*` to `/index.html` with status `200`.
- Flutter Web release builds must pass `USE_SUPABASE_BACKEND`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER` and `YANDEX_METRICA_COUNTER_ID`.

Required production frontend environment variables:

| Environment | Required values |
|---|---|
| Netlify UI | `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER`, `YANDEX_METRICA_COUNTER_ID` |
| GitHub Actions secrets | `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` |
| GitHub Actions variables | `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER`, `YANDEX_METRICA_COUNTER_ID` |

## Known Limitations

- Hosted SQL verification used `supabase db query --linked`; parallel CLI calls temporarily caused temp-login retries, so future checks should be run sequentially.
- Bucket metadata currently has no Supabase-level MIME or file-size limit. Flutter validates JPG/JPEG/PNG/WebP and 5 MB before upload.
- Post image upload, avatar upload and full chat send flows remain planned enhancements.
