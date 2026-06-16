# Database Schema - PetConnect Supabase

Источник истины для SQL: `supabase/migrations/001_initial_schema.sql`.

Схема заменяет Firestore collections на PostgreSQL tables и покрывает MVP: профили питомцев, ленту публикаций, комментарии, лайки, прогулки, присоединение к прогулке и базовые чаты.

## Tables

| Table | Flutter/domain entity | Purpose |
|---|---|---|
| `profiles` | `AppUser` / owner profile | Профили пользователей, связанные с Supabase Auth |
| `pets` | `Pet` | Питомцы пользователей |
| `posts` | `PetPost` | Публикации в социальной ленте |
| `comments` | `PetPost.comments` | Комментарии к публикациям |
| `post_likes` | `PostLikeResult` | Лайки пользователей к постам |
| `walks` | `Walk` | Прогулки и встречи |
| `walk_participants` | `WalkJoinResult` | Участники прогулок |
| `chats` | `ChatThread` | Метаданные чатов |
| `chat_participants` | `ChatThread` context | Участники чатов и счетчик непрочитанных |
| `messages` | future chat messages | Сообщения в чатах |

## profiles

Связь с Supabase Auth:

```sql
id uuid primary key references auth.users(id) on delete cascade
```

Поля:

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Совпадает с `auth.users.id` |
| `display_name` | `text` | 1-80 символов |
| `email` | `text` | Email профиля |
| `avatar_url` | `text` | Storage/public URL |
| `bio` | `text` | До 500 символов |
| `city` | `text` | До 120 символов |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Обновляется trigger |

Пример:

```json
{
  "id": "11111111-1111-1111-1111-111111111111",
  "display_name": "Anya",
  "email": "anya@example.test",
  "city": "Moscow"
}
```

## pets

Соответствует Flutter `Pet`.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `owner_id` | `uuid` | FK -> `profiles.id` |
| `owner_name` | `text` | Денормализация для карточек |
| `name` | `text` | 1-50 символов |
| `animal_type` | `text` | `dog`, `cat`, `other` |
| `breed` | `text` | До 80 символов |
| `age` | `int` | 0-30 |
| `description` | `text` | До 500 символов |
| `photo_url` | `text` | URL фото |
| `photo_emoji` | `text` | Fallback для текущего UI |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Обновляется trigger |

Flutter mapping:

| Dart | SQL |
|---|---|
| `Pet.id` | `pets.id` |
| `Pet.ownerId` | `pets.owner_id` |
| `Pet.name` | `pets.name` |
| `Pet.animalType` | `pets.animal_type` |
| `Pet.breed` | `pets.breed` |
| `Pet.age` | `pets.age` |
| `Pet.description` | `pets.description` |
| `Pet.photoEmoji` | `pets.photo_emoji` |
| `Pet.ownerName` | `pets.owner_name` |

## posts

Соответствует Flutter `PetPost`.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `author_id` | `uuid` | FK -> `profiles.id` |
| `author_name` | `text` | Денормализация для ленты |
| `pet_id` | `uuid` | FK -> `pets.id` |
| `pet_name` | `text` | Денормализация для ленты |
| `pet_photo_url` | `text` | Фото питомца |
| `pet_emoji` | `text` | Fallback для UI |
| `text` | `text` | До 1000 символов |
| `image_urls` | `text[]` | Изображения поста |
| `image_emoji` | `text` | Fallback для текущего UI |
| `likes_count` | `int` | Пересчитывается trigger |
| `comments_count` | `int` | Пересчитывается trigger |
| `visibility` | `text` | `public`, `private` |
| `created_at` | `timestamptz` | Для сортировки ленты |
| `updated_at` | `timestamptz` | Обновляется trigger |
| `deleted_at` | `timestamptz` | Soft delete |

Flutter mapping:

| Dart | SQL |
|---|---|
| `PetPost.petId` | `posts.pet_id` |
| `PetPost.petName` | `posts.pet_name` |
| `PetPost.authorName` | `posts.author_name` |
| `PetPost.petEmoji` | `posts.pet_emoji` |
| `PetPost.imageEmoji` | `posts.image_emoji` |
| `PetPost.text` | `posts.text` |
| `PetPost.createdAt` | `posts.created_at` |
| `PetPost.likesCount` | `posts.likes_count` |
| `PetPost.commentsCount` | `posts.comments_count` |

## comments

Комментарии к публикациям.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `post_id` | `uuid` | FK -> `posts.id` |
| `author_id` | `uuid` | FK -> `profiles.id` |
| `author_name` | `text` | Денормализация |
| `author_avatar_url` | `text` | Аватар автора |
| `text` | `text` | 1-500 символов |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Обновляется trigger |
| `deleted_at` | `timestamptz` | Soft delete |

`comments_count` в `posts` пересчитывается trigger при insert и soft delete.

## post_likes

Лайки постов. Таблица имеет отдельный `id uuid primary key` и уникальность пары:

```sql
unique (post_id, user_id)
```

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `post_id` | `uuid` | FK -> `posts.id` |
| `user_id` | `uuid` | FK -> `profiles.id` |
| `created_at` | `timestamptz` | Default `now()` |

`likes_count` в `posts` пересчитывается trigger after insert/delete.

## walks

Соответствует Flutter `Walk`.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `creator_id` | `uuid` | FK -> `profiles.id` |
| `organizer_name` | `text` | `Walk.organizerName` |
| `title` | `text` | 1-120 символов |
| `place` | `text` | 1-160 символов |
| `latitude` | `double precision` | Optional |
| `longitude` | `double precision` | Optional |
| `scheduled_at` | `timestamptz` | `Walk.startsAt` |
| `description` | `text` | До 500 символов |
| `participants_count` | `int` | `Walk.participantCount` |
| `status` | `text` | `active`, `cancelled`, `completed` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Обновляется trigger |

## walk_participants

Участники прогулки. Таблица имеет отдельный `id uuid primary key` и уникальность пары:

```sql
unique (walk_id, user_id)
```

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `walk_id` | `uuid` | FK -> `walks.id` |
| `user_id` | `uuid` | FK -> `profiles.id` |
| `created_at` | `timestamptz` | Дата присоединения |

`walks.participants_count` пересчитывается trigger after insert/delete.

## chats

Метаданные чата для списка диалогов.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `last_message_text` | `text` | `ChatThread.lastMessage` |
| `last_message_sender_id` | `uuid` | FK -> `profiles.id` |
| `last_message_at` | `timestamptz` | Сортировка чатов |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Обновляется trigger |

## chat_participants

Участники чата и данные для UI списка диалогов.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `chat_id` | `uuid` | FK -> `chats.id` |
| `user_id` | `uuid` | FK -> `profiles.id` |
| `companion_name` | `text` | `ChatThread.companionName` |
| `pet_name` | `text` | `ChatThread.petName` |
| `unread_count` | `int` | `ChatThread.unreadCount` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Обновляется trigger |

Уникальность:

```sql
unique (chat_id, user_id)
```

## messages

Сообщения внутри чатов.

| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `chat_id` | `uuid` | FK -> `chats.id` |
| `sender_id` | `uuid` | FK -> `profiles.id` |
| `sender_name` | `text` | Денормализация |
| `text` | `text` | 1-1000 символов |
| `status` | `text` | `sending`, `sent`, `failed` |
| `created_at` | `timestamptz` | Для сортировки |
| `updated_at` | `timestamptz` | Обновляется trigger |

## Relations

```text
auth.users 1 -> 1 profiles
profiles 1 -> many pets
profiles 1 -> many posts
pets 1 -> many posts
posts 1 -> many comments
posts 1 -> many post_likes
profiles many -> many posts through post_likes
profiles 1 -> many walks
walks many -> many profiles through walk_participants
chats many -> many profiles through chat_participants
chats 1 -> many messages
profiles 1 -> many messages
```

## Indexes

Required indexes from HW5:

```sql
create index posts_created_at_desc_idx on public.posts (created_at desc);
create index comments_post_id_idx on public.comments (post_id);
create index pets_owner_id_idx on public.pets (owner_id);
create index walks_scheduled_at_idx on public.walks (scheduled_at);
create index messages_chat_id_created_at_idx on public.messages (chat_id, created_at);
```

Additional useful indexes:

- `pets(owner_id, created_at desc)`;
- `posts(visibility, created_at desc)` for public feed;
- `posts(pet_id, created_at desc)`;
- `posts(author_id, created_at desc)`;
- `comments(post_id, created_at asc)`;
- `walks(status, scheduled_at asc)`;
- `walk_participants(user_id)`;
- `post_likes(user_id)`;
- `chat_participants(user_id)`.

## Examples

### Create pet

```json
{
  "owner_id": "11111111-1111-1111-1111-111111111111",
  "owner_name": "Anya",
  "name": "Bruno",
  "animal_type": "dog",
  "breed": "Corgi",
  "age": 3,
  "description": "Loves parks and balls",
  "photo_emoji": "dog"
}
```

### Create post

```json
{
  "author_id": "11111111-1111-1111-1111-111111111111",
  "author_name": "Anya",
  "pet_id": "22222222-2222-2222-2222-222222222222",
  "pet_name": "Bruno",
  "pet_emoji": "dog",
  "text": "Morning walk was great",
  "image_urls": [],
  "image_emoji": "park"
}
```

### Join walk

```json
{
  "walk_id": "33333333-3333-3333-3333-333333333333",
  "user_id": "11111111-1111-1111-1111-111111111111"
}
```

## Notes

- RLS policies are included in the migration because Supabase security must be part of the database design.
- Storage buckets are also created in the migration for `avatars`, `pet-photos`, and `post-images`.
- `supabase/seed.sql` intentionally contains no real users or production data.
