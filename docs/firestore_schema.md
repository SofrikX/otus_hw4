# Firestore Schema — PetConnect HW5

## Назначение документа

Документ описывает структуру Cloud Firestore для PetConnect в рамках HW5 "Backend и интеграция с Frontend".

Схема опирается на:

- `docs/technical_specification.md`;
- `docs/project_description.md`;
- `docs/user_stories.md`;
- текущий Flutter frontend MVP в `lib/features/`;
- Firebase backend stack из `docs/current_homework_scope.md`.

Firestore используется как основная база данных для профилей пользователей, питомцев, ленты, комментариев, прогулок и базовых чатов. Firebase Storage хранит изображения, а Firestore хранит URL и metadata.

## Общие соглашения

- ID документа хранится в имени документа. Поле `id` можно дублировать в документе только если это упрощает Dart DTO и тестовые seed data.
- Все даты хранятся как Firestore `timestamp`.
- Для пользовательских ссылок используется `uid` из Firebase Auth.
- Поля `createdAt`, `updatedAt` заполняются через server timestamp.
- Защищенные счетчики (`likesCount`, `commentsCount`, `participantsCount`) обновляются через Cloud Functions или transaction.
- UI не обращается к Firestore напрямую. Данные проходят через repository layer.

## MVP HW5 Data

Для минимальной интеграции HW5 нужны данные:

1. Авторизованный пользователь в `users/{uid}`.
2. Минимум один питомец пользователя в `pets/{petId}`.
3. Посты ленты в `posts/{postId}`.
4. Комментарии к постам в `posts/{postId}/comments/{commentId}`.
5. Лайк-состояние текущего пользователя для поста. Рекомендуется хранить его в `posts/{postId}/likes/{uid}`.
6. Прогулки в `walks/{walkId}` с участниками.
7. Чаты в `chats/{chatId}` и сообщения в `chats/{chatId}/messages/{messageId}`.

Для первого backend-инкремента можно оставить часть UI на mock repositories, но новые Firebase repositories должны маппить эти коллекции в domain-модели `Pet`, `PetPost`, `Walk`, `ChatThread`.

## Collections Overview

```text
users/{uid}
pets/{petId}
posts/{postId}
posts/{postId}/comments/{commentId}
posts/{postId}/likes/{uid}
walks/{walkId}
chats/{chatId}
chats/{chatId}/messages/{messageId}
```

`posts/{postId}/likes/{uid}` не был отдельно указан в задании, но он нужен для корректной реализации повторного лайка, снятия лайка и проверки `isLiked` для текущего пользователя.

## users

### Назначение

Профиль владельца питомца, связанный с Firebase Auth user.

Path:

```text
users/{uid}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует `uid` для удобства DTO |
| `displayName` | `string` | Да | Имя пользователя в приложении |
| `email` | `string` | Да | Email из Firebase Auth |
| `avatarUrl` | `string?` | Нет | URL аватара из Firebase Storage |
| `bio` | `string?` | Нет | Короткое описание владельца |
| `city` | `string?` | Нет | Город или район для прогулок |
| `createdAt` | `timestamp` | Да | Дата создания профиля |
| `updatedAt` | `timestamp` | Да | Дата последнего обновления |

### Связи

- `users/{uid}` связан с Firebase Auth `uid`.
- `pets.ownerId`, `posts.authorId`, `walks.creatorId`, `messages.senderId` ссылаются на `users/{uid}`.

### Пример документа

```json
{
  "id": "user-1",
  "displayName": "Аня",
  "email": "anya@example.com",
  "avatarUrl": "https://storage.googleapis.com/petconnect/users/user-1/avatar.jpg",
  "bio": "Гуляю с корги и люблю pet-friendly места.",
  "city": "Москва",
  "createdAt": "2026-06-16T09:00:00Z",
  "updatedAt": "2026-06-16T09:00:00Z"
}
```

## pets

### Назначение

Профили питомцев пользователей.

Path:

```text
pets/{petId}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует document id |
| `ownerId` | `string` | Да | UID владельца из `users/{uid}` |
| `ownerName` | `string` | Да | Denormalized имя владельца для карточек |
| `name` | `string` | Да | Имя питомца, до 50 символов |
| `animalType` | `string` | Да | `dog`, `cat`, `other` или локализованное значение |
| `breed` | `string?` | Нет | Порода, до 80 символов |
| `age` | `number?` | Нет | Возраст от 0 до 30 |
| `description` | `string?` | Нет | Описание до 500 символов |
| `photoUrl` | `string?` | Нет | URL фото из Firebase Storage |
| `photoEmoji` | `string?` | Нет | MVP fallback для UI, пока нет реального фото |
| `createdAt` | `timestamp` | Да | Дата создания |
| `updatedAt` | `timestamp` | Да | Дата обновления |

### Связи

- `ownerId` указывает на `users/{uid}`.
- `posts.petId` указывает на `pets/{petId}`.
- В текущем Flutter MVP `Pet` содержит `photoEmoji` и `ownerName`; в Firebase они остаются как fallback/denormalized поля.

### Пример документа

```json
{
  "id": "pet-1",
  "ownerId": "user-1",
  "ownerName": "Аня",
  "name": "Бруно",
  "animalType": "dog",
  "breed": "Корги",
  "age": 3,
  "description": "Обожает мячики, людей и короткие пробежки в парке.",
  "photoUrl": "https://storage.googleapis.com/petconnect/pets/user-1/pet-1.jpg",
  "photoEmoji": "dog",
  "createdAt": "2026-06-16T09:10:00Z",
  "updatedAt": "2026-06-16T09:10:00Z"
}
```

## posts

### Назначение

Публикации в социальной ленте питомцев.

Path:

```text
posts/{postId}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует document id |
| `authorId` | `string` | Да | UID автора из `users/{uid}` |
| `authorName` | `string` | Да | Denormalized имя автора для ленты |
| `petId` | `string` | Да | ID питомца из `pets/{petId}` |
| `petName` | `string` | Да | Denormalized имя питомца для ленты |
| `petPhotoUrl` | `string?` | Нет | Denormalized фото питомца |
| `petEmoji` | `string?` | Нет | MVP fallback для текущего UI |
| `text` | `string?` | Нет | Текст поста, до 1000 символов |
| `imageUrls` | `list<string>` | Да | 1-5 изображений из Firebase Storage |
| `imageEmoji` | `string?` | Нет | MVP fallback для текущего UI |
| `likesCount` | `number` | Да | Количество лайков |
| `commentsCount` | `number` | Да | Количество комментариев |
| `visibility` | `string` | Да | `public`, позже можно добавить `friends` |
| `createdAt` | `timestamp` | Да | Дата публикации |
| `updatedAt` | `timestamp` | Да | Дата обновления |
| `deletedAt` | `timestamp?` | Нет | Soft delete, если пост скрыт |

### Связи

- `authorId` указывает на `users/{uid}`.
- `petId` указывает на `pets/{petId}`.
- Комментарии находятся в `posts/{postId}/comments`.
- Лайки рекомендуется хранить в `posts/{postId}/likes`.
- Domain-модель `PetPost` может получать `isLiked` отдельным запросом к `likes/{currentUid}` или через агрегированный DTO.

### Пример документа

```json
{
  "id": "post-1",
  "authorId": "user-1",
  "authorName": "Аня",
  "petId": "pet-1",
  "petName": "Бруно",
  "petPhotoUrl": "https://storage.googleapis.com/petconnect/pets/user-1/pet-1.jpg",
  "petEmoji": "dog",
  "text": "Сегодня Бруно впервые спокойно прошел мимо самоката. Маленькая победа!",
  "imageUrls": [
    "https://storage.googleapis.com/petconnect/posts/user-1/post-1/photo-1.jpg"
  ],
  "imageEmoji": "park",
  "likesCount": 18,
  "commentsCount": 4,
  "visibility": "public",
  "createdAt": "2026-06-16T09:30:00Z",
  "updatedAt": "2026-06-16T09:30:00Z",
  "deletedAt": null
}
```

## posts/{postId}/comments

### Назначение

Комментарии к публикациям.

Path:

```text
posts/{postId}/comments/{commentId}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует comment id |
| `postId` | `string` | Да | ID родительского поста |
| `authorId` | `string` | Да | UID автора комментария |
| `authorName` | `string` | Да | Denormalized имя автора |
| `authorAvatarUrl` | `string?` | Нет | Avatar URL автора |
| `text` | `string` | Да | Текст комментария, 1-500 символов |
| `createdAt` | `timestamp` | Да | Дата создания |
| `updatedAt` | `timestamp?` | Нет | Дата редактирования |
| `deletedAt` | `timestamp?` | Нет | Soft delete |

### Связи

- Родительский документ: `posts/{postId}`.
- `authorId` указывает на `users/{uid}`.
- `commentsCount` в `posts/{postId}` обновляется через Cloud Function `commentsCreate` или transaction.

### Пример документа

```json
{
  "id": "comment-1",
  "postId": "post-1",
  "authorId": "user-2",
  "authorName": "Максим",
  "authorAvatarUrl": null,
  "text": "Какой молодец!",
  "createdAt": "2026-06-16T09:35:00Z",
  "updatedAt": null,
  "deletedAt": null
}
```

## posts/{postId}/likes

### Назначение

Техническая подколлекция для idempotent like/unlike. Нужна для US-6, чтобы один пользователь не мог лайкнуть один пост несколько раз.

Path:

```text
posts/{postId}/likes/{uid}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `userId` | `string` | Да | UID пользователя, равен document id |
| `postId` | `string` | Да | ID поста |
| `createdAt` | `timestamp` | Да | Дата лайка |

### Связи

- Родительский документ: `posts/{postId}`.
- Document id равен `uid`, поэтому повторный лайк проверяется простым чтением документа.
- `likesCount` в `posts/{postId}` обновляется через Cloud Function `postsToggleLike`.

### Пример документа

```json
{
  "userId": "user-2",
  "postId": "post-1",
  "createdAt": "2026-06-16T09:32:00Z"
}
```

## walks

### Назначение

Прогулки и встречи владельцев питомцев.

Path:

```text
walks/{walkId}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует document id |
| `creatorId` | `string` | Да | UID организатора |
| `organizerName` | `string` | Да | Denormalized имя организатора |
| `title` | `string` | Да | Название прогулки |
| `place` | `string` | Да | Текстовое место встречи |
| `geo` | `geopoint?` | Нет | Координаты для будущего поиска рядом |
| `startsAt` | `timestamp` | Да | Дата и время прогулки |
| `description` | `string?` | Нет | Описание прогулки |
| `participantIds` | `list<string>` | Да | UID участников |
| `participantsCount` | `number` | Да | Количество участников |
| `status` | `string` | Да | `active`, `cancelled`, `finished` |
| `createdAt` | `timestamp` | Да | Дата создания |
| `updatedAt` | `timestamp` | Да | Дата обновления |

### Связи

- `creatorId` указывает на `users/{uid}`.
- `participantIds` содержит UID из `users`.
- Текущая domain-модель `Walk` использует `participantCount` и `isJoined`; Firebase DTO должен вычислять `isJoined` по `participantIds.contains(currentUid)`.

### Пример документа

```json
{
  "id": "walk-1",
  "creatorId": "user-1",
  "organizerName": "Аня",
  "title": "Корги-встреча в парке",
  "place": "Парк Горького, центральный вход",
  "geo": {
    "latitude": 55.7298,
    "longitude": 37.6011
  },
  "startsAt": "2026-06-16T17:00:00Z",
  "description": "Неспешная прогулка, знакомство питомцев и фото на память.",
  "participantIds": ["user-1", "user-2"],
  "participantsCount": 2,
  "status": "active",
  "createdAt": "2026-06-16T10:00:00Z",
  "updatedAt": "2026-06-16T10:00:00Z"
}
```

## chats

### Назначение

Список диалогов пользователя и metadata для сортировки чатов.

Path:

```text
chats/{chatId}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует document id |
| `participantIds` | `list<string>` | Да | UID участников |
| `participantNames` | `map<string, string>` | Да | UID -> displayName |
| `petNames` | `map<string, string>` | Нет | UID -> имя питомца для preview |
| `lastMessageText` | `string?` | Нет | Последнее сообщение для списка чатов |
| `lastMessageSenderId` | `string?` | Нет | UID отправителя последнего сообщения |
| `lastMessageAt` | `timestamp?` | Нет | Дата последнего сообщения |
| `unreadCounts` | `map<string, number>` | Да | UID -> количество непрочитанных |
| `createdAt` | `timestamp` | Да | Дата создания чата |
| `updatedAt` | `timestamp` | Да | Дата обновления |

### Связи

- `participantIds` указывает на `users/{uid}`.
- Сообщения находятся в `chats/{chatId}/messages`.
- Текущая domain-модель `ChatThread` может строиться из `participantNames`, `petNames`, `lastMessageText`, `unreadCounts[currentUid]`, `lastMessageAt`.

### Пример документа

```json
{
  "id": "chat-1",
  "participantIds": ["user-1", "user-2"],
  "participantNames": {
    "user-1": "Аня",
    "user-2": "Максим"
  },
  "petNames": {
    "user-1": "Бруно",
    "user-2": "Мия"
  },
  "lastMessageText": "Пойдем завтра в парк?",
  "lastMessageSenderId": "user-1",
  "lastMessageAt": "2026-06-16T10:20:00Z",
  "unreadCounts": {
    "user-1": 0,
    "user-2": 2
  },
  "createdAt": "2026-06-16T10:00:00Z",
  "updatedAt": "2026-06-16T10:20:00Z"
}
```

## chats/{chatId}/messages

### Назначение

Сообщения внутри конкретного чата.

Path:

```text
chats/{chatId}/messages/{messageId}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|---|---|---|---|
| `id` | `string` | Да | Дублирует message id |
| `chatId` | `string` | Да | ID родительского чата |
| `senderId` | `string` | Да | UID отправителя |
| `senderName` | `string` | Да | Denormalized имя отправителя |
| `text` | `string` | Да | Текст сообщения, не пустой |
| `status` | `string` | Да | `sent`, `failed`, `deleted` |
| `createdAt` | `timestamp` | Да | Дата отправки |
| `updatedAt` | `timestamp?` | Нет | Дата изменения |

### Связи

- Родительский документ: `chats/{chatId}`.
- `senderId` должен входить в `chats/{chatId}.participantIds`.
- `lastMessageText`, `lastMessageSenderId`, `lastMessageAt`, `unreadCounts` в `chats/{chatId}` обновляются через Cloud Function `messagesSend` или transaction.

### Пример документа

```json
{
  "id": "message-1",
  "chatId": "chat-1",
  "senderId": "user-1",
  "senderName": "Аня",
  "text": "Пойдем завтра в парк?",
  "status": "sent",
  "createdAt": "2026-06-16T10:20:00Z",
  "updatedAt": null
}
```

## Indexes

Firestore автоматически индексирует одиночные поля. Для HW5 могут понадобиться composite indexes:

| Query | Collection | Index |
|---|---|---|
| Лента последних публичных постов | `posts` | `visibility ASC`, `createdAt DESC` |
| Посты конкретного питомца | `posts` | `petId ASC`, `createdAt DESC` |
| Посты конкретного автора | `posts` | `authorId ASC`, `createdAt DESC` |
| Питомцы пользователя | `pets` | `ownerId ASC`, `createdAt DESC` |
| Активные прогулки по времени | `walks` | `status ASC`, `startsAt ASC` |
| Прогулки пользователя | `walks` | `participantIds ARRAY_CONTAINS`, `startsAt ASC` |
| Чаты пользователя | `chats` | `participantIds ARRAY_CONTAINS`, `lastMessageAt DESC` |
| Сообщения чата | `chats/{chatId}/messages` | `createdAt ASC` |
| Комментарии поста | `posts/{postId}/comments` | `createdAt ASC` |

Если появится геопоиск прогулок, одного Firestore `geopoint` недостаточно для радиусного поиска. Тогда нужно добавить geohash-поле, например `geoHash`, и использовать отдельную стратегию индексации.

## Security Notes

- `users/{uid}`: пользователь может создавать и обновлять только свой документ.
- `pets/{petId}`: создавать и редактировать может только `ownerId`.
- `posts/{postId}`: создавать может автор, удалять может автор, counters нельзя менять напрямую с клиента.
- `comments`: создавать может авторизованный пользователь, пустой текст запрещен.
- `likes`: document id должен совпадать с `request.auth.uid`.
- `walks`: создавать может авторизованный пользователь, join/leave лучше выполнять через Cloud Function.
- `chats/messages`: читать и писать могут только участники чата.

## AI-assisted database design

Схема Firestore для PetConnect HW5 спроектирована с помощью OpenAI Codex. Codex сопоставил техническое задание, user stories, scope HW5 и текущие Flutter domain-модели, после чего предложил структуру коллекций, поля, связи, примеры документов и индексы для Firebase backend.
