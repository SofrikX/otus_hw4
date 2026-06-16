# Supabase Security - PetConnect

Security model строится на Supabase Auth, PostgreSQL Row Level Security и Storage policies.

## Secrets

Разрешено в git:

- `.env.example` с пустыми placeholders;
- SQL migrations;
- RLS policies;
- Storage bucket/policy definitions.

Запрещено в git:

- реальные `.env`;
- Supabase service role key;
- database password;
- JWT secret;
- personal access token;
- production user data.

## RLS Baseline

Все пользовательские таблицы в migration включают RLS:

```sql
alter table public.profiles enable row level security;
```

Flutter-клиент работает только через Supabase Auth user session. Policies используют `auth.uid()`.

## Table Policies

| Table | Read | Write |
|---|---|---|
| `profiles` | authenticated users | only own row |
| `pets` | authenticated users | only owner |
| `posts` | authenticated users, public active posts | only author |
| `post_likes` | authenticated users | only own like |
| `comments` | authenticated users | only own comment; delete by comment author or post author |
| `walks` | authenticated users, active walks | only creator |
| `walk_participants` | authenticated users | only self join/leave |
| `chats` | chat participants | participants only |
| `messages` | chat participants | sender must be participant |

## Storage Policies

Buckets:

- `avatars`;
- `pet-photos`;
- `post-images`.

Rules:

- read: authenticated users;
- write/update/delete: first path segment must match `auth.uid()`;
- paths should use `<user-id>/<file-name>`.

Example:

```text
post-images/00000000-0000-0000-0000-000000000001/photo.jpg
```

## Service Role Key

Service role key bypasses RLS. It must never be used in Flutter, committed to git, pasted into docs, or shared in screenshots.

Use it only in trusted server-side environments if a future backend service is added.

## Manual Security Review

Before considering Supabase setup ready:

1. Create two test users.
2. User A creates a pet and post.
3. User B can read public post.
4. User B cannot update User A pet/post.
5. User B can create only their own like/comment rows.
6. User B cannot upload into a path that starts with User A id.
7. Chat messages are visible only to participants.
