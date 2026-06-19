# PetConnect Security Audit

Date: 19 June 2026

Scope: Flutter Web frontend, Supabase migrations/configuration, Netlify/GitHub Actions configuration, historical Firebase Functions package dependencies and project documentation.

## 1. Summary

This audit checked PetConnect for hardcoded secrets, frontend exposure of Supabase keys, RLS coverage, OAuth redirect configuration, Flutter Web XSS risks, SQL injection risks, insecure logging and dependency vulnerabilities.

Overall result:

- No tracked service role key, `sb_secret_`, live payment key, Google API key or real token-like Supabase publishable key was found in tracked source or documentation.
- `.env.example` is tracked intentionally; real `.env` files are ignored by `.gitignore`.
- A local ignored `.env.deploy` exists and contains local deployment values, including a public Supabase frontend key. It is not tracked by git and should stay local.
- RLS is enabled for all PetConnect application tables in `supabase/migrations/002_rls_policies.sql`.
- Service role keys are not used by Flutter frontend code, Netlify config or GitHub Actions.
- Supabase publishable key is used only as frontend client configuration through `--dart-define` / CI env.
- `flutter analyze` passed.
- `npm audit` initially found a moderate vulnerability chain in the historical Firebase Functions dependencies. It was fixed by updating `firebase-admin` within the compatible peer range and adding a `uuid` override.
- `supabase db lint` could not run because local Supabase Postgres was not running on `127.0.0.1:54322`; this is an environment blocker, not a SQL lint result.

Files inspected included `pubspec.yaml`, `pubspec.lock`, `functions/package.json`, `functions/package-lock.json`, `netlify.toml`, `.github/workflows/`, `supabase/migrations/`, `supabase/seed.sql`, `README.md`, `backend_documentation.md`, `integration_documentation.md`, `lib/`, `web/` and `docs/`.

## 2. Audit Commands

Dependency and static checks:

```bash
flutter pub outdated
flutter analyze
cd functions && npm audit
cd functions && npm run build
supabase db lint
```

Secret checks:

```bash
grep -RIn "sb_secret_\|service_role\|SUPABASE_SERVICE\|SUPABASE_ANON_KEY\|sk_live\|AIza\|password=" . --exclude-dir=.git --exclude=pubspec.lock || true

git grep -n -E "sb_secret_|service_role|SUPABASE_SERVICE|SUPABASE_ANON_KEY|sk_live|AIza|password=" -- . ':!pubspec.lock' ':!functions/package-lock.json' || true

rg -n "sb_publishable_|sb_secret_|eyJ[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{20,}|sk_live_[0-9A-Za-z]+" README.md backend_documentation.md integration_documentation.md docs lib web supabase .github netlify.toml functions/package.json functions/src --glob '!functions/node_modules/**' --glob '!functions/lib/**' || true

git ls-files | rg '(^|/)\.env($|\.)|\.env'
```

GitHub / Netlify scanning notes:

- Enable GitHub secret scanning and push protection for the repository if the plan supports it.
- Keep Netlify secrets scanning enabled.
- `netlify.toml` intentionally omits only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from Netlify secret scanning because Flutter Web embeds public client configuration.
- Never add service role keys, database passwords, JWT secrets or private tokens to Netlify `SECRETS_SCAN_OMIT_KEYS`.

## 2.1 CI Security Checks

GitHub Actions now includes a dedicated `security-audit` job in `.github/workflows/ci_cd.yml`. The build/test/deploy job depends on it through `needs: security-audit`, so production deployment is blocked when a security gate fails.

CI security gates:

- `Secret scanning grep gate` searches executable and configuration surfaces for blocked Supabase secret markers.
- `Block real env files and macOS metadata` fails on real `.env*` files, except `.env.example`, and on `.DS_Store`.
- `Dart dependency check` runs `flutter pub outdated`.
- `npm dependency audit for historical Functions package` runs `npm ci` and `npm audit --audit-level=moderate` when `functions/package-lock.json` exists.
- The build job still runs `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test` and `flutter build web --release`.

The grep gate intentionally scans runtime/configuration paths rather than documentation prose. This allows audit documents to name forbidden markers as examples while still blocking accidental use in Flutter code, Supabase files, Netlify Functions, GitHub Actions and deployment config.

## 3. Findings

| ID | Severity | Area | Finding | Status |
|---|---|---|---|---|
| SEC-001 | High | Supabase RLS | Posts could be inserted with `author_id = auth.uid()` but a `pet_id` owned by another user. | Fixed |
| SEC-002 | Medium | Supabase RLS | `posts_read_authenticated` ignored `visibility`, so private posts could be read by any authenticated user through direct API access. | Fixed |
| SEC-003 | Medium | Supabase RLS | Comments and likes inherited no post visibility check. | Fixed |
| SEC-004 | Low | Supabase RLS | Users could join non-active walks if they inserted directly into `walk_participants`. | Fixed |
| SEC-005 | Medium | Dependencies | `npm audit` reported moderate `uuid` advisory through Firebase Functions transitive dependencies. | Fixed |
| SEC-006 | Low | OAuth redirects | Local Supabase redirect config used an `https://127.0.0.1:3000` URL and did not document exact Netlify redirect in local config. | Fixed |
| SEC-007 | Low | Secrets hygiene | Ignored local `.env.deploy` contains real local deployment values. It is not tracked, but must not be copied into docs or commits. | Documented |
| SEC-008 | Low | Flutter Web | `web/index.html` loads an external Corbado/passkeys bundle required by the current web auth setup. This is a supply-chain/CSP consideration rather than direct XSS in app code. | Remaining risk |

## 4. Fixes Applied

RLS hardening in `supabase/migrations/002_rls_policies.sql`:

- `posts_read_authenticated` now allows public posts or the author's own posts only.
- `posts_insert_own` and `posts_update_own` now require the referenced pet to belong to `auth.uid()`.
- `comments_read_authenticated`, `comments_insert_own`, `post_likes_read_authenticated` and `post_likes_insert_own` now check the target post is visible to the current user.
- `walk_participants_insert_self` now requires the target walk to be active.

Dependency fix in `functions/package.json` / `functions/package-lock.json`:

- Updated historical Firebase Functions dependency path to compatible `firebase-admin` version.
- Added npm `overrides.uuid` to force a patched `uuid` version.
- Re-ran `npm install`, `npm audit` and `npm run build`.

OAuth redirect fix in `supabase/config.toml`:

- Replaced the incorrect local HTTPS redirect with exact local HTTP redirects.
- Added the exact production Netlify URL.
- No wildcard redirect URLs were added.

## 5. Validation Results

```text
flutter pub outdated
```

Result: completed. Some Flutter packages have newer resolvable or latest versions. No direct security advisory is reported by this command. Major upgrades such as Riverpod/go_router should be planned separately because they can require API changes.

```text
flutter analyze
```

Result: `No issues found!`

```text
cd functions && npm audit
```

Initial result: moderate `uuid` advisory through Firebase Functions transitive dependencies.

Final result after dependency fix: `found 0 vulnerabilities`.

```text
cd functions && npm run build
```

Result: TypeScript build passed.

```text
supabase db lint
```

Result: failed to connect to local Postgres on `127.0.0.1:54322`. Run `supabase start` or `supabase db reset` locally, then repeat `supabase db lint`.

## 6. Security Review Details

### Hardcoded Secrets

Tracked source and documentation do not contain real service role keys, `sb_secret_` values, live payment keys, Google API keys or JWT-like Supabase publishable keys.

The exact requested grep command also scans generated/ignored directories if they exist locally. On this machine it detected ignored local environment material and dependency files. The tracked-source scan showed only documentation mentions and Supabase CLI comments, not real secrets.

### `.env` In Git

`git ls-files` shows only `.env.example`. `.gitignore` excludes `.env` and `.env.*` while explicitly allowing `.env.example`.

### Supabase Keys

Frontend configuration uses:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

No `SUPABASE_SERVICE`, service role key or `sb_secret_` usage was found in Flutter frontend code, Netlify config or GitHub Actions.

The publishable key is public browser configuration. It must not be treated as the data security boundary; Supabase Auth sessions, PostgreSQL RLS and Storage policies are the security boundary.

### RLS

RLS is enabled for all application tables:

- `profiles`
- `pets`
- `posts`
- `comments`
- `post_likes`
- `walks`
- `walk_participants`
- `chats`
- `chat_participants`
- `messages`

Storage buckets are private and Storage policies require authenticated access and owner-prefixed paths for writes.

### OAuth Redirect URLs

Local `supabase/config.toml` now uses exact redirect URLs:

- `http://localhost:3000`
- `http://127.0.0.1:3000`
- production Netlify URL

Hosted Supabase Dashboard must be checked manually before final handoff to confirm the exact production frontend URL is present and no wildcard redirect is used.

### Flutter Web XSS

No direct DOM sinks were found in `lib/`:

- no `dart:html`
- no `innerHtml` / `setInnerHtml`
- no `eval`
- no `HtmlElementView`
- no manual JavaScript interpolation of user content

Flutter text widgets render user content as text, not HTML. The remaining web risk is the external Corbado/passkeys script in `web/index.html`; keep it pinned to an exact version and consider adding a tested CSP after verifying Flutter Web runtime requirements.

### SQL Injection

Supabase repositories use the typed Supabase client query builder with `.from()`, `.select()`, `.eq()`, `.insert()`, `.delete()` and `.inFilter()`. No raw SQL string concatenation or client-controlled RPC SQL was found in Flutter code.

### Insecure Logging

Flutter Supabase logging is debug-only and logs operation/status/code/type, not access tokens, passwords or full error payloads.

Historical Firebase Functions logs request method/path/query, UID and resource IDs. Authorization headers and tokens are not logged. This branch is not the current production backend.

## 7. OWASP Top 10 Mapping

| OWASP area | PetConnect audit result |
|---|---|
| Injection | No raw SQL concatenation found. Supabase client query builder is used. RLS checks were tightened for indirect object reference style risks. |
| Broken Auth | Supabase Auth is the target identity provider. Frontend does not use service role keys. Redirect URLs now use exact values. |
| Sensitive Data Exposure | No tracked real secrets found. `.env.*` is ignored. Publishable key is documented as public client config, not a secret. |
| Security Misconfiguration | RLS is enabled on all app tables. Redirect URL config and RLS policy gaps were fixed. Supabase lint still needs local DB running. |
| XSS | No direct HTML/DOM injection found in Flutter code. External script remains a supply-chain/CSP risk to monitor. |

## 8. Remaining Risks

- Re-run `supabase db lint` and `supabase db reset` with local Supabase running.
- Verify hosted Supabase Auth redirect URLs in Dashboard before final submission.
- Consider adding a tested Content Security Policy for Flutter Web after confirming CanvasKit/passkeys/Supabase runtime needs.
- Consider removing historical Firebase Functions from production deployment scope or clearly marking it as archived if it is not needed for HW5/HW6.
- Plan Flutter dependency upgrades separately; `flutter pub outdated` shows several major-version updates that may require code changes.
- Keep local `.env.deploy` private and rotate any value immediately if it is accidentally pasted into docs, screenshots or commits.
