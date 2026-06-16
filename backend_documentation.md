# PetConnect Backend Documentation для ДЗ 5

## 1. Цель

PetConnect - Flutter-приложение для владельцев домашних животных. Backend-часть ДЗ 5 описывает переход frontend MVP к Supabase Free Tier как текущему backend-решению для учебного production deployment.

Документ фиксирует архитектурное решение, целевую схему данных, модель безопасности, API-подход, Storage, валидацию и план миграции. Supabase project еще не считается созданным, реальные URL и keys в репозиторий не добавляются.

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
- `chat_participants`: `chat_id`, `user_id`, `display_name`, `pet_name`, `unread_count`;
- `messages`: `id`, `chat_id`, `sender_id`, `sender_name`, `text`, `status`, `created_at`, `updated_at`.

RLS для чатов должна разрешать чтение и запись только участникам.

## 6. Security Model

Security model строится на Supabase Auth, PostgreSQL Row Level Security и Storage policies.

Базовые правила:

- `profiles`: пользователь создает и обновляет только свой профиль; публичные поля можно читать авторизованным пользователям;
- `pets`: читать могут авторизованные пользователи, создавать/изменять/удалять может только `owner_id = auth.uid()`;
- `posts`: читать публичные активные посты могут авторизованные пользователи, создавать и изменять может только автор;
- `post_likes`: пользователь может создать или удалить только свой лайк, уникальность обеспечивается primary key;
- `comments`: пользователь создает только свой комментарий; удалять может автор комментария или автор поста;
- `walks`: читать активные прогулки могут авторизованные пользователи; создавать может авторизованный пользователь; изменять может организатор;
- `walk_participants`: пользователь может присоединить только себя к активной прогулке;
- `chats/messages`: доступ только участникам чата.

Пример политики:

```sql
create policy "Users update own profile"
on profiles
for update
using (id = auth.uid())
with check (id = auth.uid());
```

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
3. В Connect/API settings скопировать Project URL.
4. Скопировать anon public key или publishable key для client-side операций.
5. Не копировать service role key в Flutter, `.env.example`, README или screenshots.
6. Открыть SQL Editor и применить migration, если CLI не используется.
7. Проверить таблицы, RLS policies и Storage buckets.

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

`supabase db push` применяет SQL migrations к linked project. `supabase db reset` используется для локальной базы и применяет `supabase/seed.sql`.

## 10. Local Configuration

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

## 11. Production Backend URL

Production backend URL для PetConnect - это Supabase Project URL:

```text
https://<project-ref>.supabase.co
```

REST API доступен по:

```text
https://<project-ref>.supabase.co/rest/v1
```

В репозитории не указывается реальный `<project-ref>`. Проверяющий или владелец project подставляет свои значения локально.

## 12. Environment and Secrets

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

## 13. Frontend Integration Plan

Текущий Flutter UI и бизнес-логика на этом шаге не меняются.

План технической миграции:

1. Добавить `supabase_flutter` в `pubspec.yaml`.
2. Создать Supabase initializer в `lib/core`.
3. Заменить Firebase auth repository на Supabase auth repository.
4. Добавить Supabase implementations для feed, pets и walks repositories.
5. Оставить mock implementations для tests/fallback.
6. Перевести backend flag на `USE_SUPABASE_BACKEND`.
7. Обновить API/client tests под Supabase repository behavior.
8. Удалить Firebase dependencies и prototype files только после успешной миграции.

## 14. Validation

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

Manual checks:

- registration/login through Supabase Auth;
- create pet;
- create post;
- toggle like;
- load feed;
- load walks;
- join walk;
- verify denied access for foreign rows through RLS.

## 15. Firebase Prototype History

Firebase не удаляется из истории разработки. Он остается корректно описанным исследованным вариантом:

- Firebase Auth был выбран в раннем ТЗ;
- Firestore schema помогла выделить сущности и связи;
- Cloud Functions API помог сформулировать операции feed/pets/walks;
- Emulator Suite позволил локально проверить frontend-backend contract;
- ограничение Blaze/pay-as-you-go для production Cloud Functions стало причиной архитектурного разворота.

Итоговое решение: для текущего ДЗ production backend - Supabase Free Tier, а Firebase-прототип является частью AI-assisted exploration и не считается выбранным production backend.

## 16. Known Limitations

- Supabase project еще нужно создать.
- SQL migrations и RLS policies подготовлены в `supabase/migrations/`, но их еще нужно применить к реальному project.
- Flutter SDK migration на `supabase_flutter` еще не выполнена.
- Существующие Firebase prototype files могут оставаться до отдельной технической миграции.
- Реальные Supabase URL и keys не должны появляться в документации или git history.

## 17. AI-assisted Development

Основной AI-агент проекта - OpenAI Codex.

Codex использовался для:

- анализа исходного задания и предыдущего Firebase ТЗ;
- проектирования Firebase-прототипа;
- выявления production deployment риска Cloud Functions Blaze plan;
- выбора Supabase как бесплатного backend для текущего ДЗ;
- документирования mapping Firebase -> Supabase;
- фиксации remaining tasks без ложного утверждения о готовом Supabase deployment.
