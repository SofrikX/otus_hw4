# PetConnect Backend Documentation для ДЗ 5

## 1. Цель

PetConnect - Flutter-приложение для владельцев домашних животных. Backend-часть ДЗ 5 описывает переход frontend MVP к Supabase Free Tier как текущему backend-решению для учебного production deployment.

Документ фиксирует архитектурное решение, целевую схему данных, модель безопасности, API-подход, Storage, валидацию и production deployment checklist. Реальные Supabase URL и keys в репозиторий не добавляются.

## Production project status

| Area | Status | Evidence / next action |
|---|---|---|
| Supabase production project | Ready for manual setup | Project создается владельцем аккаунта в Supabase Dashboard на Free Tier; реальные project ref и keys не коммитятся |
| Database deployed | Manual verification required | Apply `supabase/migrations/001_initial_schema.sql` and `supabase/migrations/002_rls_policies.sql` through SQL Editor or `supabase db push` |
| Auth enabled | Manual verification required | Supabase Auth email/password должен быть включен; sign up/sign in проверяются через Flutter app |
| RLS enabled | Defined in migrations | `002_rls_policies.sql` enables RLS for application tables; hosted project must be checked after applying migrations |
| Storage buckets | Defined in migrations | `avatars`, `pet-photos`, `post-images` are created by `001_initial_schema.sql` |
| REST API available | Provided by Supabase/PostgREST | Available at `https://<project-ref>.supabase.co/rest/v1` after project creation |
| Frontend backend mode | Implemented | Flutter uses `USE_SUPABASE_BACKEND=true`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `supabase_flutter` repositories |

Hosted production verification has not been recorded in this repository yet. Until the checklist in `docs/supabase_setup.md` is completed manually, the correct status is `Manual verification checklist`, not `production verified`.

## 2. Architecture Decision: Firebase to Supabase

Оригинальное задание допускает Supabase или self-hosted PostgreSQL. В предыдущих документах PetConnect backend был адаптирован под Firebase, потому что Firebase Auth, Firestore, Storage и Cloud Functions были указаны в технической спецификации из прошлого этапа.

Firebase-ветка дала полезный результат:

- были описаны сущности users, pets, posts, comments, likes, walks, chats и messages;
- был выделен repository layer во Flutter;
- были спроектированы защищенные операции для лайков, создания постов и присоединения к прогулкам;
- была проверена идея локального backend workflow через emulators.

На этапе подготовки production deployment обнаружено ограничение: Firebase Cloud Functions production deploy может требовать Blaze/pay-as-you-go plan. Для учебного проекта это ухудшает воспроизводимость и противоречит цели бесплатной сдачи.

Поэтому текущий backend-стек ДЗ 5 переводится на Supabase Free Tier:

- Supabase Auth;
- PostgreSQL database;
- Row Level Security;
- Supabase Storage;
- auto REST API через PostgREST;
- Flutter SDK через `supabase_flutter`.

Это не откат, а осознанное архитектурное решение: Supabase соответствует исходному заданию, сохраняет бесплатный production backend и дает проверяемую SQL/RLS-модель.

## 3. Firebase-to-Supabase Mapping

| Firebase-прототип | Supabase-решение | Что меняется |
|---|---|---|
| Firebase Auth | Supabase Auth | Источник `uid` переносится в `auth.users`, Flutter получает session через Supabase client |
| Cloud Firestore | PostgreSQL | Документы и подколлекции становятся таблицами и связями |
| Firestore Security Rules | Row Level Security | Доступ описывается SQL policies через `auth.uid()` |
| Cloud Functions API | Supabase auto REST API / Supabase client | MVP operations идут через PostgREST и SDK; RPC добавляется только при необходимости транзакционной логики |
| Firebase Storage | Supabase Storage | Buckets и policies заменяют Firebase Storage paths/rules |
| Firebase Emulator Suite | Supabase project/local validation | Для локальной разработки можно добавить Supabase CLI; production-free backend держится на Free Tier |

## 4. Target Architecture

```text
Flutter UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase or mock repositories
  -> supabase_flutter
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

UI не должен обращаться к Supabase напрямую. Экраны работают через Riverpod controllers/providers, которые используют repository interfaces. Mock repositories сохраняются для тестов, local fallback и безопасной постепенной миграции.

## 5. Target PostgreSQL Schema

### profiles

Публичный профиль пользователя, связанный с `auth.users.id`.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Совпадает с `auth.users.id` |
| `display_name` | `text not null` | Имя пользователя |
| `email` | `text` | Email для собственного профиля |
| `avatar_url` | `text` | Ссылка на изображение |
| `bio` | `text` | Описание |
| `city` | `text` | Город |
| `created_at` | `timestamptz` | Дата создания |
| `updated_at` | `timestamptz` | Дата обновления |

### pets

Профили питомцев.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Идентификатор питомца |
| `owner_id` | `uuid references profiles(id)` | Владелец |
| `owner_name` | `text` | Денормализованное имя владельца для карточек |
| `name` | `text not null` | Имя питомца |
| `animal_type` | `text not null` | Вид животного |
| `breed` | `text` | Порода |
| `age` | `int` | Возраст |
| `description` | `text` | Описание |
| `photo_url` | `text` | Фото |
| `photo_emoji` | `text` | Fallback-эмодзи |
| `created_at` | `timestamptz` | Дата создания |
| `updated_at` | `timestamptz` | Дата обновления |

### posts

Публикации в социальной ленте.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Идентификатор поста |
| `author_id` | `uuid references profiles(id)` | Автор |
| `author_name` | `text` | Имя автора для ленты |
| `pet_id` | `uuid references pets(id)` | Питомец |
| `pet_name` | `text` | Имя питомца для ленты |
| `pet_photo_url` | `text` | Фото питомца |
| `pet_emoji` | `text` | Fallback-эмодзи |
| `text` | `text` | Текст поста |
| `image_urls` | `text[]` | Изображения |
| `image_emoji` | `text` | Fallback-изображение |
| `likes_count` | `int default 0` | Счетчик лайков |
| `comments_count` | `int default 0` | Счетчик комментариев |
| `visibility` | `text default 'public'` | Видимость |
| `created_at` | `timestamptz` | Дата создания |
| `updated_at` | `timestamptz` | Дата обновления |
| `deleted_at` | `timestamptz` | Soft delete |

### post_likes

Уникальный лайк пользователя к посту.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Идентификатор лайка |
| `post_id` | `uuid references posts(id)` | Пост |
| `user_id` | `uuid references profiles(id)` | Пользователь |
| `created_at` | `timestamptz` | Дата лайка |

Unique: `(post_id, user_id)`.

### comments

Комментарии к постам.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Идентификатор комментария |
| `post_id` | `uuid references posts(id)` | Пост |
| `author_id` | `uuid references profiles(id)` | Автор |
| `author_name` | `text` | Имя автора |
| `author_avatar_url` | `text` | Аватар автора |
| `text` | `text not null` | Комментарий |
| `created_at` | `timestamptz` | Дата создания |
| `updated_at` | `timestamptz` | Дата обновления |
| `deleted_at` | `timestamptz` | Soft delete |

### walks

Прогулки и встречи владельцев.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Идентификатор прогулки |
| `creator_id` | `uuid references profiles(id)` | Организатор |
| `organizer_name` | `text` | Имя организатора |
| `title` | `text not null` | Название |
| `place` | `text not null` | Место |
| `latitude` | `double precision` | Широта |
| `longitude` | `double precision` | Долгота |
| `scheduled_at` | `timestamptz not null` | Дата и время |
| `description` | `text` | Описание |
| `participants_count` | `int default 0` | Счетчик участников |
| `status` | `text default 'active'` | Статус |
| `created_at` | `timestamptz` | Дата создания |
| `updated_at` | `timestamptz` | Дата обновления |

### walk_participants

Участники прогулок.

| Поле | Тип | Назначение |
|---|---|---|
| `id` | `uuid primary key` | Идентификатор участия |
| `walk_id` | `uuid references walks(id)` | Прогулка |
| `user_id` | `uuid references profiles(id)` | Участник |
| `created_at` | `timestamptz` | Дата присоединения |

Unique: `(walk_id, user_id)`.

### chats, chat_participants, messages

Чаты проектируются отдельными таблицами:

- `chats`: `id`, `last_message_text`, `last_message_sender_id`, `last_message_at`, `created_at`, `updated_at`;
- `chat_participants`: `chat_id`, `user_id`, `companion_name`, `pet_name`, `unread_count`;
- `messages`: `id`, `chat_id`, `sender_id`, `sender_name`, `text`, `status`, `created_at`, `updated_at`.

RLS для чатов должна разрешать чтение и запись только участникам.

## 6. Security Model

Security model строится на Supabase Auth, PostgreSQL Row Level Security и Storage policies. Табличные RLS policies находятся в `supabase/migrations/002_rls_policies.sql`.

Базовые правила:

- `profiles`: authenticated users читают профили; пользователь создает и обновляет только свой профиль;
- `pets`: authenticated users читают питомцев; владелец создает, изменяет и удаляет своих питомцев;
- `posts`: authenticated users читают неудаленные посты; автор создает, изменяет и удаляет свои посты;
- `comments`: authenticated users читают неудаленные комментарии; автор создает и удаляет свои комментарии;
- `post_likes`: authenticated users читают лайки; пользователь создает и удаляет только свой лайк;
- `walks`: authenticated users читают прогулки; creator создает, изменяет и удаляет свои прогулки;
- `walk_participants`: authenticated users читают участников; пользователь присоединяет и удаляет только себя;
- `chats/messages`: доступ только участникам чата; прямое создание чата клиентом не открыто до отдельной RPC/серверной операции.

Пример политики:

```sql
create policy "Users update own profile"
on profiles
for update
using (id = auth.uid())
with check (id = auth.uid());
```

Публичного anon-read доступа к application tables нет. Все read policies используют роль `authenticated`.

## 7. API Operations

Supabase автоматически предоставляет REST API через PostgREST. Flutter-приложение может выполнять операции через `supabase_flutter`, не добавляя отдельный Cloud Functions слой.

Минимальные операции ДЗ:

| Операция | Supabase implementation |
|---|---|
| Создать профиль питомца | `insert` в `pets` с RLS `owner_id = auth.uid()` |
| Создать пост | `insert` в `posts` с RLS `author_id = auth.uid()` |
| Поставить/снять лайк | `insert/delete` в `post_likes`, счетчик обновлять через view/RPC/trigger при необходимости |
| Получить ленту | `select` из `posts` с сортировкой `created_at desc` |
| Получить прогулки | `select` из `walks` со статусом `active` |
| Присоединиться к прогулке | `insert` в `walk_participants`, счетчик обновлять транзакционно при необходимости |

Если обычного REST/SDK flow недостаточно для атомарных counters, добавить PostgreSQL function/RPC, например `toggle_post_like(post_id uuid)` или `join_walk(walk_id uuid)`. Такие RPC должны быть отдельной migration и покрываться RLS/security review. В текущей документации не утверждается, что RPC уже создана.

## 8. Storage

Целевые buckets:

| Bucket | Назначение |
|---|---|
| `avatars` | Аватары пользователей |
| `pet-photos` | Фото питомцев |
| `post-images` | Изображения постов |

Storage policies:

- читать изображения могут авторизованные пользователи;
- загружать и удалять файл может владелец соответствующего пути;
- MIME type должен быть изображением;
- размер файла ограничивается настройками bucket/project;
- service role key нельзя использовать во Flutter-клиенте и нельзя коммитить.

## 9. Supabase Project Setup

### Dashboard steps

1. Создать Supabase project на Free Tier.
2. Открыть project после завершения provisioning.
3. В Connect/API settings скопировать Project URL как `SUPABASE_URL`.
4. Скопировать anon public key или publishable key как `SUPABASE_ANON_KEY`.
5. Не копировать service role key в Flutter, `.env.example`, README или screenshots.
6. Открыть SQL Editor и применить `supabase/migrations/001_initial_schema.sql`.
7. Применить `supabase/migrations/002_rls_policies.sql`.
8. Создать двух demo Auth users перед seed, если нужен наполненный demo backend.
9. Заменить demo UUID в `supabase/seed.sql` на реальные `auth.users.id`.
10. Выполнить seed через SQL Editor.
11. Проверить таблицы, RLS policies, Storage buckets и seed rows.

### CLI steps

Если Supabase CLI настроен:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

Локальная проверка:

```bash
supabase db lint
supabase db reset
```

`supabase db push` применяет SQL migrations к linked project. `supabase db reset` используется для локальной базы и применяет `supabase/seed.sql`. Локальный seed создает две минимальные demo rows в `auth.users`, потому что `public.profiles.id` зависит от `auth.users.id`.

## 10. Seed Data

Файл `supabase/seed.sql` содержит demo-данные для проверки PetConnect:

| Entity | Count |
|---|---:|
| Demo profiles | 2 |
| Pets | 3 |
| Posts | 4 |
| Comments | 5 |
| Post likes | 4 |
| Walks | 3 |
| Walk participants | 4 |
| Chats | 1 |
| Chat participants | 2 |
| Messages | 3 |

Seed не создает реальных production users и не хранит реальные персональные данные. Для локальной проверки он добавляет demo Auth users с emails `example.test` и demo password `DemoPass123!`. Ограничение связано со схемой: `public.profiles.id` является foreign key на `auth.users.id`.

Для hosted Supabase project нужно:

1. Создать двух demo-пользователей через Supabase Auth UI или через регистрацию в приложении.
2. Скопировать их `auth.users.id`.
3. Заменить в `supabase/seed.sql` demo UUID `11111111-1111-1111-1111-111111111111` и `22222222-2222-2222-2222-222222222222`.
4. Выполнить seed через Dashboard SQL Editor или `psql`.

Фиксированные UUID в файле предназначены для локальной проверки. Блок `insert into auth.users ...` использует `on conflict (id) do nothing`, но для hosted project предпочтительнее создавать пользователей через Supabase Auth UI или приложение. Подробная инструкция: `docs/seed_data.md`.

## 11. Local Configuration

Файл `.env.example` содержит только безопасные placeholders:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
USE_SUPABASE_BACKEND=true
```

Реальные значения задаются локально через `.env` или через `--dart-define`.

Expected Flutter command:

```bash
flutter run -d chrome
--dart-define=USE_SUPABASE_BACKEND=true
--dart-define=SUPABASE_URL=
--dart-define=SUPABASE_ANON_KEY=
```

Shell-friendly variant:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-public-client-key>
```

## 12. Production Backend URL

Production backend URL для PetConnect - это Supabase Project URL:

```text
https://<project-ref>.supabase.co
```

REST API доступен по:

```text
https://<project-ref>.supabase.co/rest/v1
```

В репозитории не указывается реальный `<project-ref>`. Проверяющий или владелец project подставляет свои значения локально.

## 13. Environment and Secrets

В репозитории допустимы только placeholders:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
USE_SUPABASE_BACKEND=true
```

Нельзя коммитить:

- реальные `.env`;
- Supabase service role key;
- JWT secrets;
- production database password;
- приватные токены CI.

Anon key допустим для клиентских приложений по модели Supabase, но в учебном репозитории реальные значения все равно лучше не фиксировать.

## 14. Frontend Integration Plan

Текущий Flutter UI работает через repository layer и не обращается к Supabase напрямую.

Фактическое состояние интеграции:

1. Supabase Auth integration выполнена через `supabase_flutter`.
2. Supabase initializer добавлен в `lib/core/supabase`.
3. Auth repository layer выбирает `SupabaseAuthRepository` при `USE_SUPABASE_BACKEND=true`, Firebase legacy repository при `USE_FIREBASE_BACKEND=true` и mock repository в local mode.
4. После sign up/sign in Supabase repository выполняет upsert профиля в `public.profiles`, если есть authenticated session.
5. Feed repository использует Supabase для `posts`, `post_likes` и `comments` в backend mode.
6. Pets repository использует Supabase для списка питомцев, профиля питомца и создания питомца в backend mode.
7. Walks repository использует Supabase для списка прогулок, создания прогулки, join и leave в backend mode.
8. Mock implementations сохранены для tests/fallback.
9. Legacy Firebase prototype files остаются только как история предыдущей исследованной ветки.

## 15. Validation

Flutter:

```bash
dart format .
flutter analyze
flutter test
```

Supabase after project setup:

```bash
supabase db lint
supabase db reset
```

Seed smoke checks:

```sql
select count(*) from public.profiles;
select count(*) from public.pets;
select count(*) from public.posts;
select count(*) from public.comments;
select count(*) from public.post_likes;
select count(*) from public.walks;
select count(*) from public.walk_participants;
select count(*) from public.chats;
select count(*) from public.messages;
```

Manual checks:

- registration/login through Supabase Auth;
- create pet;
- create post;
- toggle like;
- load feed;
- load walks;
- join walk;
- verify denied access for foreign rows through RLS.

## 15.1. Production verification

Если hosted Supabase project еще не проверен вручную, используйте этот раздел как `Manual verification checklist`.

Backend deployment checklist:

- [ ] Supabase project создан на Free Tier.
- [ ] `SUPABASE_URL` получен из Project Settings / API.
- [ ] `SUPABASE_ANON_KEY` получен как anon public key или publishable key.
- [ ] `001_initial_schema.sql` применен к hosted project.
- [ ] `002_rls_policies.sql` применен к hosted project.
- [ ] `seed.sql` применен после создания demo Auth users и замены demo UUID.
- [ ] Таблицы `profiles`, `pets`, `posts`, `comments`, `post_likes`, `walks`, `walk_participants`, `chats`, `chat_participants`, `messages` видны в Table Editor.
- [ ] RLS enabled для всех application tables.
- [ ] Storage buckets `avatars`, `pet-photos`, `post-images` созданы.

End-to-end checklist:

- [ ] `SELECT posts` работает для authenticated user:

```sql
select id, pet_name, author_name, text, likes_count, comments_count
from public.posts
where deleted_at is null
order by created_at desc
limit 5;
```

- [ ] Sign up работает в Flutter app.
- [ ] Sign in работает в Flutter app.
- [ ] Create post работает через Supabase-backed feed flow.
- [ ] Like post работает и обновляет `posts.likes_count`.
- [ ] Join walk работает и обновляет `walks.participants_count`.
- [ ] Анонимный REST-запрос к application tables отклоняется RLS/Auth.
- [ ] User B не может update/delete rows пользователя A.

## 16. Error Handling and Logging

Frontend использует единый typed error layer на базе `ApiException` из `lib/core/network/api_error.dart`. Для прямых вызовов `supabase_flutter` добавлен общий mapper `lib/core/supabase/supabase_error_mapper.dart`.

Классификация ошибок:

| Category | Source examples | App exception | User-facing message |
|---|---|---|---|
| Network error | unreachable Project URL, browser/network failure, retryable Auth fetch | `ApiNetworkException` | `Не удалось подключиться к серверу...` |
| Unauthorized | missing/invalid session, invalid credentials | `ApiUnauthorizedException` | `Войдите в аккаунт, чтобы продолжить.` |
| Forbidden / RLS violation | PostgreSQL `42501`, row-level security denial, permission denied | `ApiForbiddenException` | `У вас нет доступа к этому действию.` |
| Validation error | Postgres `23502`, `23503`, `23505`, `23514`, `22P02`, invalid email/password | `ApiValidationException` | `Проверьте данные и попробуйте еще раз.` |
| Not found | PostgREST `PGRST116`, 404/406, empty single-row result | `ApiNotFoundException` | `Не удалось найти нужные данные.` |
| Unknown error | unexpected Supabase/PostgREST response or unexpected Dart exception | `ApiUnexpectedException` | `Что-то пошло не так. Попробуйте еще раз.` |

UI не показывает сырые Supabase/PostgreSQL сообщения. `AsyncContentView` берет `ApiException.userMessage`, а auth forms получают дружелюбный `AuthFailure`.

Debug logging включен только в debug mode через `kDebugMode`. Логи безопасного уровня содержат:

```text
[PetConnect][Supabase] operation=<feature> status=<status> code=<code> type=<exception-type>
```

Логи не содержат access token, anon key, service role key, email, display name, id строк, текст постов, комментариев или других пользовательских данных.

## 17. AI-assisted Debugging

Codex использовался для анализа Supabase error flows и тестовых логов:

- найдено дублирование маппинга PostgREST ошибок в feed/pets/walks repositories;
- найден UX-риск: `ApiValidationException` с PostgreSQL code `23505` мог показать сырое backend-сообщение вместо friendly message;
- проверено, что RLS denial `42501` классифицируется как forbidden, а не как unknown/server error;
- после запуска `flutter test` найден тест, который ожидал сырой 502 message; expectation обновлен под новое требование безопасных user-friendly errors.

Рекомендуемый AI-debug workflow:

1. Скопировать только безопасные debug-log строки без токенов и персональных данных.
2. Добавить контекст операции: auth/feed/pets/walks и ожидаемое действие.
3. Попросить AI классифицировать ошибку: network, unauthorized, forbidden/RLS, validation, not found или unknown.
4. Проверить вывод AI через Supabase dashboard logs, SQL/RLS policies и Flutter tests.

## 18. Firebase Prototype History

Firebase не удаляется из истории разработки. Он остается корректно описанным исследованным вариантом:

- Firebase Auth был выбран в раннем ТЗ;
- Firestore schema помогла выделить сущности и связи;
- Cloud Functions API помог сформулировать операции feed/pets/walks;
- Emulator Suite позволил локально проверить frontend-backend contract;
- ограничение Blaze/pay-as-you-go для production Cloud Functions стало причиной архитектурного разворота.

Итоговое решение: для текущего ДЗ production backend - Supabase Free Tier, а Firebase-прототип является частью AI-assisted exploration и не считается выбранным production backend.

## 19. Known Limitations

- Hosted Supabase production smoke test еще не зафиксирован в репозитории.
- Supabase project, migrations и RLS нужно подтвердить по `Manual verification checklist` после ручного Dashboard/CLI deployment.
- Для hosted seed нужно создать demo Auth users через Supabase Auth UI или приложение и заменить demo UUID на реальные `auth.users.id`.
- Supabase Auth, feed, pets и walks repositories подготовлены для `USE_SUPABASE_BACKEND=true`; проверка с реальными hosted credentials остается ручным release step.
- Существующие Firebase prototype files могут оставаться до отдельной технической миграции.
- Реальные Supabase URL и keys не должны появляться в документации или git history.

## 20. AI-assisted Development

Основной AI-агент проекта - OpenAI Codex.

Codex использовался для:

- анализа исходного задания и предыдущего Firebase ТЗ;
- проектирования Firebase-прототипа;
- выявления production deployment риска Cloud Functions Blaze plan;
- выбора Supabase как бесплатного backend для текущего ДЗ;
- документирования mapping Firebase -> Supabase;
- создания Supabase seed data для проверяемого demo backend;
- фиксации remaining tasks без ложного утверждения о готовом Supabase deployment.
