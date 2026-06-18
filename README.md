# PetConnect

PetConnect - Flutter-приложение для владельцев домашних животных. MVP включает социальную ленту питомцев, профили питомцев, прогулки, присоединение к прогулкам и базовый чат-сценарий.

Текущая сдача относится к ДЗ 5: backend deployment and integration with Frontend. Frontend MVP подключается к Supabase backend через repository layer и Riverpod controllers. Mock repositories сохранены для локального запуска, тестов и постепенной миграции.

README не содержит реальных `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, secret key, service role key, database password, access token или production user data.

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
- Protected routing with `go_router` and Riverpod auth state.
- Pet social feed with posts, likes and comments.
- Pet profiles and owner pets.
- Walk list, walk creation and join/leave flow.
- Basic chat data model for chat list and messages.
- Friendly loading, empty, error and success states through controllers/providers.
- Mock mode for local UI checks and tests without Supabase credentials.

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
- `post-images`

RLS model:

- authenticated users can read application data needed for the MVP;
- users can insert/update/delete only their own profile, pets, posts, likes, comments and walk participation rows;
- walk creators manage their own walks;
- chat rows and messages are visible only to chat participants;
- Storage writes require paths like `<auth.uid()>/<file-name>`.

More details:

- `backend_documentation.md`
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

Flutter Web is a good fit for Netlify because the release build is static and can be served from a CDN-like static host without a custom server. Supabase stays responsible for auth, database, storage and RLS-protected API operations.

The repository contains `netlify.toml` so Netlify can build and publish the Flutter Web release from GitHub.

### Environment Variables In Netlify UI

Configure these variables in Netlify UI, not in repository files:

```text
SUPABASE_URL=<production-supabase-project-url>
SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

`USE_SUPABASE_BACKEND=true` is passed directly by the build command. The real `SUPABASE_PUBLISHABLE_KEY` must stay in Netlify Environment Variables. Do not commit it to Git.

### Build Command

Netlify build command from `netlify.toml`:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY
```

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
  from = "/*"
  to = "/index.html"
  status = 200
```

If Netlify's build environment does not include Flutter SDK, build locally with the same `flutter build web --release ...` command and deploy the generated `build/web` directory manually through Netlify drag-and-drop.

The reviewer should receive a Netlify production URL and be able to open the deployed Flutter Web app in a browser. Real Supabase keys are not committed to the repository; the service role key is never used in the frontend.

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

Supabase Auth email/password is the target auth provider.

For educational smoke checks, either:

- confirm demo users manually in Dashboard; or
- temporarily disable email confirmation in Auth settings.

Document the chosen option in the final validation notes. Do not commit real user credentials.

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

Also check that private Storage buckets exist:

- `avatars`
- `pet-photos`
- `post-images`

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
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
```

macOS fallback:

```bash
flutter run -d macos \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
```

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
dart format .
flutter analyze
flutter test
```

Run after Supabase SQL/RLS changes when Supabase CLI is configured:

```bash
supabase db lint
supabase db reset
```

If Supabase CLI is not available, validate migrations and RLS through Supabase Dashboard SQL Editor and document the manual result.

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
