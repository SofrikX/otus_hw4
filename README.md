# PetConnect

PetConnect - Flutter-приложение для владельцев домашних животных. MVP включает социальную ленту питомцев, профили питомцев, прогулки, присоединение к прогулкам и базовый чат-сценарий.

Текущая сдача относится к ДЗ 5: backend deployment and integration with Frontend. Frontend MVP подключается к Supabase backend через repository layer и Riverpod controllers. Mock repositories сохранены для локального запуска, тестов и постепенной миграции.

README может содержать публичный Supabase Project URL для production frontend, но не содержит реальных `SUPABASE_PUBLISHABLE_KEY`, secret key, service role key, database password, access token или production user data.

## Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| State management | Riverpod / `flutter_riverpod` |
| Routing | `go_router` |
| UI | Material 3 |
| Auth | Supabase Auth |
| Database | PostgreSQL |
| Security | Row Level Security |
| Storage | Supabase Storage |
| API | Supabase REST API / Flutter SDK `supabase_flutter` |
| Tests | `flutter_test`, `mocktail` |

## Why Supabase Instead Of Firebase

Firebase was researched first because the earlier PetConnect technical specification used Firebase Auth, Firestore, Firebase Storage, Security Rules and Cloud Functions.

For the final HW5 backend decision, PetConnect uses Supabase Free Tier instead:

- the original homework allows Supabase as a backend option;
- Firebase Cloud Functions production deploy can require the Blaze/pay-as-you-go plan;
- the homework needs a free and reproducible BaaS setup;
- Supabase gives reviewable SQL migrations, PostgreSQL constraints, Row Level Security and auto REST API;
- `supabase_flutter` lets the app keep its existing repository-based architecture.

Mapping:

| Firebase research branch | Final Supabase backend |
|---|---|
| Firebase Auth | Supabase Auth |
| Cloud Firestore | PostgreSQL tables |
| Firebase Security Rules | Row Level Security policies |
| Cloud Functions API | Supabase REST API / Flutter SDK |
| Firebase Storage | Supabase Storage |

## Main Features

- Email/password sign up, sign in and sign out through Supabase Auth in backend mode.
- Google OAuth sign in through Supabase Auth. Google Client ID and Client Secret are configured only in Supabase Dashboard, not in Flutter code.
- Protected routing with `go_router` and Riverpod auth state.
- Pet social feed with posts, likes, comments and owner-only post deletion.
- Debounced feed search by post text, author name and pet name.
- Pet profiles with create/read/update/delete owner actions and Supabase Storage photo upload/display.
- Pet list search by name and filter chips by animal type.
- Walk list, walk creation and join/leave flow.
- Walk filters by date, place/location and status: upcoming, completed or all.
- Basic chat data model for chat list and messages.
- Friendly loading, empty, error and success states through controllers/providers.
- Final UI polish for responsive bottom sheets, inline form validation, disabled submit/progress states and retryable empty/error states.
- Mock mode for local UI checks and tests without Supabase credentials.

## Final project scope

PetConnect is being prepared as the final portfolio project for the course "Разработка полнофункционального веб-приложения с использованием AI-агентов".

Final positioning: PetConnect is a full-stack Flutter Web application for pet owners. Users can authenticate, create and view pet profiles, publish posts, react with likes/comments, discover walks, join pet activities and use a basic chat scenario.

Final project scope:

- frontend: Flutter Web, Material 3, responsive layout, interactive auth/feed/pets/walks/chat flows and loading/error/empty/success states;
- backend: Supabase Auth, Google OAuth, PostgreSQL, RLS, Storage and auto REST API through `supabase_flutter`;
- data model: connected tables for profiles, pets, posts, comments, likes, walks, walk participants, chats, chat participants and messages;
- integrations: Netlify hosting, GitHub Actions CI/CD, Yandex Metrica analytics, health check endpoint and structured logging;
- quality: Flutter tests, Supabase SQL/RLS validation plan, security audit, CI security gates and performance optimization notes;
- AI process: OpenAI Codex is used for planning, user stories, technical specification, frontend/backend development, testing, debugging, CI/CD, security audit, log analysis and performance review.

Final project documents:

- `project_documentation.md` - product positioning, scope, architecture and requirement coverage;
- `ai_development_process.md` - how AI agents were used and will be used in the final project;
- `backend_documentation.md` - Supabase backend architecture, schema, RLS, Storage and API;
- `integration_documentation.md` - Google OAuth, CI/CD, analytics, Netlify and monitoring;
- `security_audit.md` - security findings, fixes and remaining risks.
- `docs/crud_audit.md` - CRUD matrix for pets, posts, comments, walks, walk participants and profiles.

## Backend Architecture

```text
Flutter UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase or mock repository implementations
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Database source of truth:

```text
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_rls_policies.sql
supabase/migrations/003_api_grants.sql
supabase/migrations/004_pet_images_storage.sql
supabase/migrations/005_harden_remote_rls_policies.sql
supabase/migrations/006_fix_pet_images_storage_policy_path.sql
```

Application tables:

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

Storage buckets:

- `avatars`
- `pet-photos`
- `pet-images`
- `post-images`

RLS model:

- authenticated users can read application data needed for the MVP;
- users can insert/update/delete only their own profile, pets, posts, likes, comments and walk participation rows;
- walk creators manage their own walks;
- chat rows and messages are visible only to chat participants;
- Storage writes require paths like `<auth.uid()>/<file-name>`.
- `pet-images` uses public read for profile photo rendering and authenticated owner-scoped writes to `<auth.uid()>/<pet-id>/<file-name>`.

More details:

- `backend_documentation.md`
- `docs/backend_deployment_checklist.md`
- `docs/production_backend_verification.md`
- `docs/frontend_deployment.md`
- `docs/supabase_setup.md`
- `docs/database_schema.md`
- `docs/supabase_security.md`
- `docs/api_spec.md`
- `docs/seed_data.md`

## Netlify Deployment

Production frontend hosting: **Netlify Free**.

PetConnect production deployment is split into two parts:

| Layer | Production target |
|---|---|
| Backend | Supabase Auth, PostgreSQL, RLS, Storage and auto REST API |
| Frontend | Flutter Web static release build |
| Frontend hosting | Netlify Free |

Planned production repository/branch:

```text
https://github.com/SofrikX/otus_hw4/tree/hw5-sb
```

Planned Supabase project URL for the production frontend:

```text
https://<project-ref>.supabase.co
```

Flutter Web is a good fit for Netlify because the release build is static and can be served from a CDN-like static host without a custom server. Supabase stays responsible for auth, database, storage and RLS-protected API operations.

The repository contains `netlify.toml` so Netlify can build and publish the Flutter Web release from GitHub. If Git-based build is unavailable because the Netlify image does not include Flutter SDK, the fallback is a local `flutter build web --release` and manual upload of `build/web` in Netlify.

### Environment Variables In Netlify UI

Configure these variables in Netlify UI, not in repository files:

```text
SUPABASE_URL=<your-supabase-url>
SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
ANALYTICS_ENABLED=true
ANALYTICS_PROVIDER=yandex_metrica
YANDEX_METRICA_COUNTER_ID=<your-yandex-metrica-counter-id>
APP_VERSION=<optional-release-version-or-commit-sha>
```

`USE_SUPABASE_BACKEND=true` is passed directly by the build command. The real `SUPABASE_PUBLISHABLE_KEY` must stay in Netlify Environment Variables. Do not commit it to Git. Analytics values are public browser configuration; keep them in Netlify variables so production and local builds can enable or disable tracking independently.

Security model for Flutter Web:

- `SUPABASE_PUBLISHABLE_KEY` is public client configuration and can be embedded into the browser bundle.
- PetConnect does not rely on the publishable key as a secret. Database and Storage protection comes from Supabase Auth sessions, PostgreSQL RLS policies and Storage policies.
- Supabase secret keys and service role keys must never be passed through `--dart-define`, configured in Netlify frontend environment variables or committed to the repository.
- If a secret key or service role key is ever exposed, rotate it in Supabase before continuing deployment.
- `netlify.toml` omits `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from Netlify secrets scanning because Flutter Web embeds these public client settings into `build/web`. Do not add service role keys or database passwords to this omit list.
- Yandex Metrica receives only event names and coarse non-personal parameters. Do not add email, raw user id, tokens, post text, comment text or profile data to analytics params.

### Build Command

Netlify build command from `netlify.toml`:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=https://cool-duckanoo-d28d04.netlify.app/ \
  --dart-define=ANALYTICS_ENABLED=$ANALYTICS_ENABLED \
  --dart-define=ANALYTICS_PROVIDER=$ANALYTICS_PROVIDER \
  --dart-define=YANDEX_METRICA_COUNTER_ID=$YANDEX_METRICA_COUNTER_ID
```

### Analytics Configuration

PetConnect Flutter Web uses Yandex Metrica for product analytics. The app reads the counter id only from `--dart-define=YANDEX_METRICA_COUNTER_ID`.

Local disabled run:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=false \
  --dart-define=ANALYTICS_ENABLED=false
```

Local enabled run:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=false \
  --dart-define=ANALYTICS_ENABLED=true \
  --dart-define=ANALYTICS_PROVIDER=yandex_metrica \
  --dart-define=YANDEX_METRICA_COUNTER_ID=<your-yandex-metrica-counter-id>
```

`web/index.html` contains a small Yandex Metrica loader function. It does not hardcode the counter id and loads `https://mc.yandex.ru/metrika/tag.js` only after Flutter sends an enabled analytics event.

### Publish Directory

Flutter writes the production web build to:

```text
build/web
```

Netlify publish directory:

```text
build/web
```

### SPA Redirects

Flutter Web uses client-side routing, so Netlify must serve `index.html` for deep links. This rule is included in `netlify.toml`:

```toml
[[redirects]]
  from = "/api/health"
  to = "/.netlify/functions/health"
  status = 200
  force = true

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### Health Check

Production health endpoint:

```text
https://cool-duckanoo-d28d04.netlify.app/api/health
```

The endpoint is implemented as a Netlify Function in `netlify/functions/health.js`. It returns JSON with `status`, `timestamp`, `checks` and `version`.

Checks:

- Netlify Function is reachable;
- `SUPABASE_URL` is configured and valid;
- Supabase Auth endpoint responds;
- Supabase REST endpoint responds;
- optional `posts limit 1` query runs when a publishable key is available and RLS/API grants allow it.

The health response never returns Supabase URLs, publishable keys, service role keys or other environment values. The function uses structured JSON logs with `info`, `warning` and `error` levels and does not log `SUPABASE_PUBLISHABLE_KEY`.

If Netlify's build environment does not include Flutter SDK, build locally with the same `flutter build web --release ...` command and deploy the generated `build/web` directory manually through Netlify drag-and-drop.

The reviewer should receive a Netlify production URL and be able to open the deployed Flutter Web app in a browser. Real Supabase keys are not committed to the repository; the service role key is never used in the frontend.

## CI/CD Pipeline

GitHub Actions workflow:

```text
.github/workflows/ci_cd.yml
```

Pipeline triggers:

- `pull_request`: runs validation and Flutter Web release build;
- `push` to `main`: runs the same validation/build steps, then deploys `build/web` to Netlify production.

Security gate:

- separate `security-audit` job runs before build/test/deploy;
- grep gate fails on blocked secret markers in executable and configuration files;
- file gate fails when real `.env*` files, except `.env.example`, or `.DS_Store` files are present;
- dependency checks run `flutter pub outdated` and `npm audit --audit-level=moderate` for the historical Functions package when `functions/package-lock.json` exists.

Checks performed by CI:

```bash
flutter pub get
flutter pub outdated
npm ci
npm audit --audit-level=moderate
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=${{ secrets.SUPABASE_PUBLISHABLE_KEY }} \
  --dart-define=ANALYTICS_ENABLED=${{ vars.ANALYTICS_ENABLED }} \
  --dart-define=ANALYTICS_PROVIDER=${{ vars.ANALYTICS_PROVIDER }} \
  --dart-define=YANDEX_METRICA_COUNTER_ID=${{ vars.YANDEX_METRICA_COUNTER_ID }}
```

Deploy command on `push` to `main`:

```bash
npx --yes netlify-cli@latest deploy \
  --prod \
  --dir=build/web \
  --site="$NETLIFY_SITE_ID" \
  --auth="$NETLIFY_AUTH_TOKEN"
```

Required GitHub repository secrets:

| Secret | Purpose |
|---|---|
| `NETLIFY_AUTH_TOKEN` | Netlify CLI authentication for production deploy |
| `NETLIFY_SITE_ID` | Target Netlify site id |
| `SUPABASE_URL` | Public Supabase project URL passed to Flutter Web build |
| `SUPABASE_PUBLISHABLE_KEY` | Public Supabase publishable key passed to Flutter Web build |

Required GitHub repository variables:

| Variable | Purpose |
|---|---|
| `ANALYTICS_ENABLED` | Enables or disables frontend analytics, usually `true` in production and `false` in local smoke builds |
| `ANALYTICS_PROVIDER` | Analytics provider id, currently `yandex_metrica` |
| `YANDEX_METRICA_COUNTER_ID` | Public Yandex Metrica counter id |

Do not commit real secret values. `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are public Flutter Web client configuration, but they still belong in GitHub/Netlify environment settings for reproducible builds. Supabase service role key, database password and private tokens must not be added to GitHub Actions secrets for frontend deployment.

## How To Verify Production App

Production frontend URL:

```text
https://cool-duckanoo-d28d04.netlify.app
```

Production Supabase project URL:

```text
https://fivtpxsjcjirddogngtl.supabase.co
```

Final QA status on 18 June 2026: **not ready for teacher handoff until the frontend is redeployed**.

What passed:

- Netlify URL opens and returns the Flutter Web shell.
- Login screen renders after reload.
- Production bundle points to the expected Supabase project URL and uses a public publishable key, not a service role key.
- Supabase Auth login works for seeded demo users:
  - `demo.alina@petconnect-demo.com`
  - `demo.mark@petconnect-demo.com`
- Production database is not empty. Authenticated REST count checks returned seeded data for profiles, pets, posts, comments, likes, walks and walk participants.
- Supabase REST smoke checks passed for feed reads, creating a comment, creating a like and joining a walk.

Blocking issue found:

- After successful UI login, the deployed frontend currently turns into a blank white screen.
- Browser console shows `Null check operator used on a null value` and `Cannot read properties of undefined (reading 'init')` from `main.dart.js`.
- The likely cause is a web startup race where the external Corbado/passkeys bundle is not ready before Flutter/Supabase Auth web code initializes.
- Local fix applied in `web/index.html`: load the Corbado/passkeys script before `flutter_bootstrap.js`.
- Required next step: rebuild and redeploy Netlify from the fixed branch, then repeat the browser E2E scenario.

Reviewer smoke scenario after redeploy:

1. Open `https://cool-duckanoo-d28d04.netlify.app`.
2. Sign in with `demo.alina@petconnect-demo.com` / `DemoPass123!`.
3. Confirm the feed loads Supabase posts.
4. Create a post.
5. Like a post.
6. Add a comment.
7. Open a pet profile.
8. Open walks and join a walk using `demo.mark@petconnect-demo.com` if Alina is already joined to all walks.
9. Check mobile and desktop layouts.

Latest local UI polish validation:

```text
dart format .: passed, 88 files checked
flutter analyze: passed, No issues found
flutter test: passed, 98 tests
```

Registration troubleshooting:

- Fresh signup currently hit Supabase email sending rate limits during QA: `over_email_send_rate_limit`.
- For teacher validation, either use the seeded demo users above, confirm created users manually in Supabase Dashboard, or temporarily disable email confirmation for the demo window.
- If signup shows an email-format message, retry with a normal email domain and check Supabase Auth logs for rate-limit or confirmation errors.

## Supabase Setup

### 1. Create Project

1. Open Supabase Dashboard.
2. Create a new Free Tier project.
3. Choose a region.
4. Save the database password in a password manager, not in the repository.
5. Wait until the project is ready.

### 2. Get Client Settings

From Supabase Dashboard, copy:

- Project URL as `SUPABASE_URL`;
- publishable key as `SUPABASE_PUBLISHABLE_KEY`.

The legacy anon key is not used by PetConnect frontend configuration. Do not use a Supabase secret key or service role key in Flutter Web: browser code is public, and these keys can bypass or weaken the intended security model. PetConnect protects user data with Row Level Security policies and authenticated Supabase sessions.

Expected URL format:

```text
https://<project-ref>.supabase.co
```

### 3. Enable Auth

Supabase Auth email/password is the target auth provider. Google OAuth is enabled through Supabase Auth for OAuth2 integration.

For educational smoke checks, either:

- confirm demo users manually in Dashboard; or
- temporarily disable email confirmation in Auth settings.

Document the chosen option in the final validation notes. Do not commit real user credentials.

### 3.1. Enable Google OAuth

Manual Supabase Dashboard steps:

1. Open Supabase Dashboard for the production project.
2. Go to `Authentication` -> `Providers` -> `Google`.
3. Enable the Google provider.
4. Paste the Google OAuth Client ID.
5. Paste the Google OAuth Client Secret only in Supabase Dashboard.
6. Save the provider settings.
7. Go to `Authentication` -> `URL Configuration`.
8. Set Site URL to the production frontend URL:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

9. Add exact Redirect URLs for production and local development:

```text
https://cool-duckanoo-d28d04.netlify.app/
http://localhost:3000/
http://127.0.0.1:3000/
```

Google Cloud Console should use the Supabase callback URL shown in the Supabase Google provider screen, usually:

```text
https://<project-ref>.supabase.co/auth/v1/callback
```

The Google Client Secret must stay only in Supabase Dashboard and Google Cloud Console. Do not add it to Dart code, GitHub Actions, Netlify environment variables, documentation screenshots or git commits.

### 4. Run Migrations

Recommended CLI flow:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

If the CLI is not configured, run the migration files manually in Supabase Dashboard SQL Editor in this exact order:

```text
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_rls_policies.sql
supabase/migrations/003_api_grants.sql
```

### 5. Run Seed

Seed file:

```text
supabase/seed.sql
```

Local Supabase CLI:

```bash
supabase db reset
```

For a hosted Supabase project, create two demo Auth users first through Dashboard, Auth Admin API or the app sign-up flow. Then replace the fixed demo UUIDs in public seed rows with the real `auth.users.id` values before running the seed for `public.*` data.

Fixed demo UUIDs in `supabase/seed.sql`:

| Placeholder | Demo UUID |
|---|---|
| `DEMO_USER_A_ID` | `11111111-1111-1111-1111-111111111111` |
| `DEMO_USER_B_ID` | `22222222-2222-2222-2222-222222222222` |

Expected demo data after seed:

| Table | Rows |
|---|---:|
| `profiles` | 2 |
| `pets` | 3 |
| `posts` | 4 |
| `comments` | 5 |
| `post_likes` | 4 |
| `walks` | 3 |
| `walk_participants` | 4 |
| `chats` | 1 |
| `chat_participants` | 2 |
| `messages` | 3 |

### 6. Check RLS

Run this SQL check in Dashboard SQL Editor:

```sql
select
  schemaname,
  tablename,
  rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'profiles',
    'pets',
    'posts',
    'comments',
    'post_likes',
    'walks',
    'walk_participants',
    'chats',
    'chat_participants',
    'messages'
  )
order by tablename;
```

Every returned row should have `rowsecurity = true`.

Also check that Storage buckets exist:

- private/prepared: `avatars`, `pet-photos`, `post-images`;
- public-read pet profile photos: `pet-images`.

## Run The App

Install dependencies:

```bash
flutter pub get
```

If platform files are missing:

```bash
flutter create . --platforms=web,android,ios
```

### Mock Mode

Mock mode does not require Supabase credentials:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=false
```

macOS fallback:

```bash
flutter run -d macos \
  --dart-define=USE_SUPABASE_BACKEND=false
```

### Supabase Mode

Pass real values only locally through `--dart-define` or ignored local env files:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=http://localhost:3000/
```

macOS fallback:

```bash
flutter run -d macos \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=http://127.0.0.1:3000/
```

For production builds, `SUPABASE_AUTH_REDIRECT_URL` defaults to:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

Production Netlify/GitHub Actions builds also pass this URL explicitly. Do not set `SUPABASE_AUTH_REDIRECT_URL` to `localhost` in Netlify or GitHub production build settings.

Flutter does not need the Google OAuth Client ID or Client Secret. It calls Supabase Auth with `OAuthProvider.google`; Supabase owns the provider configuration and redirects back to the allowed URL.

If Google OAuth returns to `http://localhost:3000/?code=...` in production, fix the Supabase Dashboard Auth settings and redeploy the frontend:

1. `Authentication` -> `URL Configuration` -> Site URL must be `https://cool-duckanoo-d28d04.netlify.app/`.
2. Redirect URLs must include `https://cool-duckanoo-d28d04.netlify.app/`.
3. Netlify/GitHub production build must pass `SUPABASE_AUTH_REDIRECT_URL=https://cool-duckanoo-d28d04.netlify.app/` or use the app default.
4. Rebuild and redeploy the Flutter Web bundle.

## End-To-End Check

Use this scenario after migrations, seed and Auth setup:

1. Start the app in Supabase mode.
2. Register or sign in with a demo user.
3. Open the feed and verify seeded posts are visible.
4. Create a pet for the current user.
5. Create a post for that pet.
6. Like a post and verify the like counter changes.
7. Add a comment and verify the comment counter changes.
8. Open walks and join an active walk.
9. Sign in as a second demo user and verify RLS denies editing another user's pet, post or walk.

Useful SQL smoke checks:

```sql
select count(*) from public.profiles;
select count(*) from public.pets;
select count(*) from public.posts;
select count(*) from public.walks;
select count(*) from public.messages;
```

Do not claim production deployment is verified until the project, migrations, seed, Auth flow, RLS checks and Flutter Supabase mode have actually been tested for the submitted environment.

## Tests

Run after Flutter/Dart changes:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Focused test strategy and final manual QA checklist are documented in:

- `docs/testing_strategy.md`
- `docs/manual_qa_checklist.md`

Current automated coverage includes auth validation, pet/post/walk validation, search/filter state, disabled analytics mode, logger sanitization, repository/API error mapping, loading/empty/error widget states and delete confirmation dialogs.

Latest local stabilization pass: `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze` and `flutter test` passed; full suite result was 109 tests.

Run after Supabase SQL/RLS changes when Supabase CLI is configured:

```bash
supabase db lint
supabase db reset
```

If Supabase CLI is not available, validate migrations and RLS through Supabase Dashboard SQL Editor and document the manual result.

## Security Audit Commands

Run before final handoff and after dependency, CI/CD, Supabase or deployment changes:

```bash
flutter pub outdated
flutter analyze
git grep -n -E "sb_secret_|service_role|SUPABASE_SERVICE" -- \
  .github lib web supabase netlify netlify.toml pubspec.yaml pubspec.lock \
  functions/package.json functions/package-lock.json functions/src
find . -path ./.git -prune -o -name '.env*' ! -name '.env.example' -print
find . -path ./.git -prune -o -name '.DS_Store' -print
supabase db lint
```

If `functions/package.json` is present, also run:

```bash
cd functions
npm ci
npm audit --audit-level=moderate
npm run build
```

Keep GitHub secret scanning and Netlify secret scanning enabled. `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are public Flutter Web client configuration, but service role keys, `sb_secret_` keys, database passwords, JWT secrets and private tokens must never be committed or passed into the frontend build.

## Troubleshooting

### Wrong `SUPABASE_URL`

Symptoms:

- Supabase initialization fails;
- auth/feed/pets/walks show network errors;
- requests go to an old or malformed endpoint.

Check that the value is exactly:

```text
https://<project-ref>.supabase.co
```

Do not append `/rest/v1`, spaces or quotes.

### Wrong `SUPABASE_PUBLISHABLE_KEY`

Symptoms:

- auth or table requests return unauthorized;
- the app asks to sign in again;
- Supabase logs show rejected requests.

Copy the publishable key from Supabase Dashboard. Never use secret key or service role key in Flutter Web.

### Empty Data Because Seed Was Not Applied

Symptoms:

- app starts successfully, but feed, pets or walks are empty;
- SQL `count(*)` checks return `0`.

Apply `supabase/seed.sql`. For hosted Supabase, create demo Auth users first and replace demo UUIDs with their real `auth.users.id`.

### RLS Permission Denied

Symptoms:

- write operations fail with permission errors;
- PostgREST returns `403`, `42501` or a policy-related error.

Check that:

- the user is authenticated;
- `owner_id`, `author_id`, `user_id` or `creator_id` equals `auth.uid()`;
- `002_rls_policies.sql` was applied to the same project;
- `003_api_grants.sql` was applied after policies.

### Auth Email Confirmation

Symptoms:

- sign up succeeds, but sign in fails;
- Supabase says the email is not confirmed.

For demo validation, confirm the user in Dashboard or temporarily disable email confirmation in Auth settings.

### Chrome Does Not Appear In `flutter devices`

Run:

```bash
flutter devices
flutter doctor
```

If web platform files are missing:

```bash
flutter create . --platforms=web,android,ios
```

## AI-Assisted Development

PetConnect was developed and reviewed with OpenAI Codex as the AI coding agent.

Key AI workflow artifacts:

- `AGENTS.md` - primary Codex rules for this repository;
- `docs/ai_agent_rules.md` - extended Flutter/Supabase rules;
- `prompts.md` - prompt and result log;
- `development_report.md` - development report, decisions and debugging notes;
- `backend_documentation.md` - backend architecture, schema, RLS, Storage, API and validation documentation.

Codex was used for:

- analyzing homework requirements;
- researching the Firebase path and the Cloud Functions billing constraint;
- documenting the Firebase-to-Supabase architecture decision;
- designing PostgreSQL schema, RLS and Storage policies;
- integrating Supabase through repositories and Riverpod controllers;
- reviewing validation commands and handoff documentation.
