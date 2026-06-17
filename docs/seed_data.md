# Seed Data - PetConnect Supabase

## Назначение

`supabase/seed.sql` наполняет PetConnect demo-данными для проверки backend после применения Supabase schema и RLS migrations.

Seed нужен, чтобы после подключения Flutter-приложения к Supabase можно было увидеть реальные rows в ленте, питомцах, прогулках и чатах без использования production data.

## Важное ограничение Auth

`public.profiles.id` ссылается на `auth.users.id`. Для локального `supabase start` / `supabase db reset` seed создает две минимальные demo rows в `auth.users`, чтобы foreign keys проходили автоматически.

Для hosted Supabase project безопаснее не создавать production Auth users SQL-ом. Используйте отдельный flow:

1. Создайте двух demo-пользователей через Supabase Dashboard -> Authentication -> Users, через приложение или через Auth Admin API.
2. Скопируйте их `auth.users.id`.
3. Для hosted seed public tables используйте эти UUID вместо фиксированных demo UUID:

| Placeholder | Demo UUID in file | Заменить на |
|---|---|---|
| `DEMO_USER_A_ID` | `11111111-1111-1111-1111-111111111111` | UUID первого demo Auth user |
| `DEMO_USER_B_ID` | `22222222-2222-2222-2222-222222222222` | UUID второго demo Auth user |

Фиксированные UUID и demo password `DemoPass123!` предназначены только для demo-проверки. Не используйте реальные персональные данные: demo emails в seed используют домен `petconnect-demo.com`.

## Что создается

| Table | Количество | Назначение |
|---|---:|---|
| `profiles` | 2 | Demo Alina и Demo Mark |
| `pets` | 3 | Bruno, Mia, Rocky |
| `posts` | 4 | Публичные посты для социальной ленты |
| `comments` | 5 | Комментарии к постам |
| `post_likes` | 4 | Лайки между demo-пользователями |
| `walks` | 3 | Активные прогулки |
| `walk_participants` | 4 | Участники прогулок |
| `chats` | 1 | Диалог между demo-пользователями |
| `chat_participants` | 2 | Участники чата |
| `messages` | 3 | Сообщения внутри чата |

`posts.likes_count`, `posts.comments_count` и `walks.participants_count` не задаются вручную. Они пересчитываются trigger-функциями из `supabase/migrations/001_initial_schema.sql` после вставки лайков, комментариев и участников прогулок.

## Как применить локально

Если Supabase CLI настроен и локальная база используется для проверки, `supabase db reset` применяет migrations и затем выполняет `supabase/seed.sql`:

```bash
supabase db reset
```

Локальный seed сам создает demo Auth users с ids из seed-файла, затем вставляет application rows в `public.*`.

## Как применить в hosted Supabase

1. Примените migrations:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

2. Создайте двух demo Auth users через Dashboard или приложение.
3. Замените оба demo UUID в `supabase/seed.sql` на реальные ids созданных demo users.
4. Выполните SQL для `public.*` demo rows через Dashboard SQL Editor, `supabase db query` или `psql` к linked database. Блок `insert into auth.users ...` в `supabase/seed.sql` нужен для локального `supabase db reset`; для hosted project предпочтительнее полагаться на уже созданных Auth users, а не создавать пользователей SQL-ом.

В ходе hosted verification прямой SQL insert в `auth.users` не дал надежный email/password sign in на hosted Supabase. Рабочий минимальный flow: создать demo Auth users через Auth Admin/Dashboard, затем применить public demo rows с теми же UUID.

Не вставляйте service role key, database password или реальные пользовательские данные в репозиторий.

## Smoke checks

После загрузки seed проверьте:

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

Ожидаемые ключевые проверки:

- `posts` содержит 4 публичных записи, отсортированные по `created_at`;
- `posts.likes_count` показывает пересчитанные лайки;
- `posts.comments_count` показывает пересчитанные комментарии;
- `walks` содержит 3 активные прогулки с пересчитанным `participants_count`;
- `chats` содержит 1 диалог, видимый только его участникам по RLS;
- `messages` содержит 3 сообщения для demo-чата.

## Safety

Seed idempotent для фиксированных demo UUID: перед вставкой удаляются только rows с demo ids из этого файла.

Ограничения:

- seed создает demo Auth users с emails на домене `petconnect-demo.com`;
- seed не содержит реальных персональных данных;
- seed не содержит secrets;
- для hosted project всегда используйте отдельных demo users и заменяйте UUID перед запуском.
