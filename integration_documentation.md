# PetConnect Integration Documentation

## Purpose

This document describes service integrations added for HW6, "CI/CD and service integration". It is safe for git: it contains no real Netlify tokens, Supabase publishable keys, service role keys, database passwords or private access tokens.

Current production stack:

| Layer | Service |
|---|---|
| Frontend | Flutter Web |
| Backend | Supabase Auth, PostgreSQL, RLS, Storage and auto REST API |
| Hosting | Netlify |
| CI/CD | GitHub Actions |
| Analytics | Yandex Metrica |
| AI development agent | OpenAI Codex |

## Google OAuth Through Supabase Auth

PetConnect supports Google OAuth2 login through Supabase Auth. The Flutter app does not store Google provider credentials. It calls Supabase with `OAuthProvider.google`, Supabase handles the Google provider configuration, and the browser returns to the configured production or localhost redirect URL.

OAuth flow:

```text
Login screen -> Supabase Auth Google provider -> Google consent
  -> Supabase Auth callback -> Netlify/local redirect URL
  -> Supabase session restore -> go_router authenticated redirect to /
```

Manual setup:

1. Supabase Dashboard -> `Authentication` -> `Providers` -> `Google`.
2. Enable Google provider.
3. Paste Google OAuth Client ID.
4. Paste Google OAuth Client Secret only in Supabase Dashboard.
5. Supabase Dashboard -> `Authentication` -> `URL Configuration`.
6. Set Site URL to `https://cool-duckanoo-d28d04.netlify.app/`.
7. Add Redirect URLs:

```text
https://cool-duckanoo-d28d04.netlify.app/
http://localhost:3000/
http://127.0.0.1:3000/
```

8. Google Cloud Console -> OAuth client -> Authorized redirect URIs: add the Supabase callback URL from the provider screen:

```text
https://<project-ref>.supabase.co/auth/v1/callback
```

Security notes:

- Google Client Secret is stored only in Supabase Dashboard and Google Cloud Console.
- Google Client Secret is not committed to git, added to docs, passed through `--dart-define`, or stored in Netlify/GitHub frontend secrets.
- Production redirect URL must match the Netlify URL exactly.
- Localhost redirect URL is used only for development.
- A production callback to `http://localhost:3000/?code=...` means Supabase Dashboard Site URL or the deployed Flutter build still points at localhost. Set the Site URL and production `SUPABASE_AUTH_REDIRECT_URL` to the Netlify URL, rebuild, and redeploy.

## CI/CD

Workflow file:

```text
.github/workflows/ci_cd.yml
```

Triggers:

- `pull_request`: validates code quality, tests and release build before merge;
- `push` to `main`: validates code quality, tests, release build and deploys to Netlify production.

Pipeline stages:

1. Run `security-audit` before build/deploy.
2. Checkout repository with `actions/checkout`.
3. Install Flutter stable with `subosito/flutter-action`.
4. Restore Flutter cache through the setup action.
5. Run `flutter pub get`.
6. Run secret scanning grep and repository hygiene gates.
7. Run dependency checks.
8. Run `dart format --set-exit-if-changed .`.
9. Run `flutter analyze`.
10. Run `flutter test`.
11. Build Flutter Web release with Supabase dart-defines.
12. Deploy `build/web` to Netlify only on `push` to `main`.

Security audit gates:

```bash
flutter pub outdated
npm ci
npm audit --audit-level=moderate
```

The grep gate fails when blocked Supabase secret markers are found in executable/configuration surfaces such as `.github`, `lib`, `web`, `supabase`, `netlify`, `functions` package files and deployment config. Documentation files can mention forbidden marker names as examples, but real secret values must never be pasted there.

The file hygiene gate fails when the CI workspace contains:

- real `.env*` files except `.env.example`;
- `.DS_Store` files.

The `build-test-deploy` job has `needs: security-audit`, so Netlify deployment cannot start until these checks pass.

Build command:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=${{ secrets.SUPABASE_PUBLISHABLE_KEY }} \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=https://cool-duckanoo-d28d04.netlify.app/ \
  --dart-define=ANALYTICS_ENABLED=${{ vars.ANALYTICS_ENABLED }} \
  --dart-define=ANALYTICS_PROVIDER=${{ vars.ANALYTICS_PROVIDER }} \
  --dart-define=YANDEX_METRICA_COUNTER_ID=${{ vars.YANDEX_METRICA_COUNTER_ID }}
```

Deploy command:

```bash
npx --yes netlify-cli@latest deploy \
  --prod \
  --dir=build/web \
  --site="$NETLIFY_SITE_ID" \
  --auth="$NETLIFY_AUTH_TOKEN"
```

## GitHub Secrets

Add these values in GitHub repository settings under Actions secrets:

| Secret | Required for | Notes |
|---|---|---|
| `NETLIFY_AUTH_TOKEN` | Netlify production deploy | Private token, never commit |
| `NETLIFY_SITE_ID` | Netlify production deploy | Site identifier, keep in CI settings |
| `SUPABASE_URL` | Flutter Web release build | Public client config, managed as CI env |
| `SUPABASE_PUBLISHABLE_KEY` | Flutter Web release build | Public client config, managed as CI env |

Do not add Supabase service role key, database password, JWT secret or private access tokens to the frontend CI/CD workflow.

Add these values in GitHub repository settings under Actions variables:

| Variable | Required for | Notes |
|---|---|---|
| `ANALYTICS_ENABLED` | Flutter Web release build | Use `true` for production analytics or `false` for disabled builds |
| `ANALYTICS_PROVIDER` | Flutter Web release build | Current value: `yandex_metrica` |
| `YANDEX_METRICA_COUNTER_ID` | Flutter Web release build | Public Yandex Metrica counter id, never hardcode in git |

Netlify UI must contain the same frontend build environment variables:

| Variable | Value |
|---|---|
| `SUPABASE_URL` | `<your-supabase-url>` |
| `SUPABASE_PUBLISHABLE_KEY` | `<your-supabase-publishable-key>` |
| `ANALYTICS_ENABLED` | `true` or `false` |
| `ANALYTICS_PROVIDER` | `yandex_metrica` |
| `YANDEX_METRICA_COUNTER_ID` | `<your-yandex-metrica-counter-id>` |

## Analytics Setup

PetConnect Flutter Web uses Yandex Metrica for product analytics.

Provider:

```text
yandex_metrica
```

Production counter id:

```text
<your-yandex-metrica-counter-id>
```

Production frontend URL:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

The Flutter app reads analytics configuration from build-time `dart-define` values:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=ANALYTICS_ENABLED=true \
  --dart-define=ANALYTICS_PROVIDER=yandex_metrica \
  --dart-define=YANDEX_METRICA_COUNTER_ID=<your-yandex-metrica-counter-id>
```

Set these as Netlify environment variables or GitHub repository variables:

| Variable | Value |
|---|---|
| `ANALYTICS_ENABLED` | `true` for production tracking, `false` for local/no-op builds |
| `ANALYTICS_PROVIDER` | `yandex_metrica` |
| `YANDEX_METRICA_COUNTER_ID` | `<your-yandex-metrica-counter-id>` |

`web/index.html` contains a small loader function named `petconnectTrackAnalytics`. It does not hardcode the counter id. The Flutter analytics service calls this function only when analytics is enabled and the provider/id are configured. The loader then initializes Yandex Metrica and sends `reachGoal` events.

Implemented events:

| Event | Trigger | Parameters |
|---|---|---|
| `app_open` | Flutter app starts | none |
| `sign_up_started` | Registration controller starts sign-up | none |
| `sign_in_success` | Email, post-sign-up or Google sign-in succeeds | `method` |
| `feed_opened` | Feed screen is opened | none |
| `search_performed` | Feed search query changes after debounce | `surface`, `query_length`, `has_query` |
| `feed_filter_changed` | Feed search filter changes | `has_query` |
| `walk_filter_changed` | Walk date/location/status filters change | `status`, `has_date`, `has_location` |
| `post_created` | Post creation succeeds | `text_length`, `has_image` |
| `post_liked` | A post is successfully liked | none |
| `comment_added` | Comment creation succeeds | `text_length` |
| `walk_joined` | User successfully joins a walk | none |
| `auth_error` | Auth operation fails | `operation`, `error_type`, optional `status_code`, `error_code` |
| `backend_error` | Feed, post, comment, like or walk backend operation fails | `operation`, `error_type`, optional `status_code`, `error_code` |

Privacy notes:

- Analytics events do not include email.
- Analytics events do not include raw user id, pet id, post id, walk id or comment id.
- Tokens, passwords, Supabase keys and OAuth secrets are never sent to analytics.
- Post and comment text is not sent; only coarse text length buckets such as `short`, `medium` or `long` are used.
- Search text and location text are not sent; analytics stores only coarse query length or boolean filter flags.
- The analytics service drops parameters with sensitive key names such as `email`, `user_id`, `token`, `password` and `secret`.
- When `ANALYTICS_ENABLED=false`, events are ignored in production mode and only locally logged in debug mode.

## Netlify Integration

Netlify remains the production frontend host:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

The GitHub Actions workflow deploys the already built Flutter Web artifact from:

```text
build/web
```

The repository also keeps `netlify.toml` for Netlify-compatible build settings and SPA redirect behavior. `build/web` remains ignored by git and must not be committed.

## Supabase Storage Integration

PetConnect exposes file storage through pet photo upload in Flutter Web.

Storage bucket:

```text
pet-images
```

The bucket uses public read because pet profile images are part of visible community profiles and Flutter Web can render the saved `pets.photo_url` directly with `Image.network`. Writes remain authenticated and owner-scoped by Storage policies.

Upload constraints:

- allowed extensions/content types: JPG, JPEG, PNG, WebP;
- maximum file size: 5 MB;
- path format: `<auth.uid()>/<pet-id>/<timestamp>-<safe-file-name>`;
- after upload, Flutter updates `public.pets.photo_url` through the Supabase client.

Manual setup:

```bash
supabase db push
```

Production deployment status on 23 June 2026: hosted Supabase project `fivtpxsjcjirddogngtl` has migrations `001`-`006` applied. The expected bucket `pet-images` exists, is public-read, and has authenticated owner/pet-scoped write/update/delete policies. Corrective migrations `005` and `006` hardened RLS drift and fixed Storage path policy qualification discovered during verification.

For hosted projects without CLI migration access, run pending SQL files from `supabase/migrations/` in order in the Supabase SQL Editor and confirm the `pet-images` bucket and policies in Dashboard -> Storage.

## Supabase CRUD Integration

PetConnect uses Supabase auto REST API through `supabase_flutter` repositories rather than a custom CRUD server.

Final required CRUD scenarios exposed in Flutter UI:

- pets: create, read list/details, update own profile, delete own profile;
- posts: create text post and delete own post;
- comments: create/read comments in feed cards;
- walks: create walk and read filtered walk list;
- walk participants: join active walk and leave joined walk.

Detailed CRUD/RLS evidence is maintained in `docs/crud_audit.md`. Owner-only actions are hidden in the UI when ownership is known, while PostgreSQL RLS remains the backend enforcement layer.

## Monitoring And Health Check

PetConnect exposes a production health endpoint through Netlify Functions:

```text
https://cool-duckanoo-d28d04.netlify.app/api/health
```

Implementation:

```text
netlify/functions/health.js
```

`netlify.toml` maps `/api/health` to `/.netlify/functions/health` before the Flutter SPA fallback. The endpoint returns JSON:

```json
{
  "status": "ok",
  "timestamp": "2026-06-19T00:00:00.000Z",
  "checks": {
    "app": { "status": "ok", "message": "Netlify Function is reachable." },
    "supabase_url": { "status": "ok", "message": "Supabase URL is configured." },
    "supabase_auth": { "status": "ok", "message": "Endpoint responded." },
    "supabase_rest": { "status": "ok", "message": "Endpoint responded." },
    "supabase_posts_query": { "status": "skipped", "message": "Optional posts query blocked by RLS/API grants." }
  },
  "version": "unknown"
}
```

Health statuses:

- `ok`: required checks passed;
- `degraded`: Supabase responds with an upstream issue or the optional DB query fails unexpectedly;
- `error`: required configuration is missing/invalid or required Supabase endpoints cannot be reached.

Security notes:

- the endpoint does not return environment values;
- the function never logs `SUPABASE_PUBLISHABLE_KEY`;
- no service role key is used;
- the optional table query uses only a publishable key and treats RLS/API-grant blocks as `skipped`, not as a data leak or hard failure.

Recommended monitor setup:

1. Create an UptimeRobot, Pingdom or Better Stack HTTP monitor.
2. Set the check URL to `https://cool-duckanoo-d28d04.netlify.app/api/health`.
3. Use method `GET`.
4. Use an interval of 5 minutes for free-tier monitoring.
5. Alert when HTTP status is not `200`.
6. If the monitor supports body matching, alert unless the response body contains `"status":"ok"` or `"status": "ok"`.
7. Route alerts to email, Telegram, Slack or the student's preferred channel.

Expected alert conditions:

- Netlify function unavailable;
- `SUPABASE_URL` missing or invalid in Netlify environment variables;
- Supabase Auth endpoint timeout or 5xx;
- Supabase REST endpoint timeout or 5xx;
- optional DB query returns an unexpected non-auth/non-RLS failure.

## Logging And AI Log Analysis

Detailed logging guide:

```text
docs/logging.md
```

PetConnect now uses structured JSON logs for app diagnostics and Netlify health checks. Flutter logs are centralized through `AppLogger` in `lib/core/logging/app_logger.dart`; `/api/health` logs JSON lines from `netlify/functions/health.js`.

Logged application events:

| Area | Events |
|---|---|
| Startup | `app_startup`, `app_startup_completed`, `app_startup_failed` |
| Supabase | `supabase_initialization_started`, `supabase_initialization_completed`, `supabase_request_error` |
| Auth | `auth_success`, `auth_failure` |
| Analytics | `analytics_not_configured`, `analytics_dispatch_error` |
| Health check | `health_check` JSON logs with `check`, `httpStatus`, `durationMs` and health status |

Privacy and safety:

- logs do not include tokens, passwords, service role keys, publishable keys, cookies or Authorization headers;
- logs do not include email addresses, raw user ids, display names, post text, comment text or chat messages;
- diagnostic payloads keep only operation names, status codes, error codes, exception class names, duration and safe boolean flags.

AI log analysis prompt templates are stored in `docs/logging.md` for:

- auth error analysis;
- RLS permission denied analysis;
- Netlify deploy failure analysis;
- Supabase API error analysis;
- analytics event missing analysis.

## Security Notes

- Pull requests run validation and build but do not deploy.
- Production deployment runs only for `push` to `main`.
- Secrets are referenced through GitHub Actions `${{ secrets.* }}` and are not written into repository files.
- `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are embedded into Flutter Web output by design; Supabase RLS and Storage policies remain the user-data security boundary.
- Netlify deploy uses `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` only inside the deploy step.

## Security Audit Summary

Full audit artifact:

```text
security_audit.md
```

Audit coverage:

- hardcoded secrets and tracked `.env` files;
- Supabase service role / `sb_secret_` exposure;
- publishable key usage in frontend-only configuration;
- RLS enablement and policy quality;
- OAuth redirect URL configuration;
- Flutter Web XSS and external script risks;
- Supabase query patterns for SQL injection risk;
- logging of tokens/secrets;
- Flutter and npm dependency checks.

Fixes applied during the audit:

- Supabase RLS now prevents creating posts with another user's pet and enforces post visibility for posts, comments and likes.
- Walk participation inserts now require an active walk.
- Local Supabase redirect URLs are exact local HTTP URLs plus the production Netlify URL.
- Historical Firebase Functions dependencies were updated so `npm audit` reports `found 0 vulnerabilities`.

Validation status:

```text
flutter analyze: passed
functions npm audit: passed
functions npm run build: passed
supabase db lint: blocked until local Supabase Postgres is running
```

## Local Validation

Before pushing, run:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=ANALYTICS_ENABLED=false
```

Use real Supabase values only through local ignored env files or shell environment. Do not paste them into documentation.

## Flutter Web Performance Notes

Performance review date: 19 июня 2026.

AI recommendations before final handoff:

- keep Flutter Web release builds tree-shaken and do not disable icon tree-shaking;
- keep analytics lazy: Yandex Metrica must load only after an enabled event is dispatched with configured provider/id;
- avoid verbose production logging from Flutter Web, especially startup and disabled-analytics events;
- avoid unnecessary Riverpod consumers in static UI widgets;
- keep Storage images constrained in pet cards/profile and preserve lightweight emoji placeholders for missing or failed images;
- keep the external Corbado/passkeys script pinned and loaded before Flutter because it is part of the current web auth workaround, but treat it as a startup/network risk to revisit after auth validation.

Applied safe optimizations:

- `AppLogger` now skips `info` logs in Flutter release mode while preserving `warning` and `error` diagnostics.
- Disabled analytics no longer emits an `analytics_disabled` log for every dropped event. If analytics is explicitly enabled but incomplete, it logs `analytics_not_configured` as a warning.
- `PetStoriesStrip` was changed from `ConsumerWidget` to `StatelessWidget` because it does not read providers.
- Analytics remains lazy in `web/index.html`: `https://mc.yandex.ru/metrika/tag.js` is inserted only by `petconnectTrackAnalytics` after Flutter dispatches an enabled event.

Validation results:

```text
dart format .: passed, 84 files checked, 0 changed
flutter analyze: passed, No issues found
flutter test: passed, 77 tests
flutter build web --release --dart-define=USE_SUPABASE_BACKEND=false --dart-define=ANALYTICS_ENABLED=false: passed
```

Release build observations:

```text
build/web: 41M
build/web/main.dart.js: 2.7M
MaterialIcons tree-shaken from 1,645,184 bytes to 11,376 bytes
```

Non-blocking build notes:

- Flutter reported wasm dry-run incompatibility from a transitive web dependency using `dart:html`; the normal JavaScript Flutter Web release build still succeeded.
- Flutter reported that CupertinoIcons font was referenced in dependency metadata but not bundled; PetConnect uses Material icons and `uses-material-design: true`, so the release build remained successful.
