# PetConnect Backend Documentation для ДЗ 5

## 1. Название и цель

PetConnect - Flutter-приложение для владельцев домашних животных. Backend-часть ДЗ 5 реализует проверяемую локальную инфраструктуру для интеграции frontend MVP с Firebase.

Цель документа - описать архитектуру backend, схему данных, модель безопасности, Cloud Functions API, локальный запуск через Firebase Emulator Suite, production deploy, тестирование и процесс разработки с OpenAI Codex.

## 2. Почему Firebase вместо Supabase/PostgreSQL

Оригинальное задание допускает Supabase или self-hosted PostgreSQL. В PetConnect выбран Firebase, потому что Firebase уже зафиксирован в технической спецификации проекта и лучше соответствует текущей архитектуре Flutter MVP.

Соответствие требованиям ДЗ сохраняется через Firebase-эквиваленты:

| Требование исходного ДЗ | Реализация PetConnect |
|---|---|
| Auth | Firebase Auth |
| Database schema | Cloud Firestore collections, indexes, seed data |
| SQL/RLS security | Firebase Security Rules |
| Storage | Firebase Storage |
| Backend API | Cloud Functions HTTPS API |
| Local validation | Firebase Emulator Suite |

Такой выбор не меняет цель ДЗ: backend schema, API operations, security model, local validation и frontend integration остаются обязательными.

## 3. Архитектура

### Flutter frontend

Frontend построен на Flutter, Dart, Riverpod, go_router и Material 3. Структура feature-first сохраняет разделение:

```text
lib/app
lib/core
lib/features/auth
lib/features/feed
lib/features/pets
lib/features/walks
lib/features/chat
lib/features/home
```

UI не обращается к Firebase напрямую. Экраны работают через Riverpod controllers/providers, которые используют repository interfaces. Для локального fallback и тестов сохранены mock repositories.

### Cloud Functions API

Cloud Functions экспортирует HTTPS-функцию:

```text
api
```

Express-приложение находится в `functions/src/app.ts`, маршруты разделены по ресурсам:

```text
functions/src/routes/pets.ts
functions/src/routes/posts.ts
functions/src/routes/walks.ts
```

Репозитории Cloud Functions используют Firebase Admin SDK и Cloud Firestore:

```text
functions/src/repositories/petsRepository.ts
functions/src/repositories/postsRepository.ts
functions/src/repositories/walksRepository.ts
```

### Firebase Auth

Firebase Auth является источником идентичности пользователя. Protected endpoints принимают Firebase ID token в заголовке:

```http
Authorization: Bearer <firebase-id-token>
```

Backend проверяет токен через Firebase Admin SDK и использует `uid` как доверенный идентификатор пользователя.

### Cloud Firestore

Cloud Firestore хранит пользователей, питомцев, посты, комментарии, лайки, прогулки, чаты и сообщения. Защищенные счетчики обновляются через Cloud Functions или транзакции.

### Firebase Storage

Firebase Storage хранит изображения пользователей, питомцев и постов. Firestore хранит URL и metadata изображений.

### Security Rules

Firestore и Storage rules являются частью backend-реализации. Они ограничивают клиентский доступ по `request.auth.uid`, owner/author rules, участникам чатов, MIME type и размеру файлов.

## 4. Firestore schema

Основные коллекции:

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

### users

Профиль владельца питомца, связанный с Firebase Auth `uid`.

Ключевые поля: `id`, `displayName`, `email`, `avatarUrl`, `bio`, `city`, `createdAt`, `updatedAt`.

### pets

Профили питомцев.

Ключевые поля: `id`, `ownerId`, `ownerName`, `name`, `animalType`, `breed`, `age`, `description`, `photoUrl`, `photoEmoji`, `createdAt`, `updatedAt`.

`ownerId` связан с `users/{uid}`. Владелец управляет созданием, обновлением и удалением питомца.

### posts

Публикации в социальной ленте.

Ключевые поля: `id`, `authorId`, `authorName`, `petId`, `petName`, `petPhotoUrl`, `petEmoji`, `text`, `imageUrls`, `imageEmoji`, `likesCount`, `commentsCount`, `visibility`, `createdAt`, `updatedAt`, `deletedAt`.

`likesCount` и `commentsCount` не должны изменяться клиентом напрямую.

### posts/{postId}/comments

Комментарии к публикациям.

Ключевые поля: `id`, `postId`, `authorId`, `authorName`, `authorAvatarUrl`, `text`, `createdAt`, `updatedAt`, `deletedAt`.

Текст комментария должен быть непустым и не длиннее 500 символов.

### posts/{postId}/likes

Техническая подколлекция для idempotent like/unlike.

Document id равен `uid`, поля: `userId`, `postId`, `createdAt`. Это предотвращает повторный лайк одним пользователем.

### walks

Прогулки и встречи владельцев питомцев.

Ключевые поля: `id`, `creatorId`, `organizerName`, `title`, `place`, `geo`, `startsAt`, `description`, `participantIds`, `participantsCount`, `status`, `createdAt`, `updatedAt`.

`participantIds` используется для вычисления `isJoined` во frontend.

### chats

Metadata диалогов.

Ключевые поля: `id`, `participantIds`, `participantNames`, `petNames`, `lastMessageText`, `lastMessageSenderId`, `lastMessageAt`, `unreadCounts`, `createdAt`, `updatedAt`.

### chats/{chatId}/messages

Сообщения внутри чата.

Ключевые поля: `id`, `chatId`, `senderId`, `senderName`, `text`, `status`, `createdAt`, `updatedAt`.

Читать и создавать сообщения могут только участники чата.

### Индексы

В `firestore.indexes.json` подготовлены composite indexes:

| Сценарий | Index |
|---|---|
| Лента публичных постов | `posts: visibility ASC, createdAt DESC` |
| Посты питомца | `posts: petId ASC, createdAt DESC` |
| Посты автора | `posts: authorId ASC, createdAt DESC` |
| Питомцы пользователя | `pets: ownerId ASC, createdAt DESC` |
| Активные прогулки | `walks: status ASC, startsAt ASC` |
| Прогулки пользователя | `walks: participantIds ARRAY_CONTAINS, startsAt ASC` |
| Чаты пользователя | `chats: participantIds ARRAY_CONTAINS, lastMessageAt DESC` |

## 5. Security model

Security model строится на Firebase Auth, Firestore Security Rules, Storage Rules и backend validation в Cloud Functions.

### Firestore Rules

Правила находятся в `firestore.rules`.

Основные helpers:

| Helper | Назначение |
|---|---|
| `signedIn()` | Проверяет наличие `request.auth` |
| `isOwner(ownerId)` | Проверяет совпадение `ownerId` и `request.auth.uid` |
| `isAuthor(authorId)` | Проверяет совпадение `authorId` и `request.auth.uid` |
| `isWalkJoin()` | Разрешает строго ограниченный join-сценарий прогулки |
| `isChatParticipant()` | Проверяет участие пользователя в чате |

Основные правила:

- неавторизованные пользователи не получают доступ к данным приложения через client SDK;
- пользователь создает и обновляет только свой `users/{uid}`;
- питомца может создать, изменить и удалить только владелец;
- пост создает и изменяет только автор;
- клиент не может напрямую менять `likesCount` и `commentsCount`;
- лайк создается и удаляется только для собственного `uid`;
- join прогулки разрешен только для активной прогулки и только с увеличением `participantsCount` на 1;
- чаты и сообщения доступны только участникам.

### Storage Rules

Правила находятся в `storage.rules`.

Разрешенные пути:

```text
users/{userId}/{fileName}
pets/{userId}/{petId}/{fileName}
posts/{userId}/{postId}/{fileName}
```

Ограничения:

- чтение доступно авторизованным пользователям;
- запись доступна только владельцу соответствующего `userId`;
- файл должен иметь MIME type `image/*`;
- размер файла должен быть меньше 10 MB;
- все остальные пути закрыты.

### Cloud Functions validation

Cloud Functions выполняет серверную проверку операций, где важны права доступа, счетчики и транзакционность:

- `POST /posts` проверяет `authorId == uid`;
- `POST /pets` проверяет `ownerId == uid`;
- `POST /posts/:postId/like` транзакционно создает или удаляет лайк и обновляет `likesCount`;
- `POST /walks/:walkId/join` транзакционно добавляет пользователя в `participantIds` и обновляет `participantsCount`.

## 6. API endpoints

Base URL для локального emulator:

```text
http://127.0.0.1:5001/demo-petconnect/us-central1/api
```

Production URL формируется Firebase после deploy Cloud Functions.

### GET /health

Проверка доступности API.

Ответ:

```json
{
  "status": "ok"
}
```

### GET /pets

Возвращает питомцев пользователя.

Query parameters:

| Name | Required | Description |
|---|---|---|
| `ownerId` | Да | Firebase Auth UID владельца |

Auth на уровне HTTP middleware для этого read-only endpoint не требуется в MVP. Перед production-доступом публичность read endpoints должна быть подтверждена отдельно.

### GET /pets/:petId

Возвращает профиль питомца по document id.

Ошибки:

- `400 validation-error`, если `petId` пустой;
- `404 not-found`, если питомец не найден.

### POST /pets

Создает профиль питомца.

Auth: required.

Валидация:

- `ownerId` должен совпадать с Firebase Auth `uid`;
- `ownerName`, `name`, `animalType` обязательны;
- `name` не длиннее 50 символов;
- `breed` не длиннее 80 символов;
- `age` от 0 до 30;
- `description` не длиннее 500 символов.

### GET /posts

Возвращает ленту постов, отсортированную по `createdAt desc`.

Query parameters:

| Name | Required | Description |
|---|---|---|
| `limit` | Нет | Целое число от 1 до 50, по умолчанию 20 |

### POST /posts

Создает пост.

Auth: required.

Валидация:

- `authorId` должен совпадать с Firebase Auth `uid`;
- `petId` обязателен;
- `text` должен быть строкой не длиннее 1000 символов;
- `imageUrls`, если передан, должен быть массивом строк.

### POST /posts/:postId/like

Переключает лайк текущего пользователя.

Auth: required.

Операция выполняется в Firestore transaction:

- если лайка нет, создается `posts/{postId}/likes/{uid}` и `likesCount` увеличивается;
- если лайк уже есть, документ лайка удаляется и `likesCount` уменьшается;
- повторный вызов остается корректным для одного пользователя.

### GET /walks

Возвращает прогулки, отсортированные по `startsAt asc`.

Query parameters:

| Name | Required | Description |
|---|---|---|
| `limit` | Нет | Целое число от 1 до 50, по умолчанию 20 |

### POST /walks/:walkId/join

Добавляет текущего пользователя в прогулку.

Auth: required.

Операция выполняется в Firestore transaction:

- прогулка должна существовать;
- `status` должен быть `active`;
- если пользователь уже участник, операция возвращает текущий joined-state;
- если пользователь еще не участник, `participantIds` и `participantsCount` обновляются вместе.

### Error model

Все ошибки возвращаются в едином формате:

```json
{
  "error": {
    "code": "validation-error",
    "message": "Human readable error message."
  }
}
```

Коды:

| HTTP status | Code | Значение |
|---|---|---|
| 400 | `validation-error` | Некорректный запрос |
| 401 | `unauthorized` | Нет Firebase ID token или token недействителен |
| 403 | `forbidden` | Пользователь не может выполнить операцию |
| 404 | `not-found` | Ресурс не найден |
| 500 | `internal-error` | Неожиданная ошибка backend |

## 7. Примеры запросов

Перед protected запросами нужно получить Firebase ID token авторизованного пользователя и передать его в `Authorization`.

```bash
API_BASE_URL="http://127.0.0.1:5001/demo-petconnect/us-central1/api"
FIREBASE_ID_TOKEN="<firebase-id-token>"
```

### Получить посты

```bash
curl -X GET "${API_BASE_URL}/posts?limit=20" \
  -H "Accept: application/json"
```

### Создать пост

```bash
curl -X POST "${API_BASE_URL}/posts" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "authorId": "user-anya",
    "authorName": "Аня",
    "petId": "pet-bruno",
    "petName": "Бруно",
    "text": "Сегодня Бруно отлично погулял.",
    "imageUrls": [
      "https://storage.googleapis.com/petconnect/posts/user-anya/post-1/photo-1.jpg"
    ]
  }'
```

### Поставить или снять лайк

```bash
curl -X POST "${API_BASE_URL}/posts/post-1/like" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Accept: application/json"
```

### Получить питомца

```bash
curl -X GET "${API_BASE_URL}/pets/pet-bruno" \
  -H "Accept: application/json"
```

### Получить питомцев владельца

```bash
curl -X GET "${API_BASE_URL}/pets?ownerId=user-anya" \
  -H "Accept: application/json"
```

### Создать питомца

```bash
curl -X POST "${API_BASE_URL}/pets" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "ownerId": "user-anya",
    "ownerName": "Аня",
    "name": "Бруно",
    "animalType": "dog",
    "breed": "Корги",
    "age": 3,
    "description": "Обожает мячики и прогулки.",
    "photoEmoji": "dog"
  }'
```

### Получить прогулки

```bash
curl -X GET "${API_BASE_URL}/walks?limit=20" \
  -H "Accept: application/json"
```

### Присоединиться к прогулке

```bash
curl -X POST "${API_BASE_URL}/walks/walk-1/join" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Accept: application/json"
```

### Пример ошибки без token

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Firebase ID token is required."
  }
}
```

## 8. Локальный запуск через Firebase Emulator Suite

### Установить зависимости

Flutter:

```bash
flutter pub get
```

Cloud Functions:

```bash
npm install --prefix functions
```

### Запустить emulators

```bash
firebase emulators:start --project demo-petconnect
```

Порты из `firebase.json`:

| Service | Port |
|---|---:|
| Auth | 9099 |
| Firestore | 8080 |
| Functions | 5001 |
| Storage | 9199 |
| Emulator UI | 4000 |

Emulator UI:

```text
http://127.0.0.1:4000
```

### Наполнить Firestore Emulator seed-данными

В отдельном терминале:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

Seed создает пользователей, питомцев, посты, комментарии, лайки, прогулки, чат и сообщения. Скрипт не запускается без `FIRESTORE_EMULATOR_HOST`, чтобы не записать данные в production.

### Запустить Flutter Web с backend

```bash
flutter run -d chrome \
  --dart-define=USE_FIREBASE_AUTH_EMULATOR=true \
  --dart-define=USE_FIREBASE_BACKEND=true \
  --dart-define=FIREBASE_PROJECT_ID=demo-petconnect \
  --dart-define=API_BASE_URL=http://127.0.0.1:5001/demo-petconnect/us-central1/api
```

Если `USE_FIREBASE_BACKEND=false`, feed, pets и walks используют mock repositories.

## 9. Production deploy

Production deploy выполняется только после локальной проверки Flutter, Functions, Firestore Rules и Storage Rules.

### Подготовить Firebase project

```bash
firebase login
firebase projects:list
cp .firebaserc.example .firebaserc
```

В `.firebaserc` нужно указать реальный Firebase project id.

### Проверить активный project

```bash
firebase use
```

### Deploy rules и indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### Deploy Cloud Functions

```bash
firebase deploy --only functions
```

### Полный deploy Firebase backend

```bash
firebase deploy
```

Cloud Functions production deploy может потребовать Firebase Blaze plan. Для сдачи ДЗ основной проверяемый сценарий работает локально через Firebase Emulator Suite.

## 10. Переменные окружения и защита секретов

В репозитории допустимы только безопасные шаблоны:

```text
.env.example
.firebaserc.example
```

Пример `.env.example`:

```text
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_REGION=us-central1
API_BASE_URL=http://127.0.0.1:5001/your-firebase-project-id/us-central1
USE_FIREBASE_BACKEND=false
```

Для Flutter runtime используются `--dart-define`:

| Переменная | Назначение |
|---|---|
| `USE_FIREBASE_AUTH_EMULATOR` | Подключает Firebase Auth Emulator |
| `USE_FIREBASE_BACKEND` | Включает API repositories вместо mock repositories |
| `FIREBASE_PROJECT_ID` | Project id для Firebase initialization |
| `API_BASE_URL` | Base URL Cloud Functions API |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID` | Production Firebase options при необходимости |

Нельзя коммитить:

- `serviceAccount.json`;
- любые `*-service-account.json`;
- реальные `.env`;
- приватные токены;
- Firebase Admin SDK credentials;
- CI secrets;
- debug logs с token values.

## 11. Обработка ошибок

Backend использует класс `HttpError` и централизованный `errorHandler`.

Обработанные ошибки возвращаются как JSON envelope с `error.code` и `error.message`. Необработанные исключения логируются как `Unhandled API error`, а клиент получает:

```json
{
  "error": {
    "code": "internal-error",
    "message": "Unexpected backend error."
  }
}
```

Frontend `ApiClient` преобразует ответы backend в typed Dart exceptions:

- `ApiValidationException`;
- `ApiUnauthorizedException`;
- `ApiForbiddenException`;
- `ApiNotFoundException`;
- `ApiServerException`;
- `ApiNetworkException`;
- `ApiUnexpectedException`.

UI показывает короткие дружелюбные сообщения через `AsyncContentView` и сохраняет loading, error, empty и success states.

## 12. Логирование

Cloud Functions использует `firebase-functions/logger`.

Логируются:

- входящие API-запросы: method и path;
- успешная аутентификация: uid, method, path;
- операции `GET /posts`, `POST /posts`, `POST /posts/:postId/like`;
- операции `GET /pets`, `GET /pets/:petId`, `POST /pets`;
- операции `GET /walks`, `POST /walks/:walkId/join`;
- успешное создание поста и питомца;
- успешное присоединение к прогулке;
- ошибки проверки Firebase ID token;
- обработанные `HttpError`;
- необработанные backend errors.

В логи не должны попадать Firebase ID tokens, service account keys и приватные значения окружения.

## 13. Тестирование

### Flutter validation

Рекомендуемые команды после изменений Flutter-кода:

```bash
dart format .
flutter analyze
flutter test
```

Тесты покрывают auth controller, API client, feed, pets, walks, chat и repository mapping.

### Functions validation

Команды:

```bash
npm run lint --prefix functions
npm test --prefix functions
```

`npm test --prefix functions` выполняет TypeScript build и запускает `node --test lib/test/*.test.js`.

Текущие backend endpoint tests покрывают:

- `GET /posts` success;
- `POST /posts` unauthorized;
- `POST /posts` validation error;
- `POST /posts/:postId/like` success;
- `GET /walks` success;
- `POST /walks/:walkId/join` unauthorized.

### Emulator validation

Для проверки backend в окружении Firebase Emulator Suite:

```bash
firebase emulators:exec "npm test --prefix functions"
```

Для ручной проверки:

```bash
firebase emulators:start --project demo-petconnect
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

После этого endpoints можно проверять curl-командами из раздела 7 и через Emulator UI.

## 14. Интеграция Frontend-Backend

Интеграция выполнена через repository layer и Riverpod providers.

### Auth

`FirebaseAuthRepository` реализует:

- login по email/password;
- registration по email/password;
- logout;
- stream auth state;
- дружелюбные сообщения Firebase Auth errors.

`go_router` защищает основные маршруты: неавторизованный пользователь направляется на `/login`.

### API client

`ApiClient`:

- читает base URL из `BackendConfig`;
- добавляет `Accept` и `Content-Type`;
- получает Firebase ID token через `AuthTokenProvider`;
- добавляет `Authorization: Bearer ...`, если пользователь авторизован;
- декодирует `data` envelope;
- преобразует error envelope в typed exceptions.

### Feed

`FeedRepository` имеет mock и API implementations. При `USE_FIREBASE_BACKEND=true` используется `ApiFeedRepository`, который вызывает:

- `GET /posts`;
- `POST /posts`;
- `POST /posts/:postId/like`.

Комментарии пока остаются локальной fallback-операцией, потому что endpoint `POST /posts/:postId/comments` не реализован в текущих Functions routes.

### Pets

`PetRepository` имеет mock и API implementations. API-вариант вызывает:

- `GET /pets/:petId`;
- `GET /pets?ownerId=...`;
- `POST /pets` на backend-стороне.

`PetProfileScreen` обрабатывает loading, backend error, not found и success.

### Walks

`WalksRepository` имеет mock и API implementations. API-вариант вызывает:

- `GET /walks`;
- `POST /walks/:walkId/join`.

`WalksController` обновляет UI только после результата repository.

## 15. AI-assisted development

Основной AI-агент проекта - OpenAI Codex.

### Проектирование БД через Codex

Codex сопоставил техническую спецификацию, user stories, текущие Flutter domain-модели и scope HW5. На этой основе была спроектирована Firestore schema: коллекции, поля, связи, индексы, примеры документов, seed data и security notes.

### Генерация API через Codex

Codex спроектировал Cloud Functions HTTP API на Express:

- выделил маршруты `pets`, `posts`, `walks`;
- добавил middleware Firebase Auth verification;
- добавил error envelope;
- реализовал транзакционные операции like и join;
- подготовил endpoint tests через `node:test`;
- добавил curl-примеры для ручной проверки.

### Анализ ошибок через Codex

Codex использовался для анализа:

- Flutter analyzer и widget/unit test failures;
- backend TypeScript build errors;
- API validation errors;
- unauthorized/forbidden/not-found сценариев;
- sandbox-ограничения при запуске локальных test sockets;
- ошибок конфигурации Flutter Web и Firebase emulator workflow.

### Работа с логами

Codex опирался на логи Cloud Functions, Flutter test output, `flutter analyze`, `npm test --prefix functions`, Firebase Emulator Suite и git diff. По результатам анализа фиксировались причина, исправление и команда проверки в `prompts.md` и `development_report.md`.

## 16. Известные ограничения MVP

- Read-only endpoints `GET /posts`, `GET /pets`, `GET /pets/:petId`, `GET /walks` в HTTP middleware текущего MVP не требуют Firebase ID token. Firestore Admin SDK обходит Security Rules, поэтому перед production-доступом нужно утвердить публичность этих endpoints или добавить обязательную auth-проверку.
- Backend endpoint для создания комментариев пока не реализован; комментарии в feed остаются локальным fallback-сценарием.
- Backend endpoint для сообщений чата пока не реализован; Firestore schema и rules готовы для будущей интеграции.
- Production deploy Cloud Functions может потребовать Firebase Blaze plan.
- Полная проверка Firestore/Storage Security Rules через отдельные rules tests остается следующим усилением качества; текущая локальная проверка опирается на emulator workflow, endpoint tests и ручные сценарии.
- Геопоиск прогулок по радиусу не реализован. Для него потребуется geohash-стратегия поверх Firestore.

## 17. Чек-лист проверки

- [ ] Установлены Flutter-зависимости: `flutter pub get`.
- [ ] Установлены Functions-зависимости: `npm install --prefix functions`.
- [ ] Flutter-код отформатирован: `dart format .`.
- [ ] Flutter analyzer проходит: `flutter analyze`.
- [ ] Flutter tests проходят: `flutter test`.
- [ ] Functions TypeScript lint проходит: `npm run lint --prefix functions`.
- [ ] Backend endpoint tests проходят: `npm test --prefix functions`.
- [ ] Firebase Emulator Suite запускается: `firebase emulators:start --project demo-petconnect`.
- [ ] Seed-данные загружаются в Firestore Emulator: `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions`.
- [ ] Flutter Web запускается с Auth Emulator и Cloud Functions API.
- [ ] Protected endpoints проверены с Firebase ID token.
- [ ] Firestore rules и Storage rules присутствуют в репозитории.
- [ ] В репозитории нет service account keys, реальных `.env`, приватных токенов и production credentials.
- [ ] `README.md`, `prompts.md`, `development_report.md` и финальная backend-документация согласованы между собой.
