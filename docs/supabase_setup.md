# Supabase Setup - PetConnect HW5

Этот документ описывает production-развертывание Supabase backend для PetConnect без добавления секретов в репозиторий.

Статус репозитория: SQL migrations, RLS policies, Storage buckets, seed data и Flutter Supabase integration подготовлены. Hosted Supabase project linked через Supabase CLI, migrations применены, backend/API smoke checks выполнены. Реальные credentials не записываются в репозиторий.

## 1. Создать Supabase project

1. Откройте Supabase Dashboard.
2. Создайте новый project на Free Tier.
3. Выберите регион, близкий к пользователям или проверяющему.
4. Задайте database password и сохраните его в password manager, не в git.
5. Дождитесь, пока project перейдет в ready/active state.
6. Зафиксируйте для себя project ref, но не коммитьте его вместе с ключами.

В репозитории не хранится реальный Supabase project id, URL, publishable key, secret key, service role key или database password.

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

## 3. Получить `SUPABASE_PUBLISHABLE_KEY`

В том же разделе Dashboard скопируйте client-side `publishable key` в новом формате Supabase API keys.

В PetConnect переменная называется `SUPABASE_PUBLISHABLE_KEY`.

Запрещено использовать во Flutter:

- service role key;
- secret key;
- database password;
- JWT secret;
- personal access token.

## 4. Настроить локальные переменные

Используйте локальный `.env` или `--dart-define`. `.env` игнорируется git.

```text
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
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
5. Выполните подготовленный SQL для `public.*` demo rows через Dashboard SQL Editor или `supabase db query`.

Для hosted verification был использован именно этот принцип: demo Auth users созданы через Auth API/Admin flow, затем public demo rows загружены отдельно. Прямой SQL insert в `auth.users` оставлен для локального `supabase db reset`, но не считается рекомендуемым hosted Auth setup.

Для локального Supabase CLI `supabase db reset` применяет migrations и затем выполняет `supabase/seed.sql` автоматически:

```bash
supabase db reset
```

Если локальный stack запускается через Colima и контейнер `supabase_vector_*` падает на mount Docker socket, используйте локальную команду без logging vector container:

```bash
supabase start --exclude vector
```

Этот workaround нужен только для локальной проверки Supabase CLI. Hosted Supabase deployment и application schema/RLS от него не зависят.

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
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=http://localhost:3000/
```

Fallback для macOS desktop:

```bash
flutter run -d macos \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key> \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=http://127.0.0.1:3000/
```

Реальные значения передаются локально и не добавляются в README, screenshots, commits или issue-тексты.

## 9.1. Настроить Google OAuth provider

Google OAuth для PetConnect работает через Supabase Auth. Flutter вызывает `OAuthProvider.google`, а Client ID и Client Secret хранятся на стороне Supabase.

Supabase Dashboard:

1. `Authentication` -> `Providers` -> `Google`.
2. Включите Google provider.
3. Вставьте Google OAuth Client ID.
4. Вставьте Google OAuth Client Secret только в Dashboard.
5. Сохраните provider settings.
6. `Authentication` -> `URL Configuration`.
7. Site URL:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

8. Redirect URLs:

```text
https://cool-duckanoo-d28d04.netlify.app/
http://localhost:3000/
http://127.0.0.1:3000/
```

Google Cloud Console:

1. Откройте OAuth client.
2. В `Authorized redirect URIs` добавьте callback из Supabase Google provider screen:

```text
https://<project-ref>.supabase.co/auth/v1/callback
```

3. Не переносите Client Secret в Flutter, Netlify, GitHub Actions или tracked docs.

## 10. Проверить Supabase CLI перед hosted deploy

Локальная проверка перед cloud push:

```bash
supabase start --exclude vector
supabase db lint
supabase db reset
```

Ожидаемый результат:

- migrations применяются без SQL errors;
- seed применяет demo rows;
- `supabase db lint` возвращает `No schema errors found`;
- RLS включен для application tables;
- Storage buckets `avatars`, `pet-photos`, `post-images` созданы как private.

Hosted deploy через CLI требует авторизации и привязки project:

```bash
supabase login --token <local-access-token>
supabase link --project-ref <project-ref> --password <db-password>
supabase db push --linked --dry-run
supabase db push --linked
```

В текущей проверке hosted project был linked через Supabase CLI, `supabase db push --linked --dry-run` выполнен перед deploy, затем `supabase db push --linked` применил migrations. Не коммитьте access token, database password, project secrets или реальные `.env` значения.

## Production verification

Hosted Supabase verification выполнен 17 июня 2026. Ниже зафиксированы результаты без секретов.

### Current verification status

Backend checks:

- [x] Supabase project создан на Free Tier.
- [x] `SUPABASE_URL` и public client key получены локально и не закоммичены.
- [x] `001_initial_schema.sql` применен без ошибок.
- [x] `002_rls_policies.sql` применен без ошибок.
- [x] `003_api_grants.sql` применен без ошибок.
- [x] Demo Auth users созданы через Auth API/Admin flow.
- [x] Public seed rows применены.
- [x] Authenticated REST read вернул seeded feed/walks.
- [x] Like/comment/join REST writes прошли и обновили counters.
- [x] RLS negative smoke check подтвердил, что User B не меняет rows User A.
- [x] Flutter Web запущен с `USE_SUPABASE_BACKEND=true` и hosted Supabase values из local env.

Оставшиеся ручные UI-проверки:

- [ ] Sign up через Flutter UI с новым email.
- [ ] Create post через feed UI.
- [ ] Mobile/desktop click-through в живом браузере.

### Manual verification checklist

Backend checks:

- [ ] Supabase project создан на Free Tier.
- [ ] `SUPABASE_URL` получен из Dashboard.
- [ ] `SUPABASE_PUBLISHABLE_KEY` получен из Dashboard как publishable key.
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
