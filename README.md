# PetConnect

PetConnect - Flutter-приложение для владельцев домашних животных. Пользователь может вести социальную ленту питомца, смотреть профили питомцев, присоединяться к прогулкам и работать с базовым чат-сценарием.

ДЗ 5 переводит frontend MVP к backend-интеграции. Актуальное архитектурное решение для сдачи - Supabase Free Tier: Supabase Auth, PostgreSQL, Row Level Security, Supabase Storage, auto REST API через PostgREST и Flutter SDK `supabase_flutter`.

Firebase-ветка была спроектирована и проверялась как исследованный вариант, потому что Firebase был указан в технической спецификации предыдущего этапа. На этапе подготовки production deployment выяснилось, что Firebase Cloud Functions могут требовать Blaze/pay-as-you-go plan. Для учебного проекта выбран Supabase, так как исходное задание прямо допускает Supabase и этот путь сохраняет бесплатный, воспроизводимый production backend.

Supabase project, URL и anon key в репозиторий не добавлены. Документация описывает выбранную архитектуру и следующие шаги миграции без утверждения, что Supabase уже развернут.

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

> Current implementation note: Supabase Auth is integrated through `supabase_flutter` for email/password sign up, sign in, sign out, auth state changes and profile upsert. The feed repository now uses Supabase for posts, likes and comments when `USE_SUPABASE_BACKEND=true`; mock repositories remain the local fallback. Pets and walks still keep their existing mock/Firebase prototype data repositories until their Supabase data-integration step.

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
```

### 5. Применить seed-данные

Seed-файл:

```text
supabase/seed.sql
```

Он не содержит реальных пользователей, production data или secrets. Для локального `supabase start` / `supabase db reset` seed создает две минимальные demo rows в `auth.users`, потому что `public.profiles.id` ссылается на `auth.users.id`.

Для hosted Supabase сначала создайте двух demo users через Authentication UI или регистрацию в приложении, затем замените в `supabase/seed.sql` demo UUID:

| Placeholder | Demo UUID |
|---|---|
| `DEMO_USER_A_ID` | `11111111-1111-1111-1111-111111111111` |
| `DEMO_USER_B_ID` | `22222222-2222-2222-2222-222222222222` |

Для локальной проверки через Supabase CLI `supabase db reset` применяет migrations и затем запускает `supabase/seed.sql`:

```bash
supabase db reset
```

Локальный demo password для seed users: `DemoPass123!`. Он предназначен только для локального QA.

Для hosted project выполните seed через Dashboard SQL Editor после замены UUID на ids созданных demo Auth users.

После применения seed появятся:

- 2 demo profiles;
- 3 pets;
- 4 feed posts;
- comments и post_likes;
- 3 walks и walk_participants;
- 1 chat и messages.

Подробности: `docs/seed_data.md`.

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

## Remaining Migration Tasks

1. Создать Supabase project на Free Tier.
2. Применить SQL migrations из `supabase/migrations/`.
3. Проверить RLS policies и Storage buckets.
4. Реализовать Supabase repositories для feed, pets и walks в `lib/features/*/data`.
5. Удалить Firebase dependencies и prototype files только после полной миграции data repositories.
6. Провести ручную проверку Supabase Auth в hosted/local project: регистрация, вход, logout и profile row.
7. Провести ручную проверку data flows после Supabase repository migration: лента, создание поста, лайк, прогулки, join.

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

До создания проекта используйте mock fallback. Не добавляйте реальные URL, anon key или service role key в репозиторий.

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
