# PetConnect

PetConnect - Flutter-приложение для владельцев домашних животных. Пользователь может вести социальную ленту питомца, смотреть профили питомцев, присоединяться к прогулкам и работать с базовым чат-сценарием.

ДЗ 5 переводит frontend MVP к backend-интеграции. Актуальное архитектурное решение для сдачи - Supabase Free Tier: Supabase Auth, PostgreSQL, Row Level Security, Supabase Storage, auto REST API через PostgREST и Flutter SDK `supabase_flutter`.

Firebase-ветка была спроектирована и проверялась как исследованный вариант, потому что Firebase был указан в технической спецификации предыдущего этапа. На этапе подготовки production deployment выяснилось, что Firebase Cloud Functions могут требовать Blaze/pay-as-you-go plan. Для учебного проекта выбран Supabase, так как исходное задание прямо допускает Supabase и этот путь сохраняет бесплатный, воспроизводимый production backend.

Hosted Supabase backend развернут и проверен smoke-сценариями через CLI/REST и Flutter Web. Реальные Supabase URL, anon key, database password и access token в репозиторий не добавлены: значения передаются только локально через `.env.deploy` или `--dart-define`.

## Стек

| Часть | Технология |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| State management | Riverpod / flutter_riverpod |
| Routing | go_router |
| UI | Material 3 |
| Auth | Supabase Auth |
| Database | Supabase PostgreSQL |
| Security | PostgreSQL Row Level Security |
| File storage | Supabase Storage |
| Backend API | Supabase auto REST API / Flutter Supabase client |
| Local fallback | Mock repositories |
| Frontend tests | flutter_test, mocktail |
| Backend validation | SQL migrations, RLS policies, Supabase dashboard/API checks |

> Current implementation note: Supabase Auth is integrated through `supabase_flutter` for email/password sign up, sign in, sign out, auth state changes and profile upsert. Feed, pets and walks repositories use Supabase tables when `USE_SUPABASE_BACKEND=true`; mock repositories remain the local fallback for tests and offline development.

## Architecture Decision: Firebase to Supabase

Original homework supports Supabase or self-hosted PostgreSQL. PetConnect initially mapped the backend to Firebase to match the earlier technical specification:

- Firebase Auth;
- Cloud Firestore;
- Firebase Storage;
- Cloud Functions;
- Firebase Security Rules;
- Firebase Emulator Suite.

That option was useful for schema, API and repository-layer design, but it is not the chosen production backend for the current homework anymore. The decisive constraint is Firebase Cloud Functions production deployment: it can require Blaze/pay-as-you-go billing, which is undesirable for a free educational handoff.

Supabase is selected because it:

- is explicitly allowed by the homework;
- provides a free tier suitable for a small educational backend;
- gives PostgreSQL schema and SQL migrations that are easy to review;
- implements authorization with RLS instead of a separate rules language;
- exposes REST endpoints automatically through PostgREST;
- supports Flutter integration through `supabase_flutter`;
- avoids Cloud Functions as a required production dependency for the MVP operations.

## Firebase-to-Supabase Mapping

| Previous Firebase component | Current Supabase component | Decision |
|---|---|---|
| Firebase Auth | Supabase Auth | Email/password identity source |
| Cloud Firestore | PostgreSQL tables | Relational schema for users, pets, posts, comments, likes, walks, chats and messages |
| Firestore Security Rules | Row Level Security policies | Authenticated row-level access with `auth.uid()` |
| Cloud Functions HTTP API | Supabase auto REST API / Supabase client | MVP operations use database constraints, RLS and client calls |
| Firebase Storage | Supabase Storage | Pet, post and user images in protected buckets |
| Firebase Emulator Suite | Supabase local/project validation | Local Supabase CLI can be added later; production-free validation uses SQL/RLS checks |

For operations that need atomic counters, PostgreSQL should use transactions, constraints, RPC functions or triggers only when the simple Supabase client flow is not enough. The current documentation does not claim those database functions are already deployed.

## Основные функции

- Email/password вход, регистрация и выход через backend auth layer.
- Защищенный routing через `go_router` и Riverpod auth state.
- Лента постов питомцев с созданием поста, лайками, комментариями и async states.
- Профили питомцев и экран неизвестного питомца с error-state.
- Прогулки с присоединением и обновлением счетчика участников.
- Базовый экран чатов как задел под сообщения.
- Repository layer: UI работает через controllers/providers, а не напрямую с backend SDK.
- Local fallback на mock repositories для тестов и постепенной миграции.

## Target Backend Architecture

```text
Flutter UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase or mock repositories
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Целевая схема PostgreSQL:

```text
profiles
pets
posts
comments
post_likes
walks
walk_participants
chats
chat_participants
messages
```

Supabase Storage buckets:

```text
avatars
pet-photos
post-images
```

RLS должна ограничивать доступ через `auth.uid()`: пользователь управляет своим профилем и питомцами, автор управляет своими постами, лайки уникальны по паре user/post, участники видят свои чаты, изображения загружаются только владельцем.

## Supabase Auth Flow

Flutter auth layer:

- `AuthRepository` abstraction lives outside widgets;
- `SupabaseAuthRepository` uses `Supabase.instance.client.auth`;
- `AuthController` exposes Riverpod actions for sign in, register and sign out;
- `authStateProvider` listens to Supabase auth state changes;
- `SupabaseAuthTokenProvider` returns the current Supabase access token for future Supabase API calls.

Supported operations:

- sign up with email/password;
- sign in with email/password;
- sign out;
- current user;
- auth state changes;
- profile upsert into `public.profiles` after sign up/sign in when Supabase session is available.

Routing:

- `USE_SUPABASE_BACKEND=true` protects app routes and redirects anonymous users to `/login`;
- `/login` and `/register` redirect back to `/` after successful auth state change;
- mock mode remains available without login so local UI/tests do not require backend credentials.

Handled auth errors:

- invalid credentials -> `Email или пароль не подошли.`;
- already registered email -> `Пользователь с таким email уже есть.`;
- network/service failure -> `Нет соединения с сервисом авторизации.`;
- weak password and invalid email have friendly messages.

Подробнее:

- `backend_documentation.md`
- `docs/supabase_setup.md`
- `docs/database_schema.md`
- `docs/api_spec.md`
- `docs/supabase_security.md`
- `docs/current_homework_scope.md`
- `docs/ai_workflow.md`
- `development_report.md`

## Supabase Project Setup

Production backend setup is documented in detail in `docs/supabase_setup.md`. Use the checklist there for release verification and do not commit real keys.

### 1. Создать project

1. Откройте Supabase Dashboard.
2. Создайте новый project на Free Tier.
3. Выберите регион.
4. Сохраните database password в password manager, не в репозитории.
5. Дождитесь готовности project.

### 2. Получить Project URL и anon public key

В Supabase Dashboard откройте project и найдите Connect/API settings:

- Project URL -> `SUPABASE_URL`;
- anon public key или publishable key -> `SUPABASE_ANON_KEY`.

Service role key не использовать во Flutter и не добавлять в `.env`.

### 3. Настроить локальный env

`.env.example` содержит только placeholders:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
USE_SUPABASE_BACKEND=true
```

Реальные значения храните только локально в `.env` или передавайте через `--dart-define`.

### 4. Применить SQL migrations

Через Supabase CLI:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

Если CLI еще не настроен, выполните SQL из файла вручную через Dashboard SQL Editor:

```text
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_rls_policies.sql
supabase/migrations/003_api_grants.sql
```

Порядок важен: сначала `001_initial_schema.sql`, затем `002_rls_policies.sql`, затем `003_api_grants.sql`.

### 5. Применить seed-данные

Seed-файл:

```text
supabase/seed.sql
```

Он не содержит реальных пользователей, production data или secrets. Для локального `supabase start` / `supabase db reset` seed создает две минимальные demo rows в `auth.users`, потому что `public.profiles.id` ссылается на `auth.users.id`.

Для hosted Supabase сначала создайте двух demo users через Authentication UI, Auth Admin API или регистрацию в приложении, затем используйте их ids для public demo rows. Прямой SQL insert в `auth.users` оставлен для локального `supabase db reset`.

| Placeholder | Demo UUID |
|---|---|
| `DEMO_USER_A_ID` | `11111111-1111-1111-1111-111111111111` |
| `DEMO_USER_B_ID` | `22222222-2222-2222-2222-222222222222` |

Для локальной проверки через Supabase CLI `supabase db reset` применяет migrations и затем запускает `supabase/seed.sql`:

```bash
supabase db reset
```

Локальный demo password для seed users: `DemoPass123!`. Он предназначен только для demo QA.

Для hosted project выполните public seed rows через Dashboard SQL Editor или Supabase CLI после замены UUID на ids созданных demo Auth users.

После применения seed появятся:

- 2 demo profiles;
- 3 pets;
- 4 feed posts;
- comments и post_likes;
- 3 walks и walk_participants;
- 1 chat и messages.

Подробности: `docs/seed_data.md`.

### 6. Production verification

Если hosted Supabase project еще не проверен вручную, используйте это как `Manual verification checklist`:

- [ ] Supabase project создан.
- [ ] Migrations применены.
- [ ] Seed применен после замены demo Auth UUID.
- [ ] Таблицы видны в Table Editor.
- [ ] RLS enabled для application tables.
- [ ] `SELECT posts` работает для authenticated user.
- [ ] Sign up/sign in работает в Flutter app.
- [ ] Create post работает.
- [ ] Like post работает.
- [ ] Join walk работает.

## Локальный запуск Flutter

### 1. Установить Flutter-зависимости

```bash
flutter pub get
```

Если Flutter platform files отсутствуют, создайте их:

```bash
flutter create . --platforms=web,android,ios
```

### 2. Запустить приложение на mock repositories

```bash
flutter run -d chrome
```

Fallback для desktop-проверки на macOS:

```bash
flutter run -d macos
```

### 3. После создания Supabase project

Добавить реальные значения только через локальные переменные окружения или `--dart-define`, не коммитя их в репозиторий:

Expected command in docs:

```bash
flutter run -d chrome
--dart-define=USE_SUPABASE_BACKEND=true
--dart-define=SUPABASE_URL=
--dart-define=SUPABASE_ANON_KEY=
```

Shell-friendly version:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-supabase-anon-key>
```

Реальные URL и keys в документации не указываются.

## Запуск тестов

После изменений Flutter/Dart:

```bash
dart format .
flutter analyze
flutter test
```

После добавления Supabase SQL migrations/RLS:

```bash
supabase db lint
supabase db reset
```

Если Supabase CLI еще не подключен, проверку SQL/RLS нужно выполнить через Supabase dashboard SQL editor или добавить CLI setup отдельной задачей.

## Release Status

1. Hosted Supabase project создан на Free Tier и linked через Supabase CLI.
2. `SUPABASE_URL` и public client key получены локально и не добавлены в git.
3. SQL migrations из `supabase/migrations/` применены к hosted database.
4. Demo Auth users созданы через Auth flow, public demo rows загружены.
5. RLS smoke check и PostgREST read/write checks выполнены.
6. Flutter Web запущен с `USE_SUPABASE_BACKEND=true`.
7. Оставшиеся ручные UI-проверки: fresh sign up через Flutter UI, create post через feed UI, mobile/desktop click-through.
8. Firebase dependencies и prototype files удалять только отдельной cleanup-задачей, если они больше не нужны для истории разработки.

## Troubleshooting

### Chrome не отображается в `flutter devices`

Проверьте, что Google Chrome установлен и доступен Flutter:

```bash
flutter devices
flutter doctor
```

Если platform files отсутствуют:

```bash
flutter create . --platforms=web,android,ios
```

### Supabase credentials отсутствуют

Если локальные values недоступны, используйте mock fallback. Не добавляйте реальные URL, anon key или service role key в репозиторий.

### Wrong `SUPABASE_URL`

Симптомы:

- приложение не проходит Supabase initialization;
- login/feed/pets/walks показывают сетевую ошибку;
- в debug-log видно только безопасную строку вида `operation=... status=0 code=network-error`.

Проверьте, что URL имеет формат:

```text
https://<project-ref>.supabase.co
```

Не добавляйте `/rest/v1`, пробелы или кавычки в значение `SUPABASE_URL`.

### Wrong `SUPABASE_ANON_KEY`

Симптомы:

- вход или запросы к таблицам возвращают unauthorized;
- приложение показывает `Войдите в аккаунт, чтобы продолжить.`;
- Supabase dashboard показывает rejected request для неверного client key.

Скопируйте именно anon public key / publishable key из API settings. Не используйте service role key во Flutter и не коммитьте реальные ключи.

### RLS permission denied

Симптомы:

- UI показывает `У вас нет доступа к этому действию.`;
- debug-log содержит `status=403 code=42501` или код PostgREST, связанный с policy denial.

Проверьте, что пользователь авторизован, `owner_id`/`author_id`/`user_id` совпадает с `auth.uid()`, а migrations с RLS policies применены к текущему Supabase project.

### Empty data because seed not applied

Симптомы:

- приложение запускается без ошибки, но feed/pets/walks пустые;
- SQL smoke checks возвращают `0` rows.

Примените `supabase/seed.sql`. Для hosted project сначала создайте demo Auth users и замените demo UUID на реальные `auth.users.id`, как описано в `docs/seed_data.md`.

### Email confirmation issue

Симптомы:

- регистрация проходит, но вход не работает;
- Supabase Auth сообщает, что email не подтвержден.

Для учебного smoke test можно временно отключить email confirmations в Supabase Auth settings или подтвердить demo user через Dashboard. Зафиксируйте выбранный вариант в отчете проверки.

### CORS/browser issue

Для обычного Flutter Web + `supabase_flutter` CORS обычно не требует отдельной настройки: Supabase API поддерживает browser clients. Если browser console показывает CORS/preflight ошибки, проверьте, что используется правильный Project URL, запрос идет к `https://<project-ref>.supabase.co`, а не к локальному/старому Firebase endpoint, и что расширения браузера не блокируют запросы.

### Нужен Firebase emulator

Firebase emulator workflow относится к предыдущей исследованной ветке. Он остается в истории разработки и может помогать понять уже сделанную интеграцию, но не является выбранным production backend для текущей сдачи.

## AI-Assisted Development

Проект разрабатывался с использованием OpenAI Codex как AI coding agent.

Ключевые артефакты:

- `AGENTS.md` - основные правила для Codex в репозитории;
- `docs/ai_agent_rules.md` - расширенные правила Flutter/backend разработки;
- `prompts.md` - журнал промптов и результатов;
- `development_report.md` - отчет о разработке и архитектурном решении;
- `backend_documentation.md` - описание backend architecture, security model, API и validation.

Codex использовался для анализа ТЗ, проектирования Firebase-прототипа, проверки ограничения Cloud Functions Blaze plan и документирования перехода на Supabase Free Tier.
