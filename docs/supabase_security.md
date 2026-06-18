# Supabase Security - PetConnect

Security model PetConnect строится на Supabase Auth, PostgreSQL Row Level Security и Storage policies.

## Что такое RLS

Row Level Security (RLS) - механизм PostgreSQL, который проверяет доступ к каждой строке таблицы. В Supabase RLS заменяет Firebase Security Rules:

- Firebase Rules проверяли `request.auth.uid`;
- Supabase policies проверяют `auth.uid()`;
- UI не получает прямой доступ к чужим строкам, даже если запрос сформирован вручную через REST API.

RLS включается в `supabase/migrations/002_rls_policies.sql`.

## Secrets

Разрешено в git:

- `.env.example` с пустыми placeholders;
- SQL migrations;
- RLS policies;
- Storage bucket/policy definitions.

Запрещено в git:

- реальные `.env`;
- Supabase secret key;
- Supabase service role key;
- database password;
- JWT secret;
- personal access token;
- production user data.

## Client API Keys

Flutter Web uses only public client configuration:

- `SUPABASE_URL`;
- `SUPABASE_PUBLISHABLE_KEY`.

The publishable key is allowed in browser-side code because RLS policies and the current Supabase Auth session enforce access to user data. Supabase secret keys and service role keys must never be sent to the browser, committed to git, pasted into docs or included in screenshots.

RLS policies are mandatory for every user-data table. Treat the publishable key as an identifier for client access, not as the security boundary.

## Таблицы с RLS

RLS включен для:

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

## Policies

| Table | Read | Write |
|---|---|---|
| `profiles` | authenticated users can read profiles | user can insert/update only own profile |
| `pets` | authenticated users can read pets | owner can insert/update/delete own pets |
| `posts` | authenticated users can read non-deleted posts | author can insert/update/delete own posts |
| `comments` | authenticated users can read non-deleted comments | author can insert/delete own comments |
| `post_likes` | authenticated users can read likes | user can insert/delete own like |
| `walks` | authenticated users can read walks | creator can insert/update/delete own walks |
| `walk_participants` | authenticated users can read participants | user can join/leave as self |
| `chats` | only chat participants can read/update chats | direct chat insert/delete is not exposed to client |
| `chat_participants` | only chat participants can read participant rows | participant can update/delete own row |
| `messages` | only chat participants can read messages | chat participant can insert messages; sender can update/delete own messages |

Read policies are for the `authenticated` role. There is no anon/public read access for application data by default.

## Forbidden Operations

RLS denies:

- anonymous reads and writes to app tables;
- creating or updating another user's profile;
- creating, updating or deleting another user's pet;
- creating a post with another user's `author_id`;
- updating or deleting another user's post;
- creating a comment with another user's `author_id`;
- deleting another user's comment;
- creating or deleting another user's like;
- joining or leaving a walk as another user;
- creating, updating or deleting another user's walk;
- reading chats where the current user is not a participant;
- sending a message to a chat where the current user is not a participant;
- updating or deleting another user's message.

## Chat Creation Assumption

Direct client creation of `chats` and arbitrary `chat_participants` rows is intentionally not open in RLS. This avoids a security hole where a user could join a чужой chat by guessing `chat_id`.

For production chat creation, add a separate PostgreSQL RPC or trusted server operation that atomically creates:

1. `chats`;
2. first `chat_participants` row;
3. second `chat_participants` row.

Until then, basic chat read/message policies are prepared for existing participant rows.

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
2. User A creates a profile, pet, post and walk.
3. User B can read authenticated feed data.
4. User B cannot update or delete User A profile, pet, post or walk.
5. User B can create only their own like/comment rows.
6. User B cannot join a walk as User A.
7. User B cannot upload into a Storage path that starts with User A id.
8. Chat messages are visible only to participants.
