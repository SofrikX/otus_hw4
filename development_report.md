# development_report.md — отчет о разработке PetConnect HW5

## 1. Цель работы

Цель ДЗ 5 — подготовить PetConnect к интеграции Flutter frontend с backend и описать проверяемый локальный сценарий разработки.

Оригинальное задание предлагает Supabase или self-hosted PostgreSQL. В PetConnect backend адаптируется на Firebase, потому что Firebase уже выбран в техническом задании проекта:

- Firebase Auth;
- Cloud Firestore;
- Firebase Storage;
- Cloud Functions;
- Firebase Security Rules;
- Firebase Emulator Suite.

## 2. Используемый AI-агент

В качестве AI-агента используется **OpenAI Codex**.

Для Codex создан и обновлен файл `AGENTS.md`. Он является основным файлом инструкций агента в этом репозитории. Правила из ДЗ 2 адаптированы под Codex и расширены под HW5:

- `AGENTS.md` — обязательные правила для Flutter + Firebase разработки;
- `docs/ai_agent_rules.md` — расширенные правила кодирования, Firebase-интеграции и тестирования;
- `docs/ai_workflow.md` — workflow проектирования backend, rules, functions и frontend integration.

Корневой `.cursorrules` не используется, потому что проект выполняется через OpenAI Codex.

## 3. Основа проекта

HW5 выполняется на основе Flutter frontend MVP из предыдущего этапа. Уже реализованы:

1. лента публикаций питомцев;
2. профиль питомца;
3. прогулки и присоединение к прогулке;
4. базовый экран чатов;
5. адаптивная Material 3 верстка;
6. автоматические Flutter tests.

Эти функции остаются frontend-основой для backend-интеграции.

## 4. Выбранный стек

| Часть | Технология |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State management | Riverpod |
| Routing | go_router |
| UI | Material 3 |
| Architecture | feature-first + Clean Architecture principles |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| File storage | Firebase Storage |
| Backend API | Cloud Functions |
| Security | Firebase Security Rules |
| Local backend | Firebase Emulator Suite |
| Flutter tests | flutter_test, mocktail |
| Backend tests | npm test для `functions` |

## 5. Firebase mapping из оригинального ДЗ

| Оригинальное задание | PetConnect HW5 |
|---|---|
| Supabase Auth | Firebase Auth |
| Supabase Database / PostgreSQL | Cloud Firestore |
| SQL schema and migrations | Firestore schema, indexes, seed/emulator data |
| Supabase Storage | Firebase Storage |
| Edge Functions / backend API | Cloud Functions |
| Row Level Security | Firebase Security Rules |
| Local Supabase stack | Firebase Emulator Suite |

Supabase упоминается только как технология из исходного текста задания, замененная на Firebase для согласованности с ТЗ PetConnect.

## 6. План backend-интеграции

### Шаг 1. Аудит frontend MVP

Codex проверяет `lib/`, `test/`, `README.md`, `development_report.md`, `prompts.md`, `docs/current_homework_scope.md` и подтверждает, какие mock-слои нужно заменить repository layer.

### Шаг 2. Firestore schema

Планируемые коллекции:

```text
users
pets
posts
posts/{postId}/likes
posts/{postId}/comments
chats
chats/{chatId}/messages
walks
```

Схема должна соответствовать user stories: регистрация, питомцы, посты, лайки, комментарии, сообщения и прогулки.

### Шаг 3. Firebase Storage

Storage используется для:

- аватаров пользователей;
- фото питомцев;
- изображений постов.

Rules должны ограничивать загрузку владельцем, MIME type `image/*` и размер файла.

### Шаг 4. Cloud Functions API

Минимальные backend/API операции:

1. `postsToggleLike` — транзакционно ставит или снимает лайк и обновляет `likesCount`.
2. `commentsCreate` — валидирует комментарий, создает документ и обновляет `commentsCount`.
3. `walksJoin` — проверяет статус прогулки и добавляет пользователя в участники.

Дополнительно возможны `postsCreate`, `messagesSend`, `userProfileCreate`.

### Шаг 5. Security Rules

Firestore и Storage rules должны обеспечить:

- доступ только авторизованным пользователям;
- редактирование своих профилей и питомцев;
- чтение постов авторизованными пользователями;
- доступ к чатам только участникам;
- запрет прямого изменения защищенных counters с клиента;
- безопасную загрузку изображений.

### Шаг 6. Frontend integration

Flutter должен перейти на repository layer:

```text
features/*/
  domain/       # repository interfaces
  data/         # Firebase/mock implementations, DTO/mappers
  application/  # Riverpod providers/controllers
  presentation/ # screens/widgets
```

UI не должен обращаться к Firebase напрямую.

### Шаг 7. Emulator Suite

Основной локальный сценарий:

```bash
firebase emulators:start
firebase emulators:exec "npm test --prefix functions"
```

Production deploy Cloud Functions может потребовать Firebase Blaze plan, поэтому emulator-сценарий обязателен.

### Шаг 8. Тестирование

Сохраняются текущие Flutter tests:

```bash
flutter analyze
flutter test
```

Для backend добавляются проверки:

```bash
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
```

### Шаг 9. Документирование

Codex фиксирует prompts, решения, ошибки и результаты в:

- `prompts.md`;
- `development_report.md`;
- `README.md`;
- `docs/ai_workflow.md`;
- `docs/current_homework_scope.md`.

## 7. Проблемы и риски

| Риск | Решение |
|---|---|
| Оригинальное ДЗ предлагает Supabase/PostgreSQL | Документировать Firebase mapping и использовать стек из ТЗ PetConnect |
| Cloud Functions deploy может требовать Firebase Blaze plan | Сделать Firebase Emulator Suite основным локальным сценарием проверки |
| UI может начать обращаться к Firebase напрямую | Ввести repository interfaces и Riverpod providers |
| Security Rules могут остаться непроверенными | Добавить emulator/rules tests |
| Mock data может смешаться с production data | Оставить mock repositories только для тестов и fallback |
| Секреты могут попасть в репозиторий | Не коммитить service account keys и приватные токены |

## 8. Команды проверки

Flutter:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

Firebase backend, когда files/functions добавлены:

```bash
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
firebase emulators:start
```

## 9. Текущий результат документационного этапа

Документация обновлена под HW5:

- `AGENTS.md` описывает OpenAI Codex, Flutter + Firebase стек и обязательные проверки;
- `docs/api_spec.md` описывает Cloud Functions HTTP API, endpoints, CORS, auth и error model;
- `docs/current_homework_scope.md` содержит 9 шагов ДЗ 5 и Firebase mapping;
- `docs/deployment.md` описывает Firebase CLI, emulator suite, production deploy, Blaze plan warning и правила некоммита секретов;
- `docs/firebase_security.md` объясняет Firestore Security Rules как замену Supabase RLS и фиксирует разрешенные/запрещенные операции;
- `docs/firestore_schema.md` описывает коллекции Firestore, поля, связи, примеры документов, MVP data и индексы;
- `docs/seed_data.md` описывает запуск локальных seed-данных для Firestore Emulator;
- `docs/ai_workflow.md` описывает Firestore schema, Security Rules, Cloud Functions API, frontend integration и AI-анализ логов;
- `docs/documents_index.md` маршрутизирует документы как HW5-материалы;
- `docs/ai_agent_rules.md` больше не запрещает Firebase, а задает правила безопасной интеграции;
- `README.md` больше не выглядит как HW4-only и описывает Firebase Emulator Suite.

## 10. Firebase Auth frontend integration

Codex добавил базовую интеграцию Firebase Auth во Flutter frontend:

- добавлены зависимости `firebase_core` и `firebase_auth`;
- добавлен Firebase bootstrap с поддержкой Auth Emulator через `--dart-define=USE_FIREBASE_AUTH_EMULATOR=true`;
- создан `AppUser` как доменная модель текущего пользователя;
- создан `AuthRepository` и `FirebaseAuthRepository` для login, registration, logout и stream auth state;
- создан `AuthController` на Riverpod `StateNotifier<AsyncValue<void>>`;
- добавлены экраны `/login` и `/register` с loading/error/success состояниями;
- `go_router` получил redirect: неавторизованные пользователи попадают на `/login`, авторизованные не остаются на auth-экранах;
- mock-экраны feed/pets/walks/chat сохранены и остаются доступными после входа;
- в Home добавлен logout.

Секреты Firebase не добавлялись. Для локального emulator-сценария используются demo options и project id `demo-petconnect`.

Проверка:

```bash
dart format .
flutter analyze
flutter test
```

Результат: analyzer без замечаний, Flutter tests прошли.

## 11. Cloud Functions HTTP API client

Codex добавил frontend API client для постепенного перехода feed/walks с mock-данных на Cloud Functions HTTP API:

- выбран `package:http`: для endpoints `GET /posts`, `POST /posts`, `POST /posts/:postId/like`, `GET /walks`, `POST /walks/:walkId/join` достаточно легкого клиента без interceptor-слоя `dio`, а `MockClient` удобно использовать в unit tests;
- добавлен `BackendConfig`, который читает `API_BASE_URL` и `USE_FIREBASE_BACKEND` из `--dart-define`;
- добавлен `AuthTokenProvider`, который берет Firebase ID token из `FirebaseAuth.currentUser`;
- добавлен `ApiClient`, который отправляет JSON, добавляет `Authorization: Bearer ...` при наличии токена и преобразует error-envelope backend в typed exceptions;
- добавлены `FeedRepository` и `WalksRepository` с mock/api реализациями;
- `feedControllerProvider` и `walksControllerProvider` выбирают API repositories только при `USE_FIREBASE_BACKEND=true`; по умолчанию остаются mock repositories;
- mock repositories не удалялись и продолжают использоваться существующими UI/tests.

Локальный backend запуск:

```bash
flutter run -d chrome \
  --dart-define=USE_FIREBASE_AUTH_EMULATOR=true \
  --dart-define=USE_FIREBASE_BACKEND=true \
  --dart-define=FIREBASE_PROJECT_ID=demo-petconnect \
  --dart-define=API_BASE_URL=http://127.0.0.1:5001/demo-petconnect/us-central1/api
```

Проверка:

```bash
dart format .
flutter analyze
flutter test
```

Результат: analyzer без замечаний, Flutter tests прошли, включая `test/core/network/api_client_test.dart`.

## 12. Feed screen backend integration

Codex интегрировал экран ленты с repository layer и Cloud Functions HTTP API, сохранив mock fallback:

- `FeedRepository` остается единым domain-контрактом для `fetchPosts`, `createPost` и `toggleLike`;
- `ApiFeedRepository` использует `ApiClient` для `GET /posts`, `POST /posts` и `POST /posts/:postId/like`;
- `MockFeedRepository` сохранен для локального fallback, тестов и режима `USE_FIREBASE_BACKEND=false`;
- `feedRepositoryProvider` выбирает `ApiFeedRepository` только при `USE_FIREBASE_BACKEND=true`, иначе использует mock repository;
- `FeedController.refresh()` теперь проверяет реальную ошибку repository/backend через `AsyncValue.guard`, без искусственного `shouldFail`;
- `FeedScreen` продолжает использовать `AsyncContentView` и покрывает loading, error с retry, empty и success states;
- `AsyncContentView` показывает локализованный `ApiException.userMessage`, чтобы backend errors отображались дружелюбно, без технического `ApiException(...)`;
- `toggleLike` сохраняет optimistic UI update и синхронизирует результат с backend через repository.

Endpoint для комментариев в `docs/api_spec.md` и `functions/src/routes/posts.ts` пока не описан. Поэтому `addComment()` оставлен локальной mock/fallback-операцией на уровне `FeedController`; backend-реализация комментариев зафиксирована как next step после добавления `POST /posts/:postId/comments`.

Проверка:

```bash
dart format lib/core/widgets/async_content_view.dart lib/features/feed/data/api_feed_repository.dart lib/features/feed/application/feed_controller.dart test/features/feed/feed_controller_test.dart test/features/feed/api_feed_repository_test.dart
flutter test test/features/feed
flutter analyze
flutter test
```

Результат:

- `flutter test test/features/feed` — 16 feed-тестов прошли;
- `flutter analyze` — `No issues found!`;
- `flutter test` — 27 тестов прошли.

## 13. Walks screen backend integration

Codex интегрировал экран прогулок с Cloud Functions HTTP API и сохранил mock fallback:

- `WalksRepository` используется как domain-контракт для `fetchWalks` и `joinWalk`;
- `ApiWalksRepository` использует `ApiClient` для `GET /walks` и `POST /walks/:walkId/join`;
- `MockWalksRepository` сохранен для тестов, локальной разработки и режима `USE_FIREBASE_BACKEND=false`;
- `walksRepositoryProvider` выбирает `ApiWalksRepository` только при `USE_FIREBASE_BACKEND=true`, иначе использует mock repository;
- `WalksController.refresh()` загружает прогулки через repository и отдает loading/error/empty/success состояния в `AsyncContentView`;
- `WalksController.joinWalk()` теперь подтверждает участие только после ответа backend/mock repository, обновляет `isJoined` и `participantCount` из `WalkJoinResult`;
- `WalksScreen` показывает snackbar успеха только после успешного join;
- 401, 403, 404 и backend errors остаются typed exceptions из `ApiClient`, а network failure преобразуется в `ApiNetworkException` с дружелюбным сообщением для UI.

Проверка:

```bash
dart format lib/core/network/api_client.dart lib/core/network/api_error.dart lib/features/walks/application/walks_controller.dart lib/features/walks/presentation/screens/walks_screen.dart lib/features/walks/presentation/widgets/walk_card.dart test/core/network/api_client_test.dart test/features/walks
flutter test test/features/walks
flutter test test/core/network/api_client_test.dart
flutter analyze
flutter test
```

Результат фиксируется в выводе Codex по задаче интеграции прогулок.

## 14. Pets backend integration

Codex интегрировал данные питомцев с Cloud Functions HTTP API и сохранил mock fallback:

- добавлен `PetRepository` как domain-контракт для `getPetById` и `getPetsByOwner`;
- добавлены `ApiPetRepository` и `MockPetRepository`;
- `petRepositoryProvider` выбирает `ApiPetRepository` при `USE_FIREBASE_BACKEND=true`, иначе использует mock repository;
- `petByIdProvider` и `petsProvider` переведены на async provider states;
- `PetProfileScreen` теперь показывает loading, backend error с retry, not found и success states;
- `PetsScreen` показывает loading, empty, error и success через общий `AsyncContentView`;
- `ApiClient` расширен методами `GET /pets/:petId` и `GET /pets?ownerId=...`;
- в Cloud Functions добавлены `GET /pets/:petId`, `GET /pets?ownerId=...` и `POST /pets`;
- `POST /pets` валидирует ownerId против Firebase Auth uid и проверяет поля pet profile перед записью в Firestore;
- 404 для профиля питомца преобразуется в `null` на уровне repository, чтобы UI показывал отдельное состояние "Питомец не найден".

Проверка:

```bash
dart format .
flutter test test/features/pets
flutter analyze
flutter test
npm test --prefix functions
```

Результат фиксируется в выводе Codex по задаче интеграции питомцев.

## 15. Cloud Functions API endpoint tests

Codex добавил backend endpoint tests для Express API внутри Cloud Functions:

- `GET /posts` success;
- `POST /posts` unauthorized;
- `POST /posts` validation error;
- `POST /posts/:postId/like` success;
- `GET /walks` success;
- `POST /walks/:walkId/join` unauthorized.

Для тестирования выбран встроенный `node:test`, чтобы не добавлять лишние зависимости. Express app получил небольшую factory-обертку `createApp`, а routers/auth middleware получили dependency injection для fake repositories и fake authenticated user в тестах. Production export `api` продолжает использовать реальные Firebase Admin SDK repositories и Firebase Auth token verification.

Добавлен `docs/api_examples.md` с curl-примерами для `GET /posts`, `POST /posts`, лайка поста, `GET /walks` и присоединения к прогулке. Для protected endpoints указан placeholder `Authorization: Bearer <firebase-id-token>`.

Проверка:

```bash
npm run lint --prefix functions
npm test --prefix functions
```

Результат: `lint` прошел, `npm test --prefix functions` прошел 6/6 endpoint tests. В Codex sandbox обычный запуск был заблокирован на `listen` для локальных test sockets, поэтому тест был повторен с разрешением на локальный запуск команды.

## 16. Финальная backend-документация

Codex подготовил финальный файл `backend_documentation.md` для сдачи ДЗ 5.

Документ собран как единая backend-спецификация для преподавателя и включает:

- цель backend-части PetConnect HW5;
- объяснение выбора Firebase вместо Supabase/PostgreSQL;
- архитектуру Flutter frontend, Cloud Functions API, Firebase Auth, Firestore, Storage и Security Rules;
- Firestore schema и индексы;
- security model на базе Firestore Rules, Storage Rules и backend validation;
- описание API endpoints и curl-примеры;
- локальный запуск через Firebase Emulator Suite и seed data;
- production deploy и предупреждение про Firebase Blaze plan;
- переменные окружения и защиту секретов;
- error model, логирование и тестирование;
- frontend-backend integration через repositories и Riverpod providers;
- AI-assisted development через OpenAI Codex;
- известные ограничения MVP и чек-лист проверки.

Файл опирается на фактическую реализацию в `functions/src/`, `firebase.json`, `firestore.rules`, `storage.rules`, `docs/api_spec.md`, `docs/api_examples.md`, `docs/firestore_schema.md`, `docs/firebase_security.md`, `docs/deployment.md`, `docs/seed_data.md`, `docs/ai_workflow.md`, `prompts.md` и текущий отчет.

Код приложения и backend-логика в рамках этой задачи не менялись.

## 17. Финальный README для сдачи ДЗ 5

Codex выполнил финальный documentation/QA pass для `README.md`.

README обновлен как основной входной документ для проверяющего и теперь покрывает:

- название и краткое описание PetConnect;
- стек Flutter, Dart, Riverpod, go_router, Material 3 и Firebase services;
- объяснение, почему в корне нет `package.json`, а Node.js `package.json` находится в `functions/`;
- основные функции frontend MVP и backend-интеграции;
- backend architecture, Firestore collections, Storage paths и security model;
- локальный запуск frontend, backend, emulators и seed data;
- end-to-end сценарий проверки через Firebase Emulator Suite;
- запуск Flutter и Cloud Functions tests;
- production deploy instructions с явной оговоркой, что deploy не подтвержден как выполненный;
- API endpoints summary;
- troubleshooting для Chrome, Firebase emulator, `401 Unauthorized`, `permission-denied` и отсутствующего Git remote;
- AI-assisted development через OpenAI Codex, `AGENTS.md`, `prompts.md`, `development_report.md` и `backend_documentation.md`.

Код приложения, Cloud Functions и Firebase rules в рамках этой README-задачи не менялись.

## 18. Error handling, logging и AI-анализ ошибок

Codex выполнил отдельный QA-pass по обработке ошибок frontend/backend.

Что усилено:

- backend `HttpError` остался единым источником error envelope, но получил `details` для validation diagnostics и `requestId` для связи UI-ошибки с Firebase Functions logs;
- `errorHandler` централизованно возвращает `400 validation-error`, `401 unauthorized`, `403 forbidden`, `404 not-found` и `500 internal-error`;
- malformed JSON теперь обрабатывается как `400 validation-error`, а не как неожиданный `500`;
- Cloud Functions logger пишет структурированные записи для 400/401/403/404/500 с `method`, `path`, `statusCode`, `code`, `requestId` и validation details;
- Flutter `ApiClient` сохраняет typed exceptions, raw backend message, validation details и `requestId`;
- UI через `AsyncContentView` показывает короткие русские `userMessage`, сохраняя retry actions и loading/error/empty/success states.

Пример Firebase Functions log для AI-assisted debugging:

```json
{
  "severity": "WARNING",
  "message": "API 400 request error",
  "code": "validation-error",
  "statusCode": 400,
  "method": "POST",
  "path": "/posts",
  "requestId": "1718520000000-abcd1234",
  "details": [
    {
      "field": "petId",
      "message": "Required string."
    }
  ]
}
```

Как использовался AI-анализ:

1. Codex сопоставил требования ДЗ с фактическими `functions/src/`, `lib/core/network/`, `feed`, `walks`, `pets` и документацией.
2. По паттернам ошибок определены gaps: одинаковый `warn` для всех `HttpError`, отсутствие validation details/request correlation, показ raw backend messages пользователю, отсутствие теста malformed JSON и `500` envelope.
3. После правок Codex проверил логику через backend endpoint tests и Flutter tests для API client / error-state UI.

Проверка:

```bash
dart format .
flutter analyze
flutter test
npm test --prefix functions
```

Результаты проверки фиксируются в выводе Codex по этой задаче.

## 19. End-to-end QA и release review HW5

Дата проверки: 17 июня 2026, локально через Firebase Emulator Suite.

Codex выполнил end-to-end проверку PetConnect HW5 в роли QA Engineer и Release Reviewer.

Прочитаны:

- `README.md`;
- `backend_documentation.md`;
- `docs/deployment.md`;
- `docs/api_spec.md`;
- `docs/seed_data.md`;
- `development_report.md`;
- `prompts.md`;
- `firebase.json`;
- `functions/package.json`;
- `pubspec.yaml`;
- проектные правила `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`.

Команды проверки и результаты:

```bash
flutter pub get
```

Результат: прошел после разрешения на запись во Flutter SDK cache вне workspace sandbox. Зависимости получены, есть только advisory о более новых несовместимых версиях пакетов.

```bash
npm install
```

Запускался из `functions/`. Результат: успешно, `up to date`. Предупреждение: `functions/package.json` требует Node 20, локально использовался Node v26.3.0.

```bash
flutter analyze
flutter test
npm run build
npm test
```

Результат: `flutter analyze` без замечаний, `flutter test` прошел 48/48, `npm run build` прошел, `npm test` прошел 9/9. Первый sandbox-запуск backend tests упал с `listen EPERM` на Unix sockets; повтор вне sandbox прошел успешно.

```bash
firebase emulators:start --project demo-petconnect
```

Результат: Auth, Firestore, Functions, Storage и Emulator UI поднялись на портах из `firebase.json`: `9099`, `8080`, `5001`, `9199`, `4000`. Предупреждения: Firebase CLI не авторизован, `firebase-functions` устарел, локальный Node 26 не совпадает с требуемым Node 20.

```bash
FIREBASE_PROJECT_ID=demo-petconnect FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

Результат: seed успешно загрузил 2 users, 3 pets, 4 posts, 4 comments, 3 walks, 1 chat, 2 messages. Первый sandbox-запуск завис после metadata lookup warning; повтор вне sandbox прошел успешно.

```bash
flutter run -d chrome \
  --dart-define=USE_FIREBASE_AUTH_EMULATOR=true \
  --dart-define=USE_FIREBASE_BACKEND=true \
  --dart-define=FIREBASE_PROJECT_ID=demo-petconnect \
  --dart-define=API_BASE_URL=http://127.0.0.1:5001/demo-petconnect/us-central1/api
```

Результат: Flutter Web запустился в Chrome, подключился к Auth Emulator, показал ожидаемое emulator warning. Для браузерной manual-проверки дополнительно использован `flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8081` с теми же `dart-define`, потому что порт `8081` включен в CORS whitelist backend.

API smoke-check:

- `GET /health` вернул `200 {"status":"ok"}`;
- `GET /posts?limit=2` вернул seed/posts data;
- `GET /walks?limit=2` вернул seed/walks data;
- `GET /pets?ownerId=user-anya` вернул питомцев владельца;
- `POST /posts/post-bruno-park/like` без token вернул ожидаемый `401 unauthorized`;
- через Auth Emulator создан QA-пользователь, выполнены `POST /posts`, `POST /posts/:postId/like`, `POST /walks/:walkId/join`; все protected операции прошли с real Firebase ID token.

Manual scenarios:

1. Регистрация пользователя: пройдена через UI и Auth Emulator.
2. Вход пользователя: проверен через UI; один повторный login после hot restart дал дружелюбную ошибку окружения, свежая регистрация в чистой сессии прошла.
3. Загрузка ленты с backend: пройдена, лента показала seed/API posts.
4. Создание поста: найден дефект UI, исправлен, повторная проверка прошла; новый пост появился в ленте и вернулся из `GET /posts?limit=2`.
5. Лайк поста: пройден через UI, `likesCount` обновился до `1` и сохранился на backend.
6. Загрузка прогулок: пройдена, экран прогулок загрузил backend data.
7. Присоединение к прогулке: пройдено через UI, счетчик вырос с 2 до 3, кнопка стала `Вы участвуете`.
8. Обработка 401: проверена через curl без Authorization и backend endpoint tests.
9. Обработка backend error: покрыта backend endpoint test для `500 internal-error` и Flutter tests для typed `ApiServerException`; ручной production-like 500 endpoint не предусмотрен, чтобы не ломать emulator state.
10. Адаптивность mobile/desktop: проверена через browser viewport. Desktop включает `NavigationRail`, mobile включает bottom navigation; критичных overlap в UI не найдено. Снизу виден emulator warning, это служебный overlay локального режима.

Найденная проблема:

- `HomeScreen` показывал snackbar `Создание поста будет подключено к Firebase в следующей версии`, хотя repository/backend уже поддерживали `POST /posts`. Это ломало manual сценарий "Создание поста" как frontend-to-backend отправку данных.

Минимальное исправление:

- `FeedController` получил метод `createPost`, который валидирует текст, формирует `CreatePostInput`, вызывает текущий `FeedRepository` и добавляет созданный пост в начало state.
- `HomeScreen` заменил create-post stub на bottom sheet с текстовым полем и кнопкой публикации. UI по-прежнему обращается только к controller, без прямого backend/API вызова.
- `test/features/feed/feed_controller_test.dart` получил unit test на добавление созданного поста.
- `README.md` уточнен: лента теперь включает создание поста, а E2E checklist проверяет отправку поста на backend.

Remaining risks:

- Production deploy Cloud Functions не выполнялся; основной подтвержденный сценарий - локальный Emulator Suite.
- Локальный Node v26.3.0 отличается от `functions/package.json` engines `node: 20`; перед сдачей/CI желательно запускать Functions на Node 20.
- Firestore/Storage Security Rules не покрыты отдельным rules test suite; текущая проверка опирается на endpoint tests, emulator smoke и ручные сценарии.
- Read-only API endpoints остаются публичными в HTTP middleware MVP; перед production нужно подтвердить публичность или добавить обязательную auth-проверку.
- Endpoint создания комментариев и backend сообщений чата пока не реализованы, комментарии остаются локальным fallback-сценарием.
- Manual backend `500` проверен тестом с fake repository, а не разрушительным сценарием на живом emulator.
