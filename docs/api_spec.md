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

Flutter-клиент должен использовать `SUPABASE_PUBLISHABLE_KEY` как Supabase Publishable Key и пользовательскую Supabase Auth session. Supabase secret key и service role key запрещены в клиенте.

## Auth

Email/password auth выполняется через Supabase Auth:

- sign up;
- sign in;
- sign out;
- session restore.

После входа RLS policies используют `auth.uid()`.

## Operations

### Feed data flow

Flutter UI не обращается к Supabase напрямую. Поток данных:

```text
FeedScreen/PostCard
  -> FeedController
  -> FeedRepository
  -> SupabaseFeedRepository when USE_SUPABASE_BACKEND=true
  -> MockFeedRepository when USE_SUPABASE_BACKEND=false
```

`SupabaseFeedRepository` использует таблицы:

| Operation | Tables | Notes |
|---|---|---|
| `fetchPosts()` | `posts`, `post_likes`, `comments` | Загружает public feed, user likes и последние тексты комментариев |
| `createPost()` | `posts` | Создает post от текущего `auth.uid()` |
| `toggleLike()` | `post_likes`, `posts` | Insert/delete like row, затем перечитывает post counters |
| `addComment()` | `comments`, `posts` | Создает comment от текущего `auth.uid()`, затем перечитывает post counters |
| `fetchPets()` | `pets` | Загружает список профилей питомцев для экрана pets в backend mode |
| `getPetById()` | `pets` | Загружает профиль питомца по id для экрана `/pets/:petId` |
| `getPetsByOwner()` | `pets` | Загружает питомцев выбранного владельца |
| `createPet()` | `pets` | Создает профиль питомца текущего `auth.uid()` |
| `fetchWalks()` | `walks`, `walk_participants` | Загружает активные прогулки и участие текущего пользователя |
| `createWalk()` | `walks` | Создает прогулку от текущего `auth.uid()` |
| `joinWalk()` | `walk_participants`, `walks` | Добавляет current user в участники, затем перечитывает счетчик |
| `leaveWalk()` | `walk_participants`, `walks` | Удаляет current user из участников, затем перечитывает счетчик |

PostgREST/Supabase exceptions мапятся в typed `ApiException`, чтобы UI показывал error state, а не пустой список.

### Feed: get posts

Supabase client:

```dart
await supabase
    .from('posts')
    .select('''
      id,
      pet_id,
      pet_name,
      author_name,
      pet_emoji,
      image_emoji,
      text,
      created_at,
      likes_count,
      comments_count
    ''')
    .eq('visibility', 'public')
    .isFilter('deleted_at', null)
    .order('created_at', ascending: false)
    .limit(20);
```

Дополнительно для отображения текущего состояния пользователя:

```dart
await supabase
    .from('post_likes')
    .select('post_id')
    .eq('user_id', userId)
    .inFilter('post_id', postIds);

await supabase
    .from('comments')
    .select('post_id,text,created_at')
    .inFilter('post_id', postIds)
    .isFilter('deleted_at', null)
    .order('created_at', ascending: true);
```

REST shape:

```http
GET /rest/v1/posts?visibility=eq.public&deleted_at=is.null&order=created_at.desc&limit=20
apikey: <SUPABASE_PUBLISHABLE_KEY>
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
  'author_name': authorName,
  'pet_id': petId,
  'pet_name': petName,
  'pet_emoji': petEmoji,
  'text': text,
  'image_urls': imageUrls,
  'image_emoji': imageEmoji,
}).select().single();
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
Flutter перечитывает строку `posts` после insert/delete, чтобы показать актуальный `likes_count`.

### Comments: create comment

```dart
await supabase.from('comments').insert({
  'post_id': postId,
  'author_id': userId,
  'author_name': authorName,
  'text': text,
}).select('text').single();
```

The database trigger updates `posts.comments_count`.
Flutter перечитывает строку `posts` после insert, чтобы показать актуальный `comments_count`.

### Pets: get owner pets

Pet data flow:

```text
PetProfileScreen/PetsScreen
  -> petByIdProvider / petsProvider
  -> PetRepository
  -> SupabasePetRepository when USE_SUPABASE_BACKEND=true
  -> MockPetRepository when USE_SUPABASE_BACKEND=false
```

Pet profile by id:

```dart
await supabase
    .from('pets')
    .select('''
      id,
      owner_id,
      owner_name,
      name,
      animal_type,
      breed,
      age,
      description,
      photo_emoji,
      created_at
    ''')
    .eq('id', petId)
    .maybeSingle();
```

REST shape:

```http
GET /rest/v1/pets?id=eq.<pet-id>&select=id,owner_id,owner_name,name,animal_type,breed,age,description,photo_emoji,created_at
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <user-access-token>
```

All pets list:

```dart
await supabase
    .from('pets')
    .select()
    .order('created_at', ascending: false)
    .limit(50);
```

Owner pets:

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
  'owner_name': ownerName,
  'name': name,
  'animal_type': animalType,
  'breed': breed,
  'age': age,
  'description': description,
  'photo_emoji': photoEmoji,
}).select().single();
```

RLS requires `owner_id = auth.uid()`. A denied write is mapped to `ApiForbiddenException`, so the UI shows a permission error instead of silently falling back to mock data.

### Walks: get active walks

Walks data flow:

```text
WalksScreen/WalkCard
  -> WalksController
  -> WalksRepository
  -> SupabaseWalkRepository when USE_SUPABASE_BACKEND=true
  -> MockWalksRepository when USE_SUPABASE_BACKEND=false
```

```dart
await supabase
    .from('walks')
    .select('''
      id,
      organizer_name,
      title,
      place,
      scheduled_at,
      description,
      participants_count
    ''')
    .eq('status', 'active')
    .order('scheduled_at', ascending: true)
    .limit(20);
```

Дополнительно для состояния кнопки join:

```dart
await supabase
    .from('walk_participants')
    .select('walk_id')
    .eq('user_id', userId)
    .inFilter('walk_id', walkIds);
```

REST shape:

```http
GET /rest/v1/walks?status=eq.active&order=scheduled_at.asc&limit=20
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <user-access-token>
```

### Walks: create walk

```dart
await supabase.from('walks').insert({
  'creator_id': userId,
  'organizer_name': organizerName,
  'title': title,
  'place': place,
  'scheduled_at': startsAt.toIso8601String(),
  'description': description,
}).select().single();
```

RLS requires `creator_id = auth.uid()`.

### Walks: join walk

```dart
await supabase.from('walk_participants').insert({
  'walk_id': walkId,
  'user_id': userId,
});
```

RLS requires `user_id = auth.uid()`. The database trigger updates `walks.participants_count`.
Flutter перечитывает строку `walks` после insert, чтобы показать актуальный `participants_count`.

If PostgreSQL returns unique constraint code `23505` for `(walk_id, user_id)`, `SupabaseWalkRepository` does not expose a crash to UI. It returns a `WalkJoinResult` with `alreadyJoined=true`, and `WalksScreen` shows a friendly "Вы уже участвуете" snackbar.

### Walks: leave walk

```dart
await supabase
    .from('walk_participants')
    .delete()
    .eq('walk_id', walkId)
    .eq('user_id', userId);
```

The database trigger updates `walks.participants_count`; Flutter then rereads `walks` for the fresh count.

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
