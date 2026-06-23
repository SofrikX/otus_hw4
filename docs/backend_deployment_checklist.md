# PetConnect Backend Deployment Checklist

Date: 23 June 2026, MSK

Production Supabase project ref: `fivtpxsjcjirddogngtl`

## Preflight

| Check | Result |
|---|---|
| `git status --short` | Working tree already had local uncommitted project changes before deployment; no secrets were added. |
| `supabase --version` | `2.106.0` |
| `ls -la supabase/migrations` | Migrations `001`-`004` existed before deploy; corrective migrations `005` and `006` were added during review. |
| `git log --oneline -10` | Latest commit before deployment: `c045384 fix ui issue`. |
| Supabase auth/link | CLI was authenticated; project `fivtpxsjcjirddogngtl` was linked and `ACTIVE_HEALTHY`. |

## Migration Review

| Migration | Purpose | Production safety review |
|---|---|---|
| `001_initial_schema.sql` | Tables, constraints, indexes, triggers, prepared Storage buckets/policies | No secrets; no destructive data deletion. |
| `002_rls_policies.sql` | RLS enablement and application policies | RLS enabled; owner-scoped writes; authenticated reads only where required by MVP. |
| `003_api_grants.sql` | Grants for authenticated PostgREST access | Grants do not bypass RLS. |
| `004_pet_images_storage.sql` | `pet-images` bucket and pet photo policies | Public read for pet profile images; authenticated owner/pet-scoped writes. |
| `005_harden_remote_rls_policies.sql` | Corrects production drift for hardened public RLS policies | No data changes; replaces weak earlier policy bodies. |
| `006_fix_pet_images_storage_policy_path.sql` | Corrects Storage path checks to use `storage.objects.name` | No data changes; fixes pet id extraction from object path. |

No reviewed migration contains `DROP TABLE`, `TRUNCATE`, production data deletion, RLS disabling, service-role key usage, committed secrets or anonymous write policies.

## Deploy Result

Commands executed:

```bash
supabase db push
supabase migration list
```

Results:

- `004_pet_images_storage.sql` applied to production. `photo_url` already existed and was skipped with an expected notice.
- Production policy verification showed old weakened policy bodies from a previously applied `002`, so `005_harden_remote_rls_policies.sql` was created and applied.
- Storage policy verification showed an ambiguous `name` reference resolved to `pets.name`, so `006_fix_pet_images_storage_policy_path.sql` was created and applied.
- Final `supabase migration list` showed local and remote migrations aligned from `001` through `006`.

## Verification Checklist

- [x] Public tables exist.
- [x] `pets.photo_url` column exists.
- [x] Public RLS policies are hardened in production.
- [x] Storage bucket `pet-images` exists.
- [x] `pet-images` is public-read.
- [x] `pet-images` write/update/delete policies are authenticated and owner/pet-scoped.
- [x] Local Flutter validation passed.

## Known Limitations

- `supabase db lint` / `supabase db reset` were not run during this deployment because the task targeted the hosted production project and local Supabase services were not started.
- Google OAuth redirect settings and real pet image upload should be checked in browser/manual QA after each production frontend redeploy.
- `file_size_limit` and `allowed_mime_types` are `NULL` in bucket metadata; Flutter enforces JPG/PNG/WebP and 5 MB before upload.
