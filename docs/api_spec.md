# API Spec - PetConnect Supabase

PetConnect использует Supabase auto REST API через PostgREST и Flutter SDK `supabase_flutter`. Отдельный Cloud Functions API больше не является текущим production backend.

Base URL берется из Supabase Project URL:

```text
SUPABASE_URL=https://your-project-ref.supabase.co
```

REST API base path:

```text
${SUPABASE_URL}/rest/v1
```

Flutter-клиент должен использовать `SUPABASE_ANON_KEY` как public client key и пользовательскую Supabase Auth session. Service role key запрещен в клиенте.

## Auth

Email/password auth выполняется через Supabase Auth:

- sign up;
- sign in;
- sign out;
- session restore.

После входа RLS policies используют `auth.uid()`.

## Operations

### Feed: get posts

Supabase client:

```dart
await supabase
    .from('posts')
    .select()
    .eq('visibility', 'public')
    .isFilter('deleted_at', null)
    .order('created_at', ascending: false)
    .limit(20);
```

REST shape:

```http
GET /rest/v1/posts?visibility=eq.public&deleted_at=is.null&order=created_at.desc&limit=20
apikey: <SUPABASE_ANON_KEY>
Authorization: Bearer <user-access-token>
```

### Feed: create post

Required:

- `author_id = auth.uid()`;
- `pet_id`;
- `text` up to 1000 chars;
- optional `image_urls`.

```dart
await supabase.from('posts').insert({
  'author_id': userId,
  'pet_id': petId,
  'text': text,
  'image_urls': imageUrls,
});
```

RLS also verifies that the post belongs to the authenticated user.

### Feed: like/unlike post

Like:

```dart
await supabase.from('post_likes').insert({
  'post_id': postId,
  'user_id': userId,
});
```

Unlike:

```dart
await supabase
    .from('post_likes')
    .delete()
    .eq('post_id', postId)
    .eq('user_id', userId);
```

The database trigger updates `posts.likes_count`.

### Comments: create comment

```dart
await supabase.from('comments').insert({
  'post_id': postId,
  'author_id': userId,
  'text': text,
});
```

The database trigger updates `posts.comments_count`.

### Pets: get owner pets

```dart
await supabase
    .from('pets')
    .select()
    .eq('owner_id', ownerId)
    .order('created_at', ascending: false);
```

### Pets: create pet

```dart
await supabase.from('pets').insert({
  'owner_id': userId,
  'name': name,
  'animal_type': animalType,
  'breed': breed,
  'age': age,
  'description': description,
});
```

RLS requires `owner_id = auth.uid()`.

### Walks: get active walks

```dart
await supabase
    .from('walks')
    .select()
    .eq('status', 'active')
    .order('scheduled_at', ascending: true)
    .limit(20);
```

### Walks: join walk

```dart
await supabase.from('walk_participants').insert({
  'walk_id': walkId,
  'user_id': userId,
});
```

RLS requires `user_id = auth.uid()` and an active walk. The database trigger updates `walks.participants_count`.

### Storage: upload image

Paths must start with the authenticated user id:

```text
avatars/<user-id>/<file-name>
pet-photos/<user-id>/<file-name>
post-images/<user-id>/<file-name>
```

Example:

```dart
await supabase.storage
    .from('post-images')
    .upload('$userId/$fileName', file);
```

## Error Model

Supabase/PostgREST errors should be mapped in repositories to friendly app errors:

| Source | User-facing meaning |
|---|---|
| `401` | Нужно войти в аккаунт |
| `403` or RLS denial | Недостаточно прав для операции |
| Constraint violation | Проверьте заполненные поля |
| Network failure | Проверьте интернет и повторите |
| Unexpected error | Что-то пошло не так, попробуйте снова |

UI should keep loading, error, empty and success states through Riverpod controllers.
