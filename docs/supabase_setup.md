# Supabase Setup - PetConnect HW5

Этот документ описывает production-развертывание Supabase backend для PetConnect без добавления секретов в репозиторий.

Статус репозитория: SQL migrations, RLS policies, Storage buckets, seed data и Flutter Supabase integration подготовлены. Hosted Supabase project создается владельцем аккаунта вручную. Если ручная проверка production project еще не выполнена, используйте раздел `Manual verification checklist` ниже и не отмечайте deployment как verified.

## 1. Создать Supabase project

1. Откройте Supabase Dashboard.
2. Создайте новый project на Free Tier.
3. Выберите регион, близкий к пользователям или проверяющему.
4. Задайте database password и сохраните его в password manager, не в git.
5. Дождитесь, пока project перейдет в ready/active state.
6. Зафиксируйте для себя project ref, но не коммитьте его вместе с ключами.

В репозитории не хранится реальный Supabase project id, URL, anon key, service role key или database password.

## 2. Получить `SUPABASE_URL`

В Supabase Dashboard откройте созданный project:

1. Перейдите в `Project Settings` -> `API` или в актуальный раздел `Connect`.
2. Скопируйте Project URL.
3. Используйте его как локальное значение `SUPABASE_URL`.

Формат:

```text
SUPABASE_URL=https://<project-ref>.supabase.co
```

Не добавляйте к URL `/rest/v1`, пробелы или кавычки.

## 3. Получить `SUPABASE_ANON_KEY`

В том же разделе Dashboard скопируйте client-side key:

- `anon public key`; или
- `publishable key`, если Dashboard показывает новый формат ключей.

В PetConnect переменная называется `SUPABASE_ANON_KEY` в обоих случаях.

Запрещено использовать во Flutter:

- service role key;
- database password;
- JWT secret;
- personal access token.

## 4. Настроить локальные переменные

Используйте локальный `.env` или `--dart-define`. `.env` игнорируется git.

```text
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<public-client-key>
USE_SUPABASE_BACKEND=true
```

В git допустим только `.env.example` с placeholders.

## 5. Применить migrations через Supabase SQL Editor

Если CLI не используется, примените migrations вручную через Dashboard SQL Editor.

1. Откройте Supabase Dashboard -> SQL Editor.
2. Создайте новый query.
3. Скопируйте весь SQL из `supabase/migrations/001_initial_schema.sql`.
4. Запустите query и убедитесь, что ошибок нет.
5. Создайте второй query.
6. Скопируйте весь SQL из `supabase/migrations/002_rls_policies.sql`.
7. Запустите query и убедитесь, что ошибок нет.

Порядок важен: сначала schema/storage/triggers, затем RLS policies.

Альтернатива через Supabase CLI, если project linked:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

## 6. Применить `seed.sql`

Seed-файл находится в `supabase/seed.sql`. Он нужен для demo smoke test и не содержит реальных production users, API keys или secrets.

Для hosted Supabase project безопасный порядок такой:

1. Создайте двух demo users через Supabase Auth UI или через регистрацию в PetConnect.
2. Скопируйте их `auth.users.id`.
3. В локальной копии SQL перед запуском замените demo UUID:
   - `11111111-1111-1111-1111-111111111111` -> id первого demo user;
   - `22222222-2222-2222-2222-222222222222` -> id второго demo user.
4. Не используйте demo emails/passwords из seed как реальные учетные записи.
5. Выполните подготовленный SQL через Dashboard SQL Editor.

Для локального Supabase CLI `supabase db reset` применяет migrations и затем выполняет `supabase/seed.sql` автоматически:

```bash
supabase db reset
```

## 7. Проверить таблицы

В Dashboard Table Editor должны появиться таблицы:

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

SQL smoke checks:

```sql
select count(*) from public.profiles;
select count(*) from public.pets;
select count(*) from public.posts;
select count(*) from public.comments;
select count(*) from public.post_likes;
select count(*) from public.walks;
select count(*) from public.walk_participants;
select count(*) from public.chats;
select count(*) from public.chat_participants;
select count(*) from public.messages;
```

После seed ожидаемые demo counts:

| Table | Expected count |
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

## 8. Проверить RLS

RLS должен быть enabled для application tables:

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

Dashboard check:

1. Откройте Table Editor.
2. Для каждой таблицы убедитесь, что RLS enabled.
3. Откройте Authentication/Policies или Table Editor policies.
4. Убедитесь, что policies из `supabase/migrations/002_rls_policies.sql` применены.

SQL check:

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

Все строки должны вернуть `rowsecurity = true`.

Storage buckets после первой migration:

- `avatars`;
- `pet-photos`;
- `post-images`.

Storage policies должны разрешать чтение authenticated users и запись только в путь, где первый сегмент равен `auth.uid()`.

## 9. Запустить Flutter с production backend

Команда запуска Flutter Web:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-supabase-anon-key>
```

Fallback для macOS desktop:

```bash
flutter run -d macos \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-supabase-anon-key>
```

Реальные значения передаются локально и не добавляются в README, screenshots, commits или issue-тексты.

## Production verification

Если hosted project еще не проверен вручную, используйте этот раздел как `Manual verification checklist`.

### Manual verification checklist

Backend checks:

- [ ] Supabase project создан на Free Tier.
- [ ] `SUPABASE_URL` получен из Dashboard.
- [ ] `SUPABASE_ANON_KEY` получен из Dashboard как public client key.
- [ ] `001_initial_schema.sql` применен без ошибок.
- [ ] `002_rls_policies.sql` применен без ошибок.
- [ ] `seed.sql` применен после создания/replacement demo Auth users.
- [ ] Таблицы из раздела 7 видны в Table Editor.
- [ ] RLS enabled для всех application tables.
- [ ] Storage buckets `avatars`, `pet-photos`, `post-images` созданы.

End-to-end checks:

- [ ] `SELECT posts` работает для authenticated user:

```sql
select id, pet_name, author_name, text, likes_count, comments_count
from public.posts
where deleted_at is null
order by created_at desc
limit 5;
```

- [ ] Sign up работает в Flutter app и создает/обновляет row в `public.profiles`.
- [ ] Sign in работает в Flutter app.
- [ ] Create post работает через feed UI или repository-backed flow.
- [ ] Like post работает и обновляет `posts.likes_count`.
- [ ] Join walk работает и обновляет `walks.participants_count`.
- [ ] Анонимный пользователь не читает application tables через REST API.
- [ ] User B не может update/delete rows, owned by User A.

## Что не хранить в git

- `.env`;
- `.env.local`;
- Supabase service role key;
- database password;
- JWT secret;
- personal access token;
- production user data;
- screenshots with visible keys.

## References

- Supabase Flutter quickstart: `https://supabase.com/docs/guides/getting-started/quickstarts/flutter`
- Supabase CLI reference: `https://supabase.com/docs/reference/cli`
