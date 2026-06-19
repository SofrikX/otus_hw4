# PetConnect Backend Documentation: Supabase Backend for HW5

## 1. Название и цель

Документ описывает backend-часть PetConnect для сдачи ДЗ 5: архитектуру, развертывание Supabase, PostgreSQL schema, SQL migrations, Row Level Security, Supabase Storage, API operations, frontend integration, testing и процесс разработки с OpenAI Codex.

PetConnect - Flutter-приложение для владельцев домашних животных. MVP включает социальную ленту питомцев, профили питомцев, прогулки, присоединение к прогулкам и базовый чат-сценарий. Для ДЗ 5 frontend MVP подключается к реальному backend через Supabase Free Tier.

Документ может содержать публичный Supabase Project URL для production frontend, но не содержит реальных `SUPABASE_PUBLISHABLE_KEY`, secret key, database password, service role key, JWT secret или access tokens.

## 2. Почему Supabase выбран вместо Firebase

На предыдущем этапе техническая спецификация PetConnect ориентировалась на Firebase. Поэтому в проекте была исследована Firebase-ветка: Firebase Auth, Firestore, Storage, Security Rules, Cloud Functions и Emulator Suite. Эта работа помогла выделить доменные сущности, repository layer, API operations и security model.

На финальном этапе ДЗ 5 backend decision изменен на Supabase Free Tier. Причины:

- исходное задание прямо допускает Supabase как backend option;
- Firebase Cloud Functions production deploy может требовать Blaze/pay-as-you-go plan;
- учебной сдаче нужен бесплатный и воспроизводимый hosted backend;
- Supabase дает проверяемые SQL migrations, PostgreSQL constraints, RLS policies и auto REST API;
- для MVP операций не нужен отдельный платный serverless layer.

Итоговое соответствие:

| Firebase prototype | Final Supabase backend |
|---|---|
| Firebase Auth | Supabase Auth |
| Cloud Firestore | Supabase PostgreSQL |
| Firebase Security Rules | PostgreSQL Row Level Security |
| Cloud Functions HTTP API | Supabase auto REST API / Flutter SDK |
| Firebase Storage | Supabase Storage |
| Firebase Emulator Suite | Supabase CLI / hosted smoke checks |

## 3. Архитектура

```text
Flutter UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase repositories or mock repositories
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Компоненты:

- **Flutter frontend**: UI построен на Flutter, Material 3, `go_router` и Riverpod. Экраны не обращаются к Supabase напрямую.
- **Application layer**: Riverpod controllers/providers вызывают repository interfaces.
- **Repository layer**: Supabase implementations используются при `USE_SUPABASE_BACKEND=true`; mock repositories остаются для тестов и fallback.
- **Supabase Auth**: email/password sign up, Google OAuth sign in, sign out, session restore и `auth.uid()` для RLS.
- **PostgreSQL**: relational schema для profiles, pets, posts, comments, likes, walks, walk participants, chats и messages.
- **Row Level Security**: все application tables защищены RLS policies для роли `authenticated`.
- **Supabase Storage**: private buckets для аватаров, фото питомцев и изображений постов.
- **Supabase REST API / Flutter SDK**: операции выполняются через `supabase_flutter`, а Supabase автоматически предоставляет REST endpoints через PostgREST.

Hosted Supabase deployment был проверен 17 июня 2026: migrations применены, RLS включен, Auth login прошел, authenticated REST smoke checks прошли для feed, walks, like, comment, walk join и negative RLS update.

Frontend production deployment планируется отдельно от backend: Flutter Web собирается как static release build и размещается на Netlify Free. Netlify отдает файлы из `build/web`, а runtime-запросы выполняются Flutter-клиентом к Supabase через `supabase_flutter`.

Production deployment split:

| Layer | Production target |
|---|---|
| Backend | Supabase Auth, PostgreSQL, RLS, Storage, auto REST API |
| Frontend | Flutter Web static release build |
| Frontend hosting | Netlify Free |

Frontend release target:

```text
GitHub source: https://github.com/SofrikX/otus_hw4/tree/hw5-sb
Hosting: Netlify Free
Supabase URL: https://<project-ref>.supabase.co
```

Netlify is the recommended frontend hosting target because Flutter Web builds to static files, the free tier is enough for an educational public demo, GitHub can be connected for automatic deploys, environment variables can be configured in the Netlify UI, and `build/web` can be uploaded manually as a fallback.

Build-time configuration for production frontend:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
```

Build output and Netlify publish directory:

```text
build/web
```

In Netlify, `SUPABASE_URL` and the real `SUPABASE_PUBLISHABLE_KEY` should be stored as environment variables and passed into the build command as `--dart-define`. The repository includes `netlify.toml` with the production Flutter Web build command, `build/web` publish directory and SPA redirect rule from `/*` to `/index.html` with status `200`. Because Flutter Web embeds `--dart-define` values into the generated browser bundle, `netlify.toml` also omits these two public client settings from Netlify secrets scanning. Service role key, database password and private tokens are not used in the frontend and must never be added to the omit list.

## 4. Database Schema

Источник истины: `supabase/migrations/001_initial_schema.sql`.

| Table | Назначение |
|---|---|
| `profiles` | Профили пользователей, связанные с `auth.users` |
| `pets` | Питомцы пользователей |
| `posts` | Публикации в социальной ленте |
| `comments` | Комментарии к публикациям |
| `post_likes` | Лайки пользователей к постам |
| `walks` | Прогулки и встречи |
| `walk_participants` | Участники прогулок |
| `chats` | Метаданные чатов |
| `chat_participants` | Участники чатов |
| `messages` | Сообщения в чатах |

### profiles

`profiles.id` ссылается на `auth.users(id)` и совпадает с Supabase Auth user id.

Ключевые поля: `id`, `display_name`, `email`, `avatar_url`, `bio`, `city`, `created_at`, `updated_at`.

Ограничения:

- `display_name`: 1-80 символов;
- `bio`: до 500 символов;
- `city`: до 120 символов.

### pets

Ключевые поля: `id`, `owner_id`, `owner_name`, `name`, `animal_type`, `breed`, `age`, `description`, `photo_url`, `photo_emoji`, `created_at`, `updated_at`.

Ограничения:

- `owner_id` -> `profiles.id`;
- `animal_type` in `dog`, `cat`, `other`;
- `name`: 1-50 символов;
- `age`: 0-30.

### posts

Ключевые поля: `id`, `author_id`, `author_name`, `pet_id`, `pet_name`, `pet_photo_url`, `pet_emoji`, `text`, `image_urls`, `image_emoji`, `likes_count`, `comments_count`, `visibility`, `created_at`, `updated_at`, `deleted_at`.

Ограничения:

- `author_id` -> `profiles.id`;
- `pet_id` -> `pets.id`;
- `text`: до 1000 символов;
- `visibility` in `public`, `private`;
- `likes_count` и `comments_count` неотрицательные.

### comments

Ключевые поля: `id`, `post_id`, `author_id`, `author_name`, `author_avatar_url`, `text`, `created_at`, `updated_at`, `deleted_at`.

Ограничения:

- `post_id` -> `posts.id`;
- `author_id` -> `profiles.id`;
- `text`: 1-500 символов.

### post_likes

Ключевые поля: `id`, `post_id`, `user_id`, `created_at`.

Ограничения:

- `post_id` -> `posts.id`;
- `user_id` -> `profiles.id`;
- unique `(post_id, user_id)`.

### walks

Ключевые поля: `id`, `creator_id`, `organizer_name`, `title`, `place`, `latitude`, `longitude`, `scheduled_at`, `description`, `participants_count`, `status`, `created_at`, `updated_at`.

Ограничения:

- `creator_id` -> `profiles.id`;
- `title`: 1-120 символов;
- `place`: 1-160 символов;
- `status` in `active`, `cancelled`, `completed`;
- `participants_count` неотрицательный.

### walk_participants

Ключевые поля: `id`, `walk_id`, `user_id`, `created_at`.

Ограничения:

- `walk_id` -> `walks.id`;
- `user_id` -> `profiles.id`;
- unique `(walk_id, user_id)`.

### chats, chat_participants, messages

`chats` хранит последние сообщения и timestamps. `chat_participants` хранит участников, companion metadata и `unread_count`. `messages` хранит сообщения чата.

Ключевое security-правило: чат и сообщения доступны только участникам через функцию `public.is_chat_participant(chat_id)`.

## 5. SQL Migrations

Migrations находятся в `supabase/migrations/`.

| File | Назначение |
|---|---|
| `001_initial_schema.sql` | Tables, constraints, indexes, trigger functions, counter triggers, Storage buckets and Storage policies |
| `002_rls_policies.sql` | RLS enablement and policies for application tables |
| `003_api_grants.sql` | Grants for `authenticated` role so PostgREST can access tables while RLS still filters rows |

Важные детали migration `001_initial_schema.sql`:

- включает extension `pgcrypto`;
- создает application tables;
- создает indexes для feed, owner pets, walks, comments, likes and chat queries;
- создает `set_updated_at()` trigger для `updated_at`;
- создает trigger counters:
  - `recount_post_likes()` обновляет `posts.likes_count`;
  - `recount_comments()` обновляет `posts.comments_count`;
  - `recount_walk_participants()` обновляет `walks.participants_count`;
- создает private Storage buckets `avatars`, `pet-photos`, `post-images`.

Migrations применяются в порядке:

```bash
supabase db push
```

или вручную через Supabase SQL Editor:

```text
001_initial_schema.sql
002_rls_policies.sql
003_api_grants.sql
```

## 6. Seed Data

Seed-файл: `supabase/seed.sql`.

Назначение seed:

- дать проверяемые demo rows для feed, pets, walks и chats;
- не использовать production data;
- не хранить secrets;
- обеспечить smoke checks после migrations.

Seed создает:

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

Для локального Supabase CLI seed создает deterministic demo Auth users и demo identities. Для hosted Supabase безопаснее создать demo users через Authentication UI, Auth Admin API или регистрацию в приложении, затем заменить demo UUID в public seed rows на реальные `auth.users.id`.

Demo UUID из файла:

| Placeholder | Demo UUID |
|---|---|
| `DEMO_USER_A_ID` | `11111111-1111-1111-1111-111111111111` |
| `DEMO_USER_B_ID` | `22222222-2222-2222-2222-222222222222` |

Локальный seed password `DemoPass123!` предназначен только для demo QA и не является production secret.

## 7. RLS Policies

RLS включен для всех application tables:

- `profiles`;
- `pets`;
- `posts`;
- `comments`;
- `post_likes`;
- `walks`;
- `walk_participants`;
- `chats`;
- `chat_participants`;
- `messages`.

Policies:

| Table | Read | Write |
|---|---|---|
| `profiles` | authenticated users read profiles | user inserts/updates only own profile |
| `pets` | authenticated users read pets | owner inserts/updates/deletes own pets |
| `posts` | authenticated users read non-deleted posts | author inserts/updates/deletes own posts |
| `comments` | authenticated users read non-deleted comments | author inserts/deletes own comments |
| `post_likes` | authenticated users read likes | user inserts/deletes only own like |
| `walks` | authenticated users read walks | creator inserts/updates/deletes own walks |
| `walk_participants` | authenticated users read participants | user joins/leaves only as self |
| `chats` | only chat participants read/update | client direct chat creation is not open |
| `chat_participants` | participants read own chats | participant updates/deletes own participant row |
| `messages` | only chat participants read | participant inserts messages; sender updates/deletes own messages |

Пример реализованной policy:

```sql
create policy "post_likes_insert_own"
on public.post_likes for insert to authenticated
with check (user_id = auth.uid());
```

Anonymous users do not get read/write access to application data. Service role key bypasses RLS and is not used in Flutter.

## 8. API Operations

Base REST URL:

```text
${SUPABASE_URL}/rest/v1
```

Required headers for REST examples:

```http
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <user-access-token>
Content-Type: application/json
```

The Flutter app uses `supabase_flutter`; REST examples show the same operations exposed by PostgREST.

### SELECT posts

Flutter:

```dart
await supabase
    .from('posts')
    .select('id,pet_id,pet_name,author_name,pet_emoji,image_emoji,text,created_at,likes_count,comments_count')
    .eq('visibility', 'public')
    .isFilter('deleted_at', null)
    .order('created_at', ascending: false)
    .limit(20);
```

REST:

```http
GET /rest/v1/posts?visibility=eq.public&deleted_at=is.null&order=created_at.desc&limit=20
```

### INSERT posts

Flutter:

```dart
await supabase.from('posts').insert({
  'author_id': userId,
  'author_name': authorName,
  'pet_id': petId,
  'pet_name': petName,
  'pet_emoji': petEmoji,
  'text': text,
  'image_urls': imageUrls,
  'image_emoji': imageEmoji,
}).select().single();
```

RLS requires `author_id = auth.uid()`.

REST:

```http
POST /rest/v1/posts?select=*
Prefer: return=representation

{
  "author_id": "<current-user-id>",
  "author_name": "Demo Alina",
  "pet_id": "<pet-id>",
  "pet_name": "Bruno",
  "pet_emoji": "dog",
  "text": "Morning route was approved.",
  "image_urls": [],
  "image_emoji": "park"
}
```

### INSERT/DELETE post_likes

Like:

```dart
await supabase.from('post_likes').insert({
  'post_id': postId,
  'user_id': userId,
});
```

Unlike:

```dart
await supabase
    .from('post_likes')
    .delete()
    .eq('post_id', postId)
    .eq('user_id', userId);
```

RLS requires `user_id = auth.uid()`. Unique `(post_id, user_id)` prevents duplicate likes. Trigger `recount_post_likes()` updates `posts.likes_count`.

REST:

```http
POST /rest/v1/post_likes

{
  "post_id": "<post-id>",
  "user_id": "<current-user-id>"
}
```

```http
DELETE /rest/v1/post_likes?post_id=eq.<post-id>&user_id=eq.<current-user-id>
```

### SELECT walks

Flutter:

```dart
await supabase
    .from('walks')
    .select('id,organizer_name,title,place,scheduled_at,description,participants_count')
    .eq('status', 'active')
    .order('scheduled_at', ascending: true)
    .limit(20);
```

REST:

```http
GET /rest/v1/walks?status=eq.active&order=scheduled_at.asc&limit=20
```

### INSERT walk_participants

Flutter:

```dart
await supabase.from('walk_participants').insert({
  'walk_id': walkId,
  'user_id': userId,
});
```

RLS requires `user_id = auth.uid()`. Unique `(walk_id, user_id)` prevents duplicate join. Trigger `recount_walk_participants()` updates `walks.participants_count`.

REST:

```http
POST /rest/v1/walk_participants

{
  "walk_id": "<walk-id>",
  "user_id": "<current-user-id>"
}
```

### SELECT pets

Flutter:

```dart
await supabase
    .from('pets')
    .select('id,owner_id,owner_name,name,animal_type,breed,age,description,photo_emoji,created_at')
    .order('created_at', ascending: false)
    .limit(50);
```

By id:

```dart
await supabase
    .from('pets')
    .select('id,owner_id,owner_name,name,animal_type,breed,age,description,photo_emoji,created_at')
    .eq('id', petId)
    .maybeSingle();
```

REST:

```http
GET /rest/v1/pets?select=id,owner_id,owner_name,name,animal_type,breed,age,description,photo_emoji,created_at&order=created_at.desc&limit=50
```

### INSERT comments

Flutter:

```dart
await supabase.from('comments').insert({
  'post_id': postId,
  'author_id': userId,
  'author_name': authorName,
  'text': text,
}).select('text').single();
```

RLS requires `author_id = auth.uid()`. Trigger `recount_comments()` updates `posts.comments_count`.

REST:

```http
POST /rest/v1/comments?select=text
Prefer: return=representation

{
  "post_id": "<post-id>",
  "author_id": "<current-user-id>",
  "author_name": "Demo Mark",
  "text": "Looks like a good route."
}
```

## 9. Deployment Instructions

### 1. Create Supabase project

1. Open Supabase Dashboard.
2. Create a Free Tier project.
3. Save database password in a password manager, not in git.
4. Copy Project URL and anon/publishable public key.

### 2. Configure local environment

Use local `.env`, `.env.deploy` or `--dart-define`. Do not commit real values.

```text
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
USE_SUPABASE_BACKEND=true
```

### 3. Apply migrations

Supabase CLI:

```bash
supabase login
supabase link --project-ref <project-ref>
supabase db push --linked --dry-run
supabase db push --linked
```

Manual fallback through Dashboard SQL Editor:

```text
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_rls_policies.sql
supabase/migrations/003_api_grants.sql
```

### 4. Apply seed data

Local CLI:

```bash
supabase db reset
```

Hosted project:

1. Create demo users through Supabase Auth UI, Auth Admin API or app registration.
2. Replace demo UUIDs in public seed rows with real `auth.users.id`.
3. Run the prepared SQL through SQL Editor, `supabase db query` or `psql`.

### 5. Run Flutter with Supabase backend

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=http://localhost:3000/
```

### 5.1. Configure Google OAuth in Supabase Auth

Google OAuth is configured server-side in Supabase Auth. Flutter does not store the Google Client ID or Client Secret.

Manual Dashboard setup:

1. Supabase Dashboard -> `Authentication` -> `Providers` -> `Google`.
2. Enable Google provider.
3. Insert the Google OAuth Client ID.
4. Insert the Google OAuth Client Secret only in Supabase Dashboard.
5. Save provider settings.
6. Supabase Dashboard -> `Authentication` -> `URL Configuration`.
7. Set Site URL:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

8. Add exact Redirect URLs:

```text
https://cool-duckanoo-d28d04.netlify.app/
http://localhost:3000/
http://127.0.0.1:3000/
```

9. In Google Cloud Console, configure the authorized redirect URI from the Supabase Google provider screen:

```text
https://<project-ref>.supabase.co/auth/v1/callback
```

The Client Secret must not be committed, documented as a real value, passed through `--dart-define`, added to Netlify or GitHub Actions frontend secrets, or logged.

OAuth application flow:

```text
LoginScreen
  -> AuthController.signInWithGoogle()
  -> AuthRepository.signInWithGoogle()
  -> SupabaseAuthRepository.signInWithOAuth(OAuthProvider.google)
  -> Google consent screen
  -> Supabase Auth callback
  -> production/local redirect URL
  -> authStateProvider receives the session
  -> go_router redirects authenticated user to /
```

### 6. Build Flutter Web for Netlify

Planned frontend hosting: Netlify Free.

Committed `netlify.toml` build command:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY
```

Output directory:

```text
build/web
```

Netlify publish directory:

```text
build/web
```

Netlify environment variables:

```text
SUPABASE_URL=<production-supabase-project-url>
SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

Netlify SPA redirect:

```text
/* -> /index.html 200
```

If Netlify's build environment does not include Flutter SDK, build locally with the same release command and deploy the generated `build/web` folder manually through Netlify drag-and-drop.

After Netlify deploy, the reviewer can open the production URL and validate PetConnect against the hosted Supabase backend.

## 10. Environment Variables and Secret Protection

Allowed in git:

- `.env.example` with empty placeholders;
- SQL migrations;
- RLS policies;
- documentation without real credentials.

Forbidden in git:

- real `.env` or `.env.deploy`;
- service role key;
- database password;
- JWT secret;
- Supabase access token;
- production user data.

Client-side Flutter uses only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. The Supabase Publishable Key is public client configuration, but real project values are still kept out of repository artifacts. Supabase secret keys are not required for the Flutter frontend, and the service role key is never used in Flutter because it bypasses RLS.

## 11. Error Handling

Supabase errors are mapped in repositories to typed app errors and friendly UI messages.

| Source | Application meaning |
|---|---|
| Missing/invalid Supabase config | Startup error screen with setup hint |
| `401` / missing session | User must sign in |
| `403` / RLS denial / PostgreSQL `42501` | Permission denied |
| Unique violation `23505` | Duplicate like or already joined walk |
| Constraint violation | Invalid field values |
| Network failure | Connection issue, retry possible |
| Not found | Empty or not-found state |
| Unexpected error | Generic friendly error |

The UI keeps loading, error, empty and success states through Riverpod controllers. Repository exceptions are not shown as raw stack traces.

## 12. Logging and Debugging

Debugging approach:

- log safe operation names, status codes and Supabase/PostgREST error codes;
- do not log access tokens, publishable keys, service role keys or database passwords;
- use `supabase db lint` and `supabase db reset` for local SQL validation;
- use SQL smoke checks for row counts, RLS enabled flags, Storage buckets and counter triggers;
- use two test users for negative RLS checks.

Real debugging case from hosted deployment:

- Problem: authenticated PostgREST writes returned `403`.
- Cause: RLS policies existed, but table privileges for role `authenticated` were missing.
- Fix: added `supabase/migrations/003_api_grants.sql`.
- Result: authenticated REST reads/writes worked while RLS continued to enforce row-level access.

## 13. Frontend Integration

Flutter integration follows feature-first Clean Architecture principles:

```text
lib/features/<feature>/
  domain/
  data/
  application/
  presentation/
```

Implemented Supabase integrations:

- `SupabaseAuthRepository`: sign up, email/password sign in, Google OAuth sign in, sign out, auth state, profile upsert;
- `SupabaseFeedRepository`: select posts, create post, like/unlike, add comment;
- `SupabasePetRepository`: select pets, get pet by id, owner pets, create pet;
- `SupabaseWalkRepository`: select walks, create walk, join walk, leave walk.

Routing behavior:

- `USE_SUPABASE_BACKEND=true` enables Supabase initialization and protected routes;
- `SUPABASE_AUTH_REDIRECT_URL` controls the OAuth return URL and defaults to the Netlify production URL;
- anonymous users are redirected to auth screens;
- mock mode remains available without backend credentials.

## 14. Testing

Frontend validation commands:

```bash
dart format .
flutter analyze
flutter test
```

Supabase local validation:

```bash
supabase db lint
supabase db reset
```

Launch validation:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
```

Hosted smoke checks performed:

| Scenario | Result |
|---|---|
| Supabase Auth login | Passed |
| Load feed from Supabase | Passed |
| Load walks from Supabase | Passed |
| Like post | Passed |
| Add comment | Passed |
| Join walk | Passed |
| RLS: User B cannot mutate User A rows | Passed |
| Flutter Web Supabase initialization | Passed |

Automated Flutter tests cover auth, feed, pets, walks, chat, repository mapping and error handling. Full manual browser click-through for fresh sign-up, create post through UI and responsive layouts remains a final human QA step before presentation.

## 14.1. Production E2E Verification - 18 June 2026

Production inputs checked:

```text
Frontend: https://cool-duckanoo-d28d04.netlify.app
Supabase: https://fivtpxsjcjirddogngtl.supabase.co
Supabase project status: Healthy
```

Files inspected for the release review:

- `README.md`;
- `backend_documentation.md`;
- `docs/frontend_deployment.md`;
- `docs/supabase_setup.md`;
- `docs/seed_data.md`;
- `docs/supabase_security.md`;
- `development_report.md`;
- `prompts.md`;
- `lib/features/`.

Manual/browser result:

| Check | Result | Notes |
|---|---|---|
| Production frontend URL opens | Passed | Netlify returns `PetConnect` HTML and Flutter assets. |
| App does not crash at initial load | Partial | Login screen rendered after reload; first load logged a CanvasKit fetch retry error. |
| User registration | Blocked | Supabase Auth returned `over_email_send_rate_limit`; use seeded demo users or confirm users manually. |
| User login | Failed in UI, passed in Auth API | UI accepted demo credentials, then frontend crashed to white screen. Direct Auth API login returned `200`. |
| Feed loads Supabase data | Blocked in UI, passed by REST | Authenticated REST counts show non-empty posts. |
| Create post | Blocked in UI | Cannot reach feed because of frontend crash after login. |
| Like post | Blocked in UI, passed by REST | Authenticated REST insert into `post_likes` returned `201` for an unliked post. |
| Comment | Blocked in UI, passed by REST | Authenticated REST insert into `comments` returned `201`. |
| Pet screen opens | Blocked in UI | Cannot reach home tabs because of frontend crash after login. |
| Walks load from Supabase | Blocked in UI, passed by REST | Authenticated REST counts show 3 walks. |
| Join walk | Blocked in UI, passed by REST | Authenticated REST insert into `walk_participants` returned `201` for Demo Mark. |
| Friendly errors | Partial | Registration form showed a friendly email message, but the post-login crash is a blank screen. |
| Mobile layout | Partial | Auth screen renders in a narrow viewport; authenticated app blocked by crash. |
| Desktop layout | Blocked | Authenticated desktop app blocked by crash. |

Production database was not empty during verification:

| Table | Authenticated REST count |
|---|---:|
| `profiles` | 2 |
| `pets` | 3 |
| `posts` | 6 |
| `comments` | 6 before QA comment, then increased |
| `post_likes` | 5 before QA like, then increased |
| `walks` | 3 |
| `walk_participants` | 5 before QA join, then increased |

Blocking frontend issue:

```text
Error: Null check operator used on a null value
TypeError: Cannot read properties of undefined (reading 'init')
```

This happened in the deployed `main.dart.js` immediately after successful login. The likely cause is the external Corbado/passkeys web bundle loading after Flutter bootstrap. A local minimal fix was applied in `web/index.html` by loading the Corbado/passkeys script before `flutter_bootstrap.js`. The production site must be rebuilt and redeployed before teacher handoff.

Required release fix:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<production-supabase-project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

Then redeploy `build/web` to Netlify and repeat the full browser scenario: login, feed, create post, like, comment, pet profile, walks, join walk, mobile and desktop.

## 15. AI-Assisted Development

OpenAI Codex was used as the AI coding agent and technical reviewer.

AI-assisted workflow:

- **Проектирование БД через Codex**: Codex mapped PetConnect user stories to PostgreSQL tables, relations, constraints and indexes.
- **Генерация SQL migrations через Codex**: Codex created `001_initial_schema.sql` with tables, triggers, indexes and Storage buckets.
- **Генерация RLS policies через Codex**: Codex created `002_rls_policies.sql` with authenticated row-level policies.
- **Отладка RLS через Codex**: Codex diagnosed hosted `403` PostgREST writes and added `003_api_grants.sql` while keeping RLS as the row-level guard.
- **Seed data через Codex**: Codex prepared idempotent `supabase/seed.sql` for demo profiles, pets, posts, comments, likes, walks and chats.
- **Интеграция Flutter через Codex**: Codex added Supabase Auth, feed, pets and walks repositories behind existing Riverpod providers.
- **Error handling через Codex**: Codex centralized Supabase error mapping and added safe debug logging.
- **Документирование через Codex**: Codex maintained README, setup docs, schema docs, security docs, API spec, development report and prompts journal.

All AI-generated changes were checked against project rules: no secrets in repository, no paid services, no direct Supabase calls from widgets, mock fallback preserved.

## 16. Известные ограничения MVP

- Image upload UI for avatars, pet photos and post images is prepared at Storage policy level but not fully exposed as a polished end-user flow.
- Chat read/message policies exist, but client-side chat creation is intentionally not open without a trusted RPC or server operation.
- Feed, pets and walks use denormalized display fields such as `author_name`, `pet_name` and `owner_name`; future production work can add stricter server-side consistency.
- Fresh sign-up and create-post browser click-through should be repeated by the student with local hosted credentials before final demo.
- The app remains an MVP: moderation, notifications, search, pagination UX and production observability are outside the current homework scope.

## 17. Финальный Checklist

- [x] Supabase selected as final backend instead of Firebase.
- [x] Architecture documented: Flutter, Supabase Auth, PostgreSQL, RLS, Storage, REST API / Flutter SDK.
- [x] Database schema documented.
- [x] SQL migrations added and described.
- [x] Seed data added and described.
- [x] RLS policies added and described.
- [x] Required API operations documented with request examples.
- [x] Deployment instructions documented.
- [x] Environment variables and secret protection documented.
- [x] Error handling documented.
- [x] Logging/debugging documented.
- [x] Frontend integration documented.
- [x] Testing commands and hosted smoke results documented.
- [x] AI-assisted development process documented.
- [x] Known MVP limitations documented as final scope notes.
