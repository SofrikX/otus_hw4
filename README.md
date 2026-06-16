# PetConnect

PetConnect - Flutter-приложение для владельцев домашних животных. Пользователь может вести социальную ленту питомца, смотреть профили питомцев, присоединяться к прогулкам и работать с базовым чат-сценарием.

ДЗ 5 переводит frontend MVP к backend-интеграции на Firebase: Auth, Cloud Firestore, Firebase Storage, Cloud Functions, Security Rules и Firebase Emulator Suite. Production deploy Cloud Functions в рамках этой проверки не подтвержден как выполненный; для сдачи подготовлены инструкции и полностью проверяемый локальный emulator-сценарий.

## Стек

| Часть | Технология |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| State management | Riverpod / flutter_riverpod |
| Routing | go_router |
| UI | Material 3 |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| File storage | Firebase Storage |
| Backend API | Cloud Functions |
| Local backend | Firebase Emulator Suite |
| Frontend tests | flutter_test, mocktail |
| Backend tests | Node.js test runner через `npm test` |

Оригинальное задание допускает Supabase или self-hosted PostgreSQL. В PetConnect используется Firebase, потому что этот backend уже выбран в технической спецификации проекта.

## Почему нет `package.json` в корне

Корневой `package.json` не нужен, потому что frontend написан на Flutter и управляет зависимостями через `pubspec.yaml`.

Node.js используется только для Cloud Functions backend. Поэтому `package.json` находится внутри `functions/`:

```text
functions/package.json
```

Основные команды для Node.js backend запускаются с `--prefix functions`, например:

```bash
npm install --prefix functions
npm test --prefix functions
```

## Основные функции

- Email/password вход, регистрация и выход через Firebase Auth.
- Защищенный routing через `go_router` и Riverpod auth state.
- Лента постов питомцев с созданием поста, лайками, комментариями и async states.
- Профили питомцев и экран неизвестного питомца с error-state.
- Прогулки с присоединением и обновлением счетчика участников.
- Базовый экран чатов как задел под сообщения.
- Repository layer: UI работает через controllers/providers, а не напрямую с Firebase.
- Local fallback на mock repositories, если `USE_FIREBASE_BACKEND=false`.

## Backend Architecture

Backend реализован на Firebase и Cloud Functions HTTP API.

```text
Flutter UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Firebase/API or mock repositories
  -> Cloud Functions HTTP API
  -> Firebase Admin SDK
  -> Cloud Firestore / Firebase Storage / Firebase Auth
```

Ключевые backend-файлы:

```text
firebase.json                 # Firebase services и emulator ports
firestore.rules               # Cloud Firestore Security Rules
firestore.indexes.json        # Firestore composite indexes
storage.rules                 # Firebase Storage Security Rules
functions/src/app.ts          # Express API app
functions/src/index.ts        # Cloud Functions export
functions/src/routes/         # pets, posts, walks routes
functions/src/repositories/   # Firestore access through Admin SDK
scripts/seed_firestore.js     # local emulator seed data
```

Firestore хранит:

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

Firebase Storage хранит изображения по защищенным путям:

```text
users/{userId}/{fileName}
pets/{userId}/{petId}/{fileName}
posts/{userId}/{postId}/{fileName}
```

Security Rules ограничивают клиентский доступ по Firebase Auth `uid`, owner/author rules, участникам чатов, MIME type `image/*` и размеру файла. Операции со счетчиками и защищенными writes выполняются через Cloud Functions.

Подробнее:

- `backend_documentation.md`
- `docs/api_spec.md`
- `docs/deployment.md`
- `docs/firebase_security.md`
- `docs/firestore_schema.md`
- `docs/seed_data.md`

## Локальный запуск

### 1. Установить Flutter-зависимости

```bash
flutter pub get
```

Если Flutter platform files отсутствуют, создайте их:

```bash
flutter create . --platforms=web,android,ios
```

### 2. Установить Cloud Functions dependencies

```bash
npm install --prefix functions
```

### 3. Запустить Firebase Emulator Suite

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

### 4. Загрузить seed data

В отдельном терминале из корня проекта:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

Seed script создает пользователей, питомцев, посты, комментарии, лайки, прогулки, чат и сообщения. Скрипт не запускается без `FIRESTORE_EMULATOR_HOST`, чтобы не записать данные в production.

Подробнее: `docs/seed_data.md`.

### 5. Запустить Flutter Web с локальным backend

```bash
flutter run -d chrome \
  --dart-define=USE_FIREBASE_AUTH_EMULATOR=true \
  --dart-define=USE_FIREBASE_BACKEND=true \
  --dart-define=FIREBASE_PROJECT_ID=demo-petconnect \
  --dart-define=API_BASE_URL=http://127.0.0.1:5001/demo-petconnect/us-central1/api
```

Fallback без backend:

```bash
flutter run -d chrome \
  --dart-define=USE_FIREBASE_BACKEND=false
```

Fallback для desktop-проверки на macOS:

```bash
flutter run -d macos
```

## End-to-End проверка

1. Запустите `firebase emulators:start --project demo-petconnect`.
2. В другом терминале выполните seed:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

3. Запустите Flutter Web с `USE_FIREBASE_AUTH_EMULATOR=true` и `USE_FIREBASE_BACKEND=true`.
4. В приложении зарегистрируйте или войдите через email/password.
5. Проверьте, что:
   - лента загружает посты из backend;
   - создание поста отправляет данные на backend;
   - прогулки загружаются из backend;
   - protected operations требуют авторизованного пользователя;
   - при выключенном backend flag приложение может работать на mock repositories.
6. Откройте Emulator UI и проверьте записи в Firestore:

```text
http://127.0.0.1:4000
```

### API smoke-check

```bash
API_BASE_URL="http://127.0.0.1:5001/demo-petconnect/us-central1/api"

curl -X GET "${API_BASE_URL}/health" -H "Accept: application/json"
curl -X GET "${API_BASE_URL}/posts?limit=20" -H "Accept: application/json"
curl -X GET "${API_BASE_URL}/walks?limit=20" -H "Accept: application/json"
curl -X GET "${API_BASE_URL}/pets?ownerId=user-anya" -H "Accept: application/json"
```

Protected endpoints require Firebase ID token:

```bash
FIREBASE_ID_TOKEN="<firebase-id-token>"

curl -X POST "${API_BASE_URL}/posts/post-1/like" \
  -H "Authorization: Bearer ${FIREBASE_ID_TOKEN}" \
  -H "Accept: application/json"
```

## Запуск тестов

Flutter checks:

```bash
flutter analyze
flutter test
```

Cloud Functions checks:

```bash
npm test --prefix functions
```

Полезные backend-команды:

```bash
npm run build --prefix functions
npm run lint --prefix functions
firebase emulators:exec --project demo-petconnect "npm test --prefix functions"
```

Перед сдачей рекомендуется выполнить полный набор:

```bash
flutter pub get
flutter analyze
flutter test
npm install --prefix functions
npm test --prefix functions
firebase emulators:exec --project demo-petconnect "npm test --prefix functions"
```

## Production Deploy

Production deploy не выполнялся в рамках локальной проверки. Подготовлены инструкции для безопасного deploy после ручной проверки Firebase project, billing requirements и секретов.

1. Установить и авторизовать Firebase CLI:

```bash
npm install -g firebase-tools
firebase login
firebase projects:list
```

2. Создать локальный `.firebaserc` из шаблона и указать реальный project id:

```bash
cp .firebaserc.example .firebaserc
firebase use
```

3. Проверить backend локально:

```bash
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
```

4. Deploy rules, indexes и storage rules:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

5. Deploy Cloud Functions:

```bash
firebase deploy --only functions
```

6. Полный deploy Firebase backend:

```bash
firebase deploy
```

Cloud Functions production deploy может потребовать Firebase Blaze plan. Для ДЗ основной проверяемый сценарий остается локальным через Firebase Emulator Suite.

## API Endpoints Summary

Local emulator base URL:

```text
http://127.0.0.1:5001/demo-petconnect/us-central1/api
```

| Method | Endpoint | Auth | Назначение |
|---|---|---|---|
| GET | `/health` | No | Проверка доступности API |
| GET | `/pets?ownerId={uid}` | No | Получить питомцев владельца |
| GET | `/pets/:petId` | No | Получить профиль питомца |
| POST | `/pets` | Yes | Создать профиль питомца |
| GET | `/posts?limit=20` | No | Получить ленту постов |
| POST | `/posts` | Yes | Создать пост |
| POST | `/posts/:postId/like` | Yes | Поставить или снять лайк |
| GET | `/walks?limit=20` | No | Получить прогулки |
| POST | `/walks/:walkId/join` | Yes | Присоединиться к прогулке |

Error response shape:

```json
{
  "error": {
    "code": "validation-error",
    "message": "Human readable error message."
  }
}
```

Типовые коды: `validation-error`, `unauthorized`, `forbidden`, `not-found`, `internal-error`.

Полная спецификация: `docs/api_spec.md`. Curl-примеры: `docs/api_examples.md`.

## Troubleshooting

### Chrome не отображается в `flutter devices`

Проверьте, что Google Chrome установлен и доступен Flutter:

```bash
flutter devices
flutter doctor
```

Если platform files отсутствуют:

```bash
flutter create . --platforms=web,android,ios
```

Для локальной проверки можно временно использовать macOS target:

```bash
flutter run -d macos
```

### Firebase emulator не запущен

Признаки: API requests падают с connection refused, Flutter backend screen показывает ошибку загрузки, `curl` не отвечает.

Запустите emulators:

```bash
firebase emulators:start --project demo-petconnect
```

Проверьте health endpoint:

```bash
curl http://127.0.0.1:5001/demo-petconnect/us-central1/api/health
```

### `401 Unauthorized`

Protected endpoint вызван без Firebase ID token или с недействительным token.

Решение:

- войдите в приложение через Firebase Auth Emulator;
- передайте header `Authorization: Bearer <firebase-id-token>`;
- проверьте, что Flutter запущен с `USE_FIREBASE_AUTH_EMULATOR=true`;
- проверьте, что frontend и Functions используют один project id, например `demo-petconnect`.

### `permission-denied`

Обычно означает, что Firestore или Storage Security Rules отклонили client SDK request.

Проверьте:

- пользователь авторизован;
- `request.auth.uid` совпадает с owner/author id;
- операция не пытается напрямую менять защищенные counters;
- путь Storage соответствует `users/`, `pets/` или `posts/`;
- файл для Storage имеет MIME type `image/*` и размер меньше 10 MB.

Для операций с counters используйте Cloud Functions API, а не прямую запись из клиента.

### `no git remote configured`

Если при push или публикации репозитория Git сообщает, что remote не настроен, добавьте GitHub remote:

```bash
git remote -v
git remote add origin <github-repository-url>
git push -u origin main
```

Если основная ветка называется иначе, используйте ее имя вместо `main`:

```bash
git branch --show-current
```

## AI-Assisted Development

Проект разрабатывался с использованием OpenAI Codex как AI coding agent.

Ключевые артефакты:

- `AGENTS.md` - основные правила для Codex в репозитории;
- `docs/ai_agent_rules.md` - расширенные правила Flutter/Firebase разработки;
- `prompts.md` - журнал промптов и результатов;
- `development_report.md` - отчет о разработке и backend-интеграции;
- `backend_documentation.md` - итоговое описание backend architecture, security model, API и validation.

Codex использовался для анализа ТЗ, адаптации Supabase/PostgreSQL requirements на Firebase, проектирования Firestore schema, Cloud Functions API, Security Rules, frontend-backend integration, тестов и документации.
