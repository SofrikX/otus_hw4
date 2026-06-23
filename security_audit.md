# PetConnect Security Audit

Date: 23 June 2026

Scope: final pre-submission security and performance audit for Flutter Web frontend, Supabase migrations/configuration, Supabase Storage, Netlify/GitHub Actions configuration, Yandex Metrica analytics, health endpoint, historical Firebase Functions package dependencies and project documentation.

## 1. Summary

This final audit checked PetConnect for hardcoded secrets, frontend exposure of Supabase keys, Google OAuth secret leakage, Yandex Metrica privacy, RLS coverage, CRUD authorization, Storage upload risks, OAuth redirect configuration, Flutter Web XSS risks, SQL injection risks, insecure logging, dependency vulnerabilities and production readiness/performance issues.

Overall result:

- No tracked service role key, `sb_secret_`, live payment key, Google API key or real token-like Supabase publishable key was found in tracked source or documentation.
- `.env.example` is tracked intentionally; real `.env` files are ignored by `.gitignore`.
- A local ignored `.env.deploy` exists and contains local deployment values, including a public Supabase frontend key. It is not tracked by git and should stay local.
- No Google Client Secret was found in tracked source or documentation. The docs correctly route it to Supabase Dashboard and Google Cloud Console only.
- Yandex Metrica integration uses a build-time counter id, lazy loader and coarse event params. The final code hardening now drops broad raw identifiers and user-content-style analytics keys such as `*_id`, `raw_id`, `*_text`, `content` and `display_name`.
- RLS is enabled for all PetConnect application tables in `supabase/migrations/002_rls_policies.sql`.
- Service role keys are not used by Flutter frontend code, Netlify config or GitHub Actions.
- Supabase publishable key is used only as frontend client configuration through `--dart-define` / CI env.
- Netlify/GitHub Actions use secrets only from CI/provider settings. `netlify.toml` omits only public browser configuration keys from Netlify secret scanning.
- The health endpoint returns status/check metadata and does not return Supabase URL, publishable key, service role key or environment values.
- Production info-log volume is constrained: Flutter `AppLogger.info` is skipped in release mode; analytics disabled mode is silent; health check logs are structured and sanitized.
- `flutter analyze` and `flutter test` must be re-run after this final audit; the validation section records current command results.
- `npm audit` initially found a moderate vulnerability chain in the historical Firebase Functions dependencies. It was fixed by updating `firebase-admin` within the compatible peer range and adding a `uuid` override.
- `supabase db lint` could not run because local Supabase Postgres was not running on `127.0.0.1:54322`; this is an environment blocker, not a SQL lint result.

Files inspected included `README.md`, `project_documentation.md`, `ai_development_process.md`, `final_project_gap_analysis.md`, `user_stories.md`, `technical_specification.md`, `backend_documentation.md`, `integration_documentation.md`, `development_report.md`, `prompts.md`, `docs/`, `.github/workflows/`, `netlify.toml`, `netlify/functions/`, `supabase/migrations/`, `lib/`, `test/`, `pubspec.yaml` and `pubspec.lock`.

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
| SEC-009 | Medium | File upload | Pet photo upload can introduce oversized files, unexpected file types or public profile image exposure if unconstrained. | Mitigated |
| SEC-010 | Low | Analytics privacy | Analytics sanitizer previously blocked obvious secret/user keys but not all raw id or content-style keys. | Fixed |
| SEC-011 | Low | Documentation consistency | Some older documentation still referred to the previous bright UI direction while final UX is premium dark. | Documented |

## 3.1 Final Security Audit Findings

| Area | Result |
|---|---|
| Hardcoded secrets | No tracked service role key, `sb_secret_`, `SUPABASE_SERVICE`, live key, Google API key or Google Client Secret value found. Matches are documentation examples or sanitizer code. |
| `.env` files | Only `.env.example` is tracked. Local `.env.deploy` exists and remains ignored; keep it out of screenshots, prompts and commits. |
| Supabase key naming | Runtime uses `SUPABASE_PUBLISHABLE_KEY`. Legacy `SUPABASE_ANON_KEY` appears only in documentation as a deprecated naming note. |
| Google OAuth | Flutter code does not store provider secret. Dashboard must keep exact Netlify and localhost redirects; no wildcard redirect was added in repo config. |
| Yandex Metrica | Counter id is public config; event params are coarse. Sanitizer now drops broad id/content/name/text keys before dispatch. |
| RLS and CRUD auth | RLS is enabled on application tables. Owner writes are enforced for pets/posts/walks/participants and chat reads are participant-scoped. UI owner checks are UX only; RLS is the security boundary. |
| Storage upload | Pet image upload validates extension/content type and 5 MB max client-side; Storage policies require authenticated owner/pet-scoped paths. Public read is accepted for public pet profile photos. |
| Logs | Flutter release skips info logs. Warnings/errors and health logs are structured and sanitized. No tokens, email, raw ids or user-generated content should be logged. |
| Health endpoint | `/api/health` reports check status, HTTP status and duration only. It does not return environment values. Optional posts query uses publishable key only. |
| Netlify/GitHub Actions | Secrets are consumed via provider secret stores. Netlify secret scan omit list contains only public browser config keys. |

## 3.2 Final Performance Audit Findings

| Area | Result |
|---|---|
| Flutter Web build size | Previous release observation: `build/web` around 41 MB and `main.dart.js` around 2.7 MB with Material icons tree-shaken. Re-check after final audit with a release build if production bundle size is required in the submission. |
| Premium dark redesign | No broad architecture rewrite was introduced. The redesign uses shared widgets/tokens and existing Riverpod controllers. Remaining risk is visual complexity increasing widget cost on low-end devices; browser QA should include mobile viewport checks. |
| Rebuilds | Static story strip had already been changed away from unnecessary provider subscription. Current `ConsumerWidget`/`ref.watch` usage is concentrated around async screens, auth state and filters. |
| Production logs | `AppLogger.info` is skipped in release mode, disabled analytics is silent and health logs are concise. Keep additional diagnostics out of release unless warning/error only. |
| Images | Pet images use constrained `Image.network` rendering and emoji/gradient placeholders for missing images. Upload size is capped at 5 MB. Post images remain placeholder/future scope. |
| Analytics overhead | Yandex Metrica script is lazy-loaded only after an enabled event with configured provider/id. Disabled analytics does not dispatch or log. |
| Search/filter performance | Feed/pet/walk filters use controller/provider state and bounded repository queries. Feed search operates on the RLS-visible feed result set; current MVP limits reduce client cost. |
| Responsive UI | Mobile bottom navigation and desktop navigation rail remain. Manual QA should re-check `390x844`, `768x1024` and `1440x900` after final redeploy. |
| Health endpoint | Netlify function performs bounded 5s fetches and a limit-1 optional posts query. It should not become a heavy synthetic transaction. |

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

Analytics privacy hardening in `lib/core/analytics/analytics_service.dart`:

- Event params now drop broad raw identifier keys such as `id`, `*_id` and `raw_id`.
- Event params now drop user-content-style keys such as `text`, `*_text`, `content`, `name`, `*_name` and `display_name`.
- Existing safe coarse params such as `text_length`, `query_length`, `has_query`, `status_code`, `error_code`, `method` and boolean filter flags remain allowed.

## 5. Validation Results

```text
flutter pub get
```

Result: passed. 25 packages have newer versions incompatible with current constraints; this is a dependency freshness item, not a blocking audit failure.

```text
dart format --set-exit-if-changed .
```

Result: passed, 99 files checked, 0 changed.

```text
flutter analyze
```

Result: passed, `No issues found!`.

```text
flutter test
```

Result: passed, 110 tests.

```text
flutter build web --release --dart-define=USE_SUPABASE_BACKEND=false --dart-define=ANALYTICS_ENABLED=false
```

Result: passed and built `build/web` without production secrets. Non-blocking warnings remained for future WebAssembly compatibility from transitive `ua_client_hints` using `dart:html`, and a CupertinoIcons font metadata warning. The normal JavaScript Flutter Web release build succeeded.

```text
tracked-source secret scan
```

Result: no real service role key, `sb_secret_`, Google Client Secret, private token or hardcoded production credential found. Matches were documentation examples, Supabase CLI comments, health/logger sanitizer code or deprecated naming notes.

```text
supabase db lint
```

Result: not re-run in this final pass because local Supabase services were not part of the requested Flutter validation run. Previous note remains: run `supabase start` or `supabase db reset` locally, then repeat `supabase db lint`.

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

The pet photo bucket `pet-images` intentionally uses public read for simple profile photo rendering in Flutter Web. Write/update/delete policies require authenticated owner-scoped paths and verify that the path pet id belongs to `auth.uid()`. Flutter rejects unsupported file types and files larger than 5 MB before upload.

### CRUD Ownership Review

The final CRUD pass added Flutter UI actions for create/update/delete pets, delete own posts, create walks and leave joined walks. These actions are owner-aware in the UI when ownership is available, but PostgreSQL RLS remains the security boundary:

- pet update/delete is protected by `pets_update_own` and `pets_delete_own`;
- post delete is protected by `posts_delete_own`;
- walk creation is protected by `walks_insert_own`;
- walk leave deletes only the current user's `walk_participants` row through `walk_participants_delete_self`.

No RLS policy was disabled, no service role key was added and no allow-all policy was introduced.

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

### File Upload Risks

Risks:

- arbitrary file upload;
- oversized files affecting storage quota and UX;
- public profile photo URLs being shared outside the app;
- users overwriting another pet's image path.

Mitigations:

- Flutter Web picker and validation allow only JPG/JPEG/PNG/WebP;
- max file size is 5 MB;
- file bytes are not logged;
- Storage paths include `<auth.uid()>/<pet-id>/...`;
- Storage policies check that `<pet-id>` belongs to `auth.uid()`;
- `pets.photo_url` updates go through RLS-protected `pets_update_own`;
- no service role key is used in frontend upload.

## 7. OWASP Top 10 Review

| OWASP area | PetConnect audit result | Status |
|---|---|---|
| Injection | Flutter repositories use Supabase query builder methods such as `.select()`, `.eq()`, `.insert()`, `.update()`, `.delete()` and a manually escaped `ilike` location filter. No raw SQL concatenation or client-controlled SQL RPC was found in Flutter code. | No blocking finding |
| Broken Authentication | Supabase Auth is the identity provider for email/password and Google OAuth. Flutter stores no Google Client Secret and no service role key. OAuth redirect URLs must remain exact in Supabase Dashboard. | Manual redirect verification remains |
| Broken Access Control | RLS is enabled on all application tables. Corrective policies prevent using another user's pet for posts, restrict private/deleted post visibility for comments/likes and require active walks for joins. Owner-only UI is not treated as the security boundary. | No blocking finding |
| Sensitive Data Exposure | No tracked private credentials were found. `.env.deploy` is local/ignored. Logs and analytics sanitizers remove tokens, emails, raw ids and user content; the final audit hardened analytics key filtering further. | Local secret hygiene remains |
| Security Misconfiguration | Netlify/GitHub Actions use provider secrets, SPA routing is configured, health endpoint avoids env leakage and Netlify secret scan omit list contains public browser config only. Supabase local lint/reset still require local services. | Manual environment checks remain |
| XSS | No `innerHtml`, `setInnerHtml`, `eval` or user-controlled DOM insertion was found in `lib/`. Analytics loader parses only app-generated JSON params. External scripts remain a CSP/supply-chain consideration. | Remaining risk |
| Vulnerable Components | Flutter dependency audit uses `flutter pub outdated`; historical Firebase Functions package is covered by `npm audit` in CI when lockfile exists. Major Flutter package upgrades should be planned separately. | Monitor |
| Logging and Monitoring | `AppLogger.info` is disabled in release mode; warnings/errors are structured and sanitized. `/api/health` gives monitoring signal without secrets. No penetration test or external uptime monitor is claimed by this audit. | No blocking finding |

## 8. Remaining Risks

- Production Supabase RLS and Storage policies were re-verified on 23 June 2026 after applying corrective migrations `005` and `006`; re-run `supabase db lint` and `supabase db reset` with local Supabase running for local validation.
- Verify hosted Supabase Auth redirect URLs in Dashboard before final submission.
- Consider adding a tested Content Security Policy for Flutter Web after confirming CanvasKit/passkeys/Supabase runtime needs.
- Keep historical Firebase Functions outside the production deployment scope or clearly mark them as archived/reference-only material.
- Plan Flutter dependency upgrades separately; `flutter pub outdated` shows several major-version updates that may require code changes.
- Keep local `.env.deploy` private and rotate any value immediately if it is accidentally pasted into docs, screenshots or commits.
