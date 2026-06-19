# development_report.md — отчет о разработке PetConnect HW5

## 1. Цель работы

Цель ДЗ 5 — подготовить PetConnect к интеграции Flutter frontend с backend и описать проверяемый сценарий backend deployment.

Оригинальное задание предлагает Supabase или self-hosted PostgreSQL. В ранней технической спецификации PetConnect был указан Firebase, поэтому первая backend-ветка была спроектирована вокруг Firebase Auth, Firestore, Storage, Cloud Functions, Security Rules и Emulator Suite.

На этапе подготовки production deployment принято архитектурное решение перейти на Supabase Free Tier. Причина: Firebase Cloud Functions production deploy может требовать Blaze/pay-as-you-go plan, а учебному проекту нужен бесплатный и воспроизводимый backend.

Текущий backend выбор для ДЗ 5:

- Supabase Auth;
- PostgreSQL database;
- Row Level Security;
- Supabase Storage;
- Supabase auto REST API через PostgREST;
- Flutter SDK `supabase_flutter`.

## 2. Используемый AI-агент

В качестве AI-агента используется **OpenAI Codex**.

Для Codex создан и обновлен файл `AGENTS.md`. Он является основным файлом инструкций агента в этом репозитории. Правила из ДЗ 2 адаптированы под Codex и расширены под HW5:

- `AGENTS.md` — обязательные правила для Flutter + Supabase разработки;
- `docs/ai_agent_rules.md` — расширенные правила кодирования, Supabase-интеграции и тестирования;
- `docs/ai_workflow.md` — workflow проектирования backend, RLS, Storage, API operations и frontend integration.

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
| Auth | Supabase Auth |
| Database | PostgreSQL |
| File storage | Supabase Storage |
| Backend API | Supabase auto REST API / Supabase client |
| Security | Row Level Security |
| Frontend production hosting | Netlify Free |
| Local backend | Mock repositories, future Supabase CLI validation |
| Flutter tests | flutter_test, mocktail |
| Backend validation | SQL migrations/RLS checks после добавления Supabase project |

## 5. Architecture Decision: Firebase to Supabase

Firebase был исследованным backend-вариантом, потому что он был указан в предыдущем ТЗ PetConnect. Эта ветка помогла спроектировать repository layer, сущности, API operations и security model.

Firebase не выбран как production backend текущего ДЗ из-за риска платного Cloud Functions deployment. Supabase выбран потому, что он прямо поддерживается исходным заданием и дает бесплатный backend path через Auth, PostgreSQL, RLS, Storage и auto REST API.

## 6. Firebase-to-Supabase mapping

| Firebase-прототип | Supabase HW5 |
|---|---|
| Firebase Auth | Supabase Auth |
| Cloud Firestore | PostgreSQL tables |
| Firestore Security Rules | Row Level Security |
| Cloud Functions HTTP API | Supabase auto REST API / Supabase client |
| Firebase Storage | Supabase Storage |
| Firebase Emulator Suite | Supabase project/local validation |

## 7. План backend-интеграции

### Шаг 1. Аудит frontend MVP

Codex проверяет `lib/`, `test/`, `README.md`, `development_report.md`, `prompts.md`, `docs/current_homework_scope.md` и подтверждает, какие mock-слои нужно заменить repository layer.

### Шаг 2. PostgreSQL schema

Планируемые таблицы:

```text
profiles
pets
posts
post_likes
post_comments
chats
chat_participants
messages
walks
walk_participants
```

Схема должна соответствовать user stories: регистрация, питомцы, посты, лайки, комментарии, сообщения и прогулки.

### Шаг 3. Supabase Storage

Storage используется для:

- аватаров пользователей;
- фото питомцев;
- изображений постов.

Policies должны ограничивать загрузку владельцем, MIME type `image/*` и размер файла.

### Шаг 4. Supabase API operations

Минимальные backend/API операции:

1. создание поста через `posts`;
2. лайк/анлайк через `post_likes`;
3. присоединение к прогулке через `walk_participants`;
4. создание питомца через `pets`;
5. чтение ленты через `posts`.

Если счетчики требуют строгой атомарности, добавить PostgreSQL RPC/trigger отдельной миграцией.

### Шаг 5. Row Level Security

RLS и Storage policies должны обеспечить:

- доступ только авторизованным пользователям;
- редактирование своих профилей и питомцев;
- чтение постов авторизованными пользователями;
- доступ к чатам только участникам;
- безопасную модель likes/join rows;
- безопасную загрузку изображений.

### Шаг 6. Frontend integration

Flutter должен перейти на repository layer:

```text
features/*/
  domain/       # repository interfaces
  data/         # Supabase/mock implementations, DTO/mappers
  application/  # Riverpod providers/controllers
  presentation/ # screens/widgets
```

UI не должен обращаться к Supabase напрямую.

### Шаг 7. Supabase validation

После добавления Supabase CLI/migrations:

```bash
supabase db lint
supabase db reset
```

Если CLI еще не подключен, SQL/RLS validation остается ручной проверкой через Supabase dashboard и фиксируется как next step.

### Шаг 8. Тестирование

Сохраняются текущие Flutter tests:

```bash
flutter analyze
flutter test
```

Для backend добавляются SQL/RLS checks после создания Supabase project и migrations.

### Шаг 9. Документирование

Codex фиксирует prompts, решения, ошибки и результаты в:

- `prompts.md`;
- `development_report.md`;
- `README.md`;
- `docs/ai_workflow.md`;
- `docs/current_homework_scope.md`.

## 8. Проблемы и риски

| Риск | Решение |
|---|---|
| Предыдущее ТЗ указывает Firebase | Зафиксировать Firebase как исследованный вариант и Supabase как текущий HW5 backend |
| Cloud Functions deploy может требовать Firebase Blaze plan | Отказаться от Firebase production backend в пользу Supabase Free Tier |
| UI может начать обращаться к backend SDK напрямую | Использовать repository interfaces и Riverpod providers |
| RLS policies могут остаться непроверенными | Добавить SQL/RLS validation после создания Supabase project |
| Mock data может смешаться с production data | Оставить mock repositories только для тестов и fallback |
| Секреты могут попасть в репозиторий | Не коммитить Supabase service role key, реальные `.env`, database password и приватные токены |

## 9. Команды проверки

Flutter:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

Supabase backend, когда project/migrations добавлены:

```bash
supabase db lint
supabase db reset
```

Frontend production build for Netlify:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<your-supabase-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
```

Build output:

```text
build/web
```

## 10. Текущий результат документационного этапа

Документация обновлена под HW5 и текущее решение Supabase:

- `AGENTS.md` описывает OpenAI Codex, Flutter + Supabase стек и обязательные проверки;
- `backend_documentation.md` описывает Architecture Decision: Firebase to Supabase, PostgreSQL schema, RLS, Storage и API operations;
- `docs/frontend_deployment.md` описывает план production-развертывания Flutter Web на Netlify Free;
- `docs/current_homework_scope.md` содержит 9 шагов ДЗ 5 и Firebase-to-Supabase mapping;
- `docs/ai_workflow.md` описывает PostgreSQL schema, RLS, Supabase Storage, API operations, frontend integration и AI-анализ ошибок;
- `docs/documents_index.md` маршрутизирует документы как HW5-материалы;
- `docs/ai_agent_rules.md` задает правила безопасной Supabase-интеграции;
- `README.md` описывает Supabase как текущий backend choice и сохраняет Firebase как исследованную историю.

## 10.1. План production-развертывания Flutter Web

Для закрытия frontend production deployment gap добавлен отдельный план Netlify-развертывания.

Архитектура:

```text
Netlify production URL
  -> Flutter Web static files from build/web
  -> supabase_flutter
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL + RLS
```

Netlify Free выбран, потому что Flutter Web release build является статическим сайтом, а backend-операции уже обслуживаются Supabase. Это не требует платного server-side frontend hosting и дает преподавателю обычную production-ссылку для открытия приложения.

Production frontend получает `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` и `USE_SUPABASE_BACKEND=true` через build-time `--dart-define`. В Netlify реальные значения должны храниться в environment variables. Реальные ключи не добавляются в репозиторий, service role key не используется во Flutter Web.

## 10.1.1. Security review production environment variables

18 июня 2026 выполнена проверка production environment variables для Flutter Web deployment.

Проверено:

- `.env.example` содержит только placeholders: `USE_SUPABASE_BACKEND=true`, `SUPABASE_URL=<your-supabase-url>`, `SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>`;
- `.gitignore` игнорирует реальные `.env` и `.env.*` файлы, при этом оставляет `.env.example` tracked;
- tracked git files не содержат реальных `.env` файлов;
- локальный `.env.deploy` существует только как ignored файл и не должен попадать в commit;
- Flutter config читает `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY` через `String.fromEnvironment`;
- `Supabase.initialize` получает только `publishableKey`, service role key во frontend-коде не используется;
- найденные `supabase.co` совпадения относятся к публичному Project URL в документации, placeholder/test URL или ignored локальным Supabase files, а не к secret key.

Итог: реальные secret key, service role key, database password и access token не обнаружены в tracked frontend/config files. README и frontend deployment docs уточняют, что publishable key является публичной клиентской настройкой, а безопасность пользовательских данных обеспечивается Supabase Auth, RLS policies и Storage policies.

## 10.1.2. Уточнение production target для frontend

Актуальный план frontend production deployment:

| Часть | Значение |
|---|---|
| GitHub source | `https://github.com/SofrikX/otus_hw4/tree/hw5-sb` |
| Hosting | Netlify Free |
| Backend URL | `https://<project-ref>.supabase.co` |
| Build command | `flutter build web --release` with Supabase `--dart-define` values |
| Build output | `build/web` |

Netlify выбран как статический hosting для Flutter Web: release build не требует собственного frontend-сервера, бесплатный тариф подходит для учебной проверки, GitHub можно подключить к deploy pipeline, environment variables можно задать в Netlify UI, а при проблемах со Flutter SDK в Netlify можно вручную загрузить локально собранный `build/web`.

На этом шаге бизнес-логика, Flutter UI, repository layer и Supabase migrations не менялись. Изменения касаются только production deployment документации. Реальный `SUPABASE_PUBLISHABLE_KEY` не добавлялся в tracked files.

## 10.2. Netlify production configuration

Добавлен файл `netlify.toml` для Git-based production deploy Flutter Web на Netlify:

```toml
[build]
  command = "flutter build web --release --dart-define=USE_SUPABASE_BACKEND=true --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

Netlify UI должен хранить `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY` как Environment Variables. Реальный publishable key не записывался в файлы. Для случая, когда Netlify build image не содержит Flutter SDK, документация описывает fallback: локально выполнить `flutter build web --release ...` и загрузить `build/web` через Netlify drag-and-drop.

## 11. История Firebase-прототипа

Следующие разделы сохранены как история исследованной Firebase-ветки. Они объясняют, какие backend/frontend идеи уже были проверены, но не означают, что Firebase остается выбранным production backend для текущего ДЗ.

### Firebase Auth frontend integration

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

### Cloud Functions HTTP API client

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

### Feed screen backend integration

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

### Walks screen backend integration

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

### Pets backend integration

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

### Cloud Functions API endpoint tests

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

### Финальная Firebase backend-документация

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

### Финальный Firebase README для сдачи ДЗ 5

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

### Error handling, logging и AI-анализ ошибок

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

### End-to-end QA и release review HW5

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

Этот список фиксирует первичный QA pass до передачи локальных hosted Supabase values. Актуальный hosted backend smoke status см. в разделе 23.

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

## 12. Текущий результат Supabase architecture update

Дата решения: 17 июня 2026.

Codex обновил документацию так, чтобы Firebase больше не был указан как выбранный production backend. Firebase сохранен как исследованный вариант, от которого отказались из-за ограничения Cloud Functions Blaze/pay-as-you-go.

Supabase теперь зафиксирован как backend для текущего ДЗ:

- Supabase Auth заменяет Firebase Auth;
- PostgreSQL заменяет Cloud Firestore;
- Row Level Security заменяет Firestore Security Rules;
- Supabase auto REST API / Supabase client заменяет Cloud Functions API для MVP operations;
- Supabase Storage заменяет Firebase Storage.

Код Flutter UI и бизнес-логика на этом шаге не менялись. Supabase project, URL и keys не добавлялись. Следующий шаг - создать Supabase project, добавить SQL migrations/RLS policies и выполнить техническую миграцию repository implementations на `supabase_flutter`.

## 13. Supabase project preparation

Дата подготовки: 17 июня 2026.

Codex подготовил структуру подключения Supabase без изменения Flutter-кода:

- добавлена директория `supabase/`;
- добавлена начальная SQL migration `supabase/migrations/202606170001_initial_petconnect_schema.sql`;
- добавлен безопасный `supabase/seed.sql` без production data;
- `.env.example` заменен на Supabase placeholders;
- `.gitignore` дополнен локальными файлами Supabase CLI;
- созданы `docs/supabase_setup.md`, `docs/database_schema.md`, `docs/api_spec.md`, `docs/supabase_security.md`;
- `README.md` и `backend_documentation.md` дополнены Supabase project setup, local configuration, production backend URL и Flutter run command.

Реальные Supabase URL, publishable key, service role key, database password и user data не добавлялись. Flutter UI, `lib/`, `test/` и `pubspec.yaml` не менялись.

## 14. Supabase seed data and local validation

Дата проверки: 17 июня 2026.

Codex подготовил и проверил Supabase seed data для backend QA:

- `supabase/seed.sql` наполняет локальную Supabase database demo-данными;
- seed создает минимальные локальные demo rows в `auth.users`, потому что `profiles.id` ссылается на `auth.users.id`;
- для hosted Supabase project документация требует создать demo users через Supabase Auth UI или регистрацию в приложении и заменить demo UUID на реальные `auth.users.id`;
- реальные персональные данные, production URLs, publishable keys, service role keys, database passwords и secrets не добавлялись.

Установленные локальные инструменты для проверки:

- Supabase CLI `2.106.0` через Homebrew;
- Docker CLI через Homebrew;
- Colima/Lima как Docker-compatible runtime.

Команды проверки:

```bash
supabase db start
supabase db reset
supabase db lint
```

Результат:

- `supabase db start` применил migrations и seed;
- `supabase db reset` успешно пересоздал локальную database, применил `001_initial_schema.sql`, `002_rls_policies.sql` и `supabase/seed.sql`;
- `supabase db lint` завершился без schema errors;
- SQL smoke checks подтвердили ожидаемые counts: 2 profiles, 3 pets, 4 posts, 5 comments, 4 post_likes, 3 walks, 4 walk_participants, 1 chat, 2 chat_participants и 3 messages;
- counter triggers пересчитали `posts.likes_count`, `posts.comments_count` и `walks.participants_count`.

Ограничение окружения:

- Полный `supabase start` с API/Studio stack на Colima дошел до seed, но затем упал на запуске `supabase_vector_otus_dz4` из-за mount ошибки Docker socket Colima. Для текущей SQL/RLS/seed проверки использован поддерживаемый путь `supabase db start` / `supabase db reset`, который поднимает локальный Postgres и валидирует migrations plus seed.

## 15. Supabase Auth frontend integration

Дата интеграции: 17 июня 2026.

Codex интегрировал Supabase Auth во Flutter frontend без добавления реальных Supabase credentials:

- добавлена зависимость `supabase_flutter`;
- `BackendConfig` читает `USE_SUPABASE_BACKEND`, `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY` из `--dart-define`;
- добавлен `initializeSupabaseApp`, который инициализирует Supabase только при `USE_SUPABASE_BACKEND=true`;
- auth abstraction вынесена в `AuthRepository`;
- добавлен `SupabaseAuthRepository` для email/password sign up, sign in, sign out, current user и auth state changes;
- после sign up/sign in выполняется upsert строки в `public.profiles`, если Supabase session доступна;
- добавлен `MockAuthRepository`, чтобы mock mode не требовал backend credentials;
- `AuthController` и `authStateProvider` сохранены как Riverpod entry points для UI;
- routing теперь защищает экраны только в backend auth mode и ведет anonymous user на `/login` при `USE_SUPABASE_BACKEND=true`;
- token provider умеет отдавать Supabase access token для дальнейших Supabase API calls.

UI:

- существующие `LoginScreen` и `RegisterScreen` используют controller, показывают loading/error states и получают success redirect через auth state + router;
- user-facing ошибки нормализованы для invalid credentials, already registered email, weak password, invalid email и network/service failure.

Проверки:

```bash
dart format .
flutter analyze
flutter test
```

Результат:

- `dart format .` выполнен;
- `flutter analyze` завершился без замечаний;
- полный `flutter test` прошел: 52 tests passed;
- добавлены тесты auth controller success/error, login screen loading/error и routing guard для Supabase backend vs mock mode.

Ограничения:

- реальные Supabase project URL и publishable key не добавлялись;
- ручная проверка hosted Supabase sign up/sign in остается next step после создания project;
- feed/pets/walks repositories еще не переведены на Supabase data API в этом шаге.

## 16. Supabase feed frontend integration

Дата интеграции: 17 июня 2026.

Codex интегрировал ленту PetConnect с Supabase data API, сохранив mock fallback:

- `FeedRepository` расширен операцией `addComment`;
- добавлен `SupabaseFeedRepository` для `fetchPosts`, `createPost`, `toggleLike` и `addComment`;
- `feedRepositoryProvider` выбирает `SupabaseFeedRepository` только при `USE_SUPABASE_BACKEND=true`, иначе использует `MockFeedRepository`;
- старый `ApiFeedRepository` для Firebase/Cloud Functions оставлен компилируемым как legacy implementation, но больше не является выбранным backend path для feed;
- `FeedController` сохраняет loading/error/empty/success states через `AsyncValue` и не превращает backend errors в пустую ленту;
- `toggleLike` и `addComment` делают optimistic UI update, а затем синхронизируют счетчики с repository result;
- Supabase/PostgREST/Auth exceptions мапятся в typed `ApiException`, чтобы `AsyncContentView` показывал дружелюбный error state с retry.

Используемые Supabase таблицы:

- `posts` для SELECT public feed и INSERT новых постов;
- `post_likes` для INSERT/DELETE лайка текущего пользователя;
- `comments` для INSERT комментариев и отображения последних комментариев;
- counters `posts.likes_count` и `posts.comments_count` перечитываются после write operations, потому что обновляются database triggers.

Проверки:

```bash
dart format lib/core/network/api_client.dart lib/core/supabase/supabase_client_provider.dart lib/features/feed/domain/feed_repository.dart lib/features/feed/data/mock_feed_repository.dart lib/features/feed/data/api_feed_repository.dart lib/features/feed/data/supabase_feed_repository.dart lib/features/feed/application/feed_controller.dart lib/features/feed/presentation/screens/feed_screen.dart test/features/feed/feed_controller_test.dart
flutter test test/features/feed
flutter analyze
flutter test
```

Результат:

- `flutter test test/features/feed` прошел: 17 feed tests passed;
- `flutter analyze` завершился без замечаний;
- полный `flutter test` прошел: 53 tests passed.

Ограничения:

- реальные Supabase URL/publishable key не добавлялись;
- hosted Supabase smoke test остается next step после создания project и применения migrations;
- pets/walks data repositories остаются следующими кандидатами на Supabase integration.

## 17. Supabase pet profile integration

Дата интеграции: 17 июня 2026.

Codex интегрировал профили питомцев PetConnect с Supabase data API, сохранив mock fallback:

- `PetRepository` расширен операциями `fetchPets` и `createPet`, а существующие `getPetById` и `getPetsByOwner` сохранены;
- добавлен `SupabasePetRepository` для таблицы `pets`;
- `petRepositoryProvider` выбирает `SupabasePetRepository` при `USE_SUPABASE_BACKEND=true`, legacy `ApiPetRepository` при `USE_FIREBASE_BACKEND=true`, иначе `MockPetRepository`;
- `PetsScreen` и `PetProfileScreen` продолжают получать данные через Riverpod providers, а не через прямой Supabase SDK call из UI;
- `PetProfileScreen` сохраняет loading, error with retry, not found и success states через `AsyncContentView`;
- Supabase/PostgREST/Auth exceptions мапятся в typed `ApiException`; RLS denial `42501` превращается в `ApiForbiddenException`;
- mock repository поддерживает создание питомца для локальной разработки и тестов.

Используемые Supabase операции:

```dart
supabase.from('pets').select(...).eq('id', petId).maybeSingle();
supabase.from('pets').select(...).eq('owner_id', ownerId).order('created_at');
supabase.from('pets').insert({...}).select(...).single();
```

Проверки:

```bash
dart format lib/core/network/api_client.dart lib/features/pets test/features/pets
flutter test test/features/pets
flutter analyze
flutter test
```

Результат:

- `flutter test test/features/pets` прошел: 14 pet tests passed;
- `flutter analyze` завершился без замечаний;
- полный `flutter test` прошел: 59 tests passed.

Ограничения:

- реальные Supabase URL/publishable key не добавлялись;
- hosted Supabase smoke test профилей питомцев остается next step после создания project и применения migrations;
- Supabase Storage upload фото питомца пока не подключался к UI, используется существующий `photo_emoji` fallback.

## 18. Supabase walks integration

Дата интеграции: 17 июня 2026.

Codex интегрировал прогулки PetConnect с Supabase data API, сохранив mock fallback:

- `WalksRepository` расширен операциями `createWalk` и `leaveWalk`; существующие `fetchWalks` и `joinWalk` сохранены;
- добавлен `SupabaseWalkRepository` для таблиц `walks` и `walk_participants`;
- `walksRepositoryProvider` выбирает `SupabaseWalkRepository` при `USE_SUPABASE_BACKEND=true`, legacy `ApiWalksRepository` при `USE_FIREBASE_BACKEND=true`, иначе `MockWalksRepository`;
- `WalksController` сохраняет loading/error/empty/success states через `AsyncValue`;
- `joinWalk` возвращает typed status: `joined`, `alreadyJoined`, `unavailable` или `failed`;
- unique constraint `walk_participants(walk_id, user_id)` с PostgREST code `23505` превращается в friendly `alreadyJoined` result, а UI показывает snackbar "Вы уже участвуете";
- `WalksScreen` продолжает использовать `AsyncContentView` для loading, error with retry, empty и success states.

Используемые Supabase операции:

```dart
supabase.from('walks').select(...).eq('status', 'active').order('scheduled_at');
supabase.from('walk_participants').select('walk_id').eq('user_id', userId);
supabase.from('walks').insert({...}).select(...).single();
supabase.from('walk_participants').insert({'walk_id': walkId, 'user_id': userId});
supabase.from('walk_participants').delete().eq('walk_id', walkId).eq('user_id', userId);
```

Проверки:

```bash
dart format lib/features/walks test/features/walks
flutter test test/features/walks
flutter analyze
flutter test
```

Результат:

- `flutter test test/features/walks` прошел: 20 walks tests passed;
- добавлены repository/controller/widget tests для list success, join success, already joined и error state;
- `flutter analyze` завершился без замечаний;
- полный `flutter test` прошел: 68 tests passed.

Ограничения:

- реальные Supabase URL/publishable key не добавлялись;
- hosted Supabase smoke test прогулок остается next step после создания project и применения migrations;
- создание прогулки реализовано в repository layer, но отдельная UI-форма создания прогулки в этой задаче не добавлялась.

## 19. Supabase error handling, logging and AI debugging

Дата доработки: 17 июня 2026.

Codex проверил обработку ошибок Supabase backend integration в `lib/core/`, `lib/features/auth/`, `lib/features/feed/`, `lib/features/pets/`, `lib/features/walks/`, `docs/supabase_security.md`, `backend_documentation.md` и `README.md`.

Реальные кейсы отладки:

- В feed/pets/walks repositories был повторяющийся PostgREST mapper. Codex вынес общий `guardSupabaseOperation` и единый mapper в `lib/core/supabase/supabase_error_mapper.dart`.
- RLS denial `42501` из Supabase/PostgreSQL проверен как forbidden case. В тестовом выводе debug-log показывает только безопасные поля: `operation=pets status=403 code=42501 type=ApiForbiddenException`.
- Найден UX-риск: при PostgreSQL validation codes (`23505`, `23503`, `22P02`) `ApiException.userMessage` мог вернуть raw backend message. Codex изменил `userMessage`, чтобы UI показывал friendly messages по типу/status, а не сырые PostgreSQL тексты.
- Полный `flutter test` сначала упал на тесте malformed 502 response: тест ожидал raw message `Request failed with status 502.`. После новой политики безопасных сообщений expectation обновлен на `Сервер временно недоступен. Попробуйте позже.`, повторный прогон прошел.

Итоговая классификация:

- network error -> `ApiNetworkException`;
- unauthorized -> `ApiUnauthorizedException`;
- forbidden/RLS -> `ApiForbiddenException`;
- validation -> `ApiValidationException`;
- not found -> `ApiNotFoundException`;
- unknown -> `ApiUnexpectedException`.

Логирование:

- включается только в debug mode;
- не пишет tokens, publishable key, service role key, email, имена пользователей, ids строк, текст постов или комментариев;
- пишет только operation/status/code/type, чтобы эти строки можно было безопасно использовать для AI-assisted debugging.

Проверки:

```bash
dart format lib/core/network/api_error.dart lib/core/supabase/supabase_error_mapper.dart lib/features/auth/data/supabase_auth_repository.dart lib/features/feed/data/supabase_feed_repository.dart lib/features/pets/data/supabase_pet_repository.dart lib/features/walks/data/supabase_walk_repository.dart test/core/network/api_client_test.dart
flutter analyze
flutter test
```

Результат:

- `flutter analyze` завершился без замечаний;
- полный `flutter test` прошел: 68 tests passed.

## 20. Supabase production release documentation

Дата документационного release review: 17 июня 2026.

Codex выступил в роли Supabase Release Engineer и QA Reviewer. Целью было подготовить документы для production-развертывания Supabase backend и не утверждать ручную проверку hosted project без фактического smoke test.

Что обновлено:

- `docs/supabase_setup.md` переписан как production runbook: создание Supabase project, получение `SUPABASE_URL`, получение `SUPABASE_PUBLISHABLE_KEY`, применение migrations через SQL Editor, применение `seed.sql`, проверка таблиц, проверка RLS и manual verification checklist.
- `backend_documentation.md` получил раздел `Production project status`: Supabase project, database, Auth, RLS, Storage, REST API и frontend backend mode.
- `README.md` получил production backend setup, Flutter launch command с `--dart-define` и release checklist.
- В документации явно указано, что реальные publishable key, service role key, database password и `.env` не добавляются в git.
- Production verification оформлен как `Manual verification checklist`, потому что hosted project smoke test не был выполнен в рамках этой Codex-задачи.

Production verification checklist для сдачи:

- Supabase project создан на Free Tier.
- Migrations применены к hosted project.
- RLS включен для application tables.
- Flutter запущен с `USE_SUPABASE_BACKEND=true`.
- `SELECT posts` работает для authenticated user.
- Sign up/sign in работает.
- Create post работает.
- Like post работает и обновляет counter.
- Join walk работает и обновляет counter.

Проверка этой задачи:

- Код Flutter и SQL migrations не менялись.
- Реальные Supabase credentials не добавлялись.
- Выполнена документационная проверка diff.

## 21. End-to-end QA review with Supabase backend

Дата QA review: 17 июня 2026.

Codex выступил в роли QA Engineer и Release Reviewer. Цель проверки — подтвердить, что PetConnect готов к end-to-end работе с Supabase backend, и не скрывать проблемы, если hosted Supabase project или credentials отсутствуют.

Прочитано и проверено:

- `README.md`;
- `backend_documentation.md`;
- `docs/supabase_setup.md`;
- `docs/api_spec.md`;
- `docs/supabase_security.md`;
- `development_report.md`;
- `prompts.md`;
- структура `lib/`;
- структура `test/`;
- Supabase repositories для auth, feed, pets и walks;
- startup configuration flow в `main.dart` и `BackendConfig`.

Команды и результаты:

```bash
flutter pub get
```

Результат: успешно. Первичный запуск в sandbox уперся в запрет записи Flutter SDK cache вне workspace, после разрешения команда прошла. Зависимости получены, новых secrets не добавлено.

```bash
dart format .
```

Результат: успешно, изменений форматирования нет.

```bash
flutter analyze
```

Результат: успешно, `No issues found!`.

```bash
flutter test
```

Результат до исправления: 68 tests passed.

После исправления startup error state:

```bash
dart format .
flutter analyze
flutter test
```

Результат: успешно, `No issues found!`, полный test suite прошел: 69 tests passed.

Запуск mock mode:

```bash
flutter run -d chrome --dart-define=USE_SUPABASE_BACKEND=false
```

Результат: приложение запустилось в Chrome debug mode, Dart VM service поднялся. Mock mode не требует Supabase credentials. In-app browser tool не смог открыть random local Flutter web port из-за `ERR_BLOCKED_BY_CLIENT`, поэтому ручные клики в живом браузере не были выполнены через tool; соответствующие сценарии подтверждаются widget/controller tests.

Запуск Supabase mode с пустыми значениями, как в QA-задании:

```bash
flutter run -d chrome --dart-define=USE_SUPABASE_BACKEND=true --dart-define=SUPABASE_URL= --dart-define=SUPABASE_PUBLISHABLE_KEY=
```

Первичный результат: найден дефект. Приложение падало до UI с `DartError: SUPABASE_URL is required when USE_SUPABASE_BACKEND=true.`. Это не соответствовало сценарию "error state при неправильном SUPABASE_URL".

После исправления та же команда запускается без DartError на bootstrap и показывает startup error screen для неверной Supabase-конфигурации.

Manual scenarios:

| # | Scenario | Result |
|---|---|---|
| 1 | Запуск mock mode | Passed: Flutter Web запускается с `USE_SUPABASE_BACKEND=false` |
| 2 | Запуск Supabase mode | Partially passed: приложение запускается с пустыми values после fix, но hosted Supabase e2e требует реальные local credentials |
| 3 | Регистрация пользователя | Первичный UI pass требовал local hosted values; final fresh sign-up оставлен как ручной UI step |
| 4 | Вход пользователя | Backend/Auth smoke позже пройден на hosted Supabase; auth repository/widget tests также проходят |
| 5 | Загрузка ленты из Supabase | Backend/API smoke позже пройден на hosted Supabase; SupabaseFeedRepository покрыт tests |
| 6 | Создание поста | Backend path подготовлен; полный create post через Flutter UI оставлен как ручной UI step |
| 7 | Лайк поста | Backend/API smoke позже пройден на hosted Supabase |
| 8 | Добавление комментария | Backend/API smoke позже пройден на hosted Supabase |
| 9 | Открытие профиля питомца | Mock/widget path passed by tests; hosted Supabase path blocked без credentials/seed |
| 10 | Загрузка прогулок | Mock/widget path passed by tests; hosted Supabase path blocked без credentials/seed |
| 11 | Присоединение к прогулке | Mock/controller path passed by tests; hosted Supabase path blocked без credentials/seed |
| 12 | Error state при неправильном `SUPABASE_URL` | Failed before fix, passed after fix through startup error screen |
| 13 | RLS: пользователь не может менять чужие данные | Not executed against hosted project; repository tests cover RLS denial mapping for `42501`, SQL/RLS manual verification still required |
| 14 | Mobile/desktop адаптивность | Covered by existing responsive widgets and screenshot docs; live browser viewport check blocked by browser tool local-port restriction |

Найденные проблемы:

1. Supabase configuration error падал до UI.
   Причина: `initializeSupabaseApp()` обращался к `BackendConfig.supabaseUri`, который бросает `BackendConfigException`, а `main()` не перехватывал это исключение до `runApp`.
   Минимальный fix: перехватить `BackendConfigException` в `main()` и показать отдельный Material startup error screen.

2. Hosted Supabase e2e на этом первичном шаге не мог быть честно подтвержден без локальных `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY`.
   Причина: в репозитории intentionally отсутствуют real credentials, secrets не должны добавляться.
   Минимальный fix для release process: выполнить hosted deployment и smoke checks с локальными credentials. Это выполнено позже в разделе 23.

Исправления:

- добавлен `lib/app/startup_error_app.dart`;
- `lib/main.dart` теперь перехватывает `BackendConfigException` при startup и показывает friendly error state;
- добавлен `test/app/startup_error_app_test.dart`;
- `flutter test` обновлен до 69 passing tests.

Remaining risks на момент первичного QA pass:

- на момент первичного QA pass hosted Supabase smoke еще не был выполнен; итоговый hosted smoke см. в разделе 23;
- RLS policies не проверены против реального hosted project двумя пользователями;
- create post / like / comment / join walk e2e требуют seeded hosted data и authenticated session;
- browser tool не смог открыть локальный Flutter Web random port, поэтому live responsive click-through проверка выполнена не была.

## 22. Supabase CLI validation before hosted deploy

Дата проверки: 17 июня 2026.

После решения о необходимости настоящего backend deployment Codex подготовил Supabase CLI workflow и выполнил локальную проверку migrations/RLS/seed перед cloud push.

Что сделано:

- создан `supabase/config.toml` через `supabase init`;
- добавлен Supabase-local `.gitignore` для `.branches`, `.temp` и локальных env-key файлов;
- поднят Docker runtime через `colima start`;
- локальный Supabase запущен командой `supabase start --exclude vector`, потому что стандартный `supabase_vector_*` container в текущей Colima-конфигурации падал на mount docker socket;
- выполнены `supabase db lint` и `supabase db reset`;
- SQL smoke checks выполнены через `docker exec supabase_db_otus_dz4 psql`.

Команды и результаты:

```bash
supabase --version
```

Результат: CLI установлен, версия `2.106.0`.

```bash
supabase projects list
```

Результат на этом промежуточном шаге: CLI требовал локальную авторизацию через `supabase login --token` или `SUPABASE_ACCESS_TOKEN`. Hosted deploy был выполнен позже в разделе 23.

```bash
supabase init
colima start
supabase start --exclude vector
supabase db lint
supabase db reset
```

Результат:

- migrations `001_initial_schema.sql` и `002_rls_policies.sql` применяются локально;
- seed применяется локально;
- `supabase db lint` вернул `No schema errors found`;
- `supabase db reset` завершился успешно.

Smoke checks:

| Check | Result |
|---|---|
| `profiles` | 2 |
| `pets` | 3 |
| `posts` | 4 |
| `comments` | 5 |
| `post_likes` | 4 |
| `walks` | 3 |
| `walk_participants` | 4 |
| `chats` | 1 |
| `chat_participants` | 2 |
| `messages` | 3 |
| RLS enabled | `true` для всех application tables |
| Storage buckets | `avatars`, `pet-photos`, `post-images`, all private |
| Trigger counters | likes sum 4, comments sum 5, walk participants sum 4 |

Дополнительная Flutter-проверка после Supabase config:

```bash
dart format .
flutter analyze
flutter test
```

Результат: format без изменений, analyzer без замечаний, полный тестовый набор прошел: 69 tests passed.

Hosted deployment был продолжен в следующем release step. Реальные Supabase credentials и production secrets в репозиторий не добавлялись.

## 23. Hosted Supabase deployment and smoke test

Дата проверки: 17 июня 2026.

Цель: выполнить настоящий hosted Supabase deployment для сдачи ДЗ и подтвердить end-to-end backend path без добавления secrets в git.

Команды и результаты:

```bash
supabase login --token <local-token>
```

Результат: успешно. Access token использовался только локально и не записан в отчеты или tracked files.

```bash
supabase link --project-ref <project-ref> --password <db-password>
```

Результат: hosted project linked через Supabase CLI. Project credentials остались в локальном `.env.deploy`, который не коммитится.

```bash
supabase db push --linked --dry-run
supabase db push --linked
```

Результат: migrations применены к hosted database. После обнаружения PostgREST permission issue добавлена migration `supabase/migrations/003_api_grants.sql`, которая выдает `authenticated` role доступ к application tables; RLS policies остаются row-level guard.

Hosted seed:

- прямой SQL insert в `auth.users` оказался недостаточным для надежного hosted email/password login;
- минимальный fix: создать demo Auth users через Supabase Auth Admin/API flow, затем применить public demo rows из seed с теми же UUID;
- service role key и database password не сохранялись в репозитории.

Hosted smoke checks:

| Scenario | Result |
|---|---|
| Supabase Auth login | Passed |
| Load feed from Supabase | Passed: authenticated REST read returned seeded posts |
| Load walks from Supabase | Passed: authenticated REST read returned seeded walks |
| Like post | Passed: REST insert succeeded and counter updated |
| Add comment | Passed: REST insert succeeded and counter updated |
| Join walk | Passed: REST insert succeeded and counter updated |
| RLS: User B cannot mutate User A rows | Passed: attempted updates left User A rows unchanged |
| Flutter Web Supabase mode | Passed: `supabase_flutter` initialized with hosted values from local env |

Additional issue found:

1. Hosted PostgREST returned `403` for authenticated writes before grants.
   Cause: RLS policies existed, but table privileges for `authenticated` role were missing.
   Minimal fix: add `supabase/migrations/003_api_grants.sql` with grants for application tables and `is_chat_participant(uuid)`.

Remaining risks:

- Full sign-up through Flutter UI with a fresh email still needs final manual browser click-through.
- Create post through the Flutter feed UI still needs final manual browser click-through.
- Mobile/desktop responsiveness should be rechecked in a live browser after final deployment credentials are set locally.

No secrets were added to tracked files.

## 24. Final backend documentation for submission

Цель: подготовить `backend_documentation.md` как финальный backend-документ для сдачи ДЗ 5 с Supabase backend.

Codex выступил в роли Technical Writer и Backend Architect. Перед правкой были прочитаны:

- `docs/documents_index.md`;
- `README.md`;
- `docs/supabase_setup.md`;
- `docs/database_schema.md`;
- `docs/supabase_security.md`;
- `docs/api_spec.md`;
- `docs/seed_data.md`;
- `development_report.md`;
- `prompts.md`;
- `supabase/migrations/001_initial_schema.sql`;
- `supabase/migrations/002_rls_policies.sql`;
- `supabase/migrations/003_api_grants.sql`;
- `supabase/seed.sql`.

Что обновлено:

- `backend_documentation.md` пересобран как самостоятельная финальная документация для преподавателя.
- В документ включены архитектура, Firebase-to-Supabase decision, database schema, migrations, seed data, RLS policies, Storage, API operations, examples, deployment, env/secrets, error handling, logging/debugging, frontend integration, testing, AI-assisted development, known MVP limitations и final checklist.
- Документация синхронизирована с фактическим hosted Supabase status: migrations применены, RLS включен, `003_api_grants.sql` добавлен для PostgREST grants, Auth/feed/walks/like/comment/join smoke checks пройдены.

Код Flutter, SQL migrations и Supabase secrets на этом шаге не менялись. Автоматические тесты не запускались, потому что изменение относится только к документации.

## 25. Supabase publishable key migration

Дата изменения: 18 июня 2026.

Цель: обновить PetConnect с legacy Supabase client-key terminology на новый Supabase Publishable Key для Flutter Web.

Что изменено:

- `BackendConfig` теперь читает `USE_SUPABASE_BACKEND`, `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY`.
- Старое config-поле ключа переименовано в `supabasePublishableKey`.
- `initializeSupabaseApp()` передает publishable key в `Supabase.initialize`.
- Startup error screen теперь подсказывает проверить `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY`.
- `.env.example`, `netlify.toml`, README, backend docs, Supabase setup/security/API docs и frontend deployment docs обновлены под `SUPABASE_PUBLISHABLE_KEY`.
- README фиксирует, что legacy anon key не используется, а secret key/service role key запрещены во Flutter Web.
- Security docs уточняют, что RLS policies остаются обязательной границей доступа к user data.

Реальный Supabase publishable key использовался только как локальный input из задания и не записывался в tracked files.

Проверки:

План проверки: выполнить required search check из задачи, `dart format .`, `flutter analyze` и `flutter test`.

## 26. Production Flutter Web build against Supabase

Дата проверки: 18 июня 2026.

Цель: провести production build Flutter Web приложения PetConnect против hosted Supabase backend и подтвердить, что release artifact собирается в `build/web`.

Перед запуском Codex прочитал и проверил:

- `README.md`;
- `docs/frontend_deployment.md`;
- `backend_documentation.md`;
- `development_report.md`;
- `prompts.md`;
- `pubspec.yaml`;
- `web/`;
- `lib/`;
- project routing docs: `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`.

Команды и результаты:

```bash
flutter pub get
```

Результат: зависимости получены успешно.

```bash
dart format .
```

Результат: `Formatted 77 files (0 changed)`.

```bash
flutter analyze
```

Результат: `No issues found!`.

```bash
flutter test
```

Результат: полный тестовый набор прошел, `69 tests passed`.

Production build command, documented with placeholders:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<production-supabase-project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

Фактический локальный build был выполнен против Supabase project URL `https://<project-ref>.supabase.co`; реальный publishable key использовался только в локальной CLI-команде и не записывался в tracked files.

Результат production build:

```text
✓ Built build/web
```

Build output:

```text
build/web
```

`build/web` подтвержден как ignored artifact через `.gitignore`, поэтому он не должен попадать в commit. README и deployment docs уже содержали корректную placeholder-команду, поэтому дополнительная правка README не потребовалась.

Замечания build output:

- Flutter сообщил, что dependency `ua_client_hints_web.dart` использует `dart:html`, поэтому текущая сборка имеет предупреждение для future WebAssembly mode. Обычный JavaScript release build завершился успешно.
- Flutter показал предупреждение про отсутствующий `packages/cupertino_icons/CupertinoIcons`; текущий release build не упал, но перед финальным UI smoke test стоит убедиться, что приложение не использует Cupertino icon glyphs без зависимости.

## 27. Netlify secrets scanning cleanup

Дата проверки: 18 июня 2026.

Цель: исправить падение Netlify deploy, где secrets scanning находил значение `SUPABASE_URL` в документации и build output.

Решение:

- реальный Supabase project URL заменен в tracked документации на placeholder `https://<project-ref>.supabase.co`;
- в `netlify.toml` добавлен `SECRETS_SCAN_OMIT_KEYS` для публичных frontend-переменных `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY`;
- README, backend documentation и frontend deployment docs дополнены пояснением, что эти значения являются public client configuration для Flutter Web, а service role key, database password и private tokens не должны попадать в frontend и omit list.

Проверка:

```bash
rg -n "<old-production-supabase-project-ref>" README.md backend_documentation.md development_report.md docs/frontend_deployment.md prompts.md
```

Результат: реальный Supabase project URL в tracked documentation не найден.

## 28. Final production E2E verification

Дата проверки: 18 июня 2026.

Роль Codex: QA Engineer и Release Reviewer.

Production inputs:

```text
Frontend URL: https://cool-duckanoo-d28d04.netlify.app
Supabase URL: https://fivtpxsjcjirddogngtl.supabase.co
Supabase status: Healthy
```

Прочитано перед проверкой:

- `README.md`;
- `backend_documentation.md`;
- `docs/frontend_deployment.md`;
- `docs/supabase_setup.md`;
- `docs/seed_data.md`;
- `docs/supabase_security.md`;
- `development_report.md`;
- `prompts.md`;
- `lib/features/`.

Фактический результат:

- Production URL открывается.
- Flutter Web assets доступны на Netlify.
- Login screen отображается.
- Production bundle содержит ожидаемый Supabase project URL и public publishable key.
- Seed demo users работают через Supabase Auth API:
  - `demo.alina@petconnect-demo.com`;
  - `demo.mark@petconnect-demo.com`.
- Production database не пустая: authenticated REST counts показали данные в profiles, pets, posts, comments, post_likes, walks и walk_participants.
- Backend REST smoke checks прошли для чтения feed/walks, comment insert, like insert и walk join.

Release blocker:

- После успешного входа через UI приложение переходит на `/`, но экран становится белым.
- Browser console показывает:

```text
Null check operator used on a null value
Cannot read properties of undefined (reading 'init')
```

- Из-за этого UI checks для feed, create post, like, comment, pet profile, walks и join walk заблокированы в production frontend.
- Fresh signup также не готов как основной reviewer path: Supabase вернул `over_email_send_rate_limit`, поэтому для проверки нужны seeded demo users, ручное confirmation в Dashboard или временно отключенное email confirmation.

Минимальный fix, примененный локально:

- В `web/index.html` внешний Corbado/passkeys bundle перенесен перед `flutter_bootstrap.js`, чтобы web binding был готов до старта Flutter/Supabase Auth.

Проверки после локального fix:

```bash
flutter analyze
flutter test
```

Результат:

- `flutter analyze`: `No issues found!`.
- `flutter test`: `69 tests passed`.

Оставшийся шаг перед сдачей:

1. Пересобрать Flutter Web release с production Supabase dart-defines.
2. Задеплоить новый `build/web` на Netlify.
3. Повторить browser E2E: login, feed, create post, like, comment, pet profile, walks, join walk, mobile и desktop.

## 29. HW6 GitHub Actions CI/CD

Дата изменения: 19 июня 2026.

Цель: подготовить PetConnect к ДЗ "Настройка CI/CD и интеграция сервисов" через GitHub Actions pipeline для Flutter Web и Netlify deployment.

Роль Codex: DevOps Engineer и GitHub Actions Specialist.

Перед изменениями прочитаны:

- `README.md`;
- `netlify.toml`;
- `pubspec.yaml`;
- `test/`;
- `.gitignore`;
- `docs/frontend_deployment.md`;
- текущие `development_report.md` и `prompts.md`.

Что добавлено:

- `.github/workflows/ci_cd.yml` с запуском на `pull_request` и `push` в `main`;
- Flutter stable setup через `subosito/flutter-action`;
- Flutter cache через setup action;
- этапы `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`;
- release build Flutter Web с `USE_SUPABASE_BACKEND=true`, `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY` из GitHub repository secrets;
- production deploy в Netlify через `npx netlify-cli deploy --prod --dir=build/web` только на `push` в `main`;
- `integration_documentation.md` с разделом CI/CD;
- README section с описанием pipeline, secrets и проверок.

GitHub repository secrets, которые нужно настроить вручную:

```text
NETLIFY_AUTH_TOKEN
NETLIFY_SITE_ID
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

Реальные значения secrets в репозиторий не добавлялись. `build/web` остается ignored artifact и не должен коммититься.

Локальная проверка для parity с CI:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<production-supabase-project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

## 30. Security Audit

Дата изменения: 19 июня 2026.

Цель: выполнить аудит безопасности PetConnect для Flutter Web, Supabase, Netlify/GitHub Actions и исторической Firebase Functions ветки.

Роль Codex: Security Auditor, Flutter Reviewer и Supabase Security Engineer.

Перед изменениями проверены:

- `pubspec.yaml` и `pubspec.lock`;
- `functions/package.json` и `functions/package-lock.json`;
- `netlify.toml`;
- `.github/workflows/`;
- `supabase/migrations/`, `supabase/seed.sql`, `supabase/config.toml`;
- `README.md`, `backend_documentation.md`, `integration_documentation.md`;
- `lib/`, `web/`, `docs/`.

Что найдено:

- service role key, `sb_secret_`, private tokens и реальные token-like publishable keys в tracked source/docs не найдены;
- tracked `.env` файлов нет, кроме безопасного `.env.example`;
- локальный ignored `.env.deploy` содержит реальные локальные deployment values и должен оставаться вне git;
- RLS был включен на всех application tables, но политики для posts/comments/likes требовали усиления по приватности и владению питомцем;
- local OAuth redirect config содержал некорректный `https://127.0.0.1:3000`;
- Flutter Web код не использует `dart:html`, `innerHtml`, `eval` или ручную DOM-вставку пользовательских данных;
- `npm audit` нашел moderate advisory в исторической Firebase Functions dependency chain.

Что исправлено:

- создан `security_audit.md` с findings, командами, OWASP mapping, fixes и remaining risks;
- усилены RLS policies в `supabase/migrations/002_rls_policies.sql`;
- `supabase/config.toml` получил точные local/prod redirect URLs без wildcard;
- `functions/package.json` и `functions/package-lock.json` обновлены так, что `npm audit` возвращает `found 0 vulnerabilities`;
- README дополнен security audit commands;
- `integration_documentation.md` дополнен security audit summary.

Проверки:

```bash
flutter pub outdated
flutter analyze
cd functions && npm audit
cd functions && npm run build
supabase db lint
```

Результат:

- `flutter pub outdated`: выполнен, показал доступные updates/major upgrades для планового обновления;
- `flutter analyze`: `No issues found!`;
- `npm audit`: после fix `found 0 vulnerabilities`;
- `npm run build`: TypeScript build passed;
- `supabase db lint`: заблокирован, потому что local Postgres на `127.0.0.1:54322` не запущен.

## 31. Google OAuth2 через Supabase Auth

Дата изменения: 19 июня 2026.

Цель: добавить OAuth2 integration для входа через Google, не ломая существующий email/password Supabase Auth flow.

Роль Codex: Supabase Auth Engineer и Flutter Developer.

Перед изменениями прочитаны:

- `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`;
- `lib/features/auth/`;
- `lib/core/supabase/`;
- `lib/app/`;
- `README.md`;
- `backend_documentation.md`;
- `docs/supabase_setup.md`;
- `supabase/migrations/`;
- `integration_documentation.md`.

Что изменено:

- `AuthRepository` получил метод `signInWithGoogle()`;
- `AuthController` прокидывает Google OAuth вход через repository layer;
- `SupabaseAuthRepository` вызывает `signInWithOAuth(OAuthProvider.google)` и использует redirect URL из конфигурации;
- `BackendConfig` получил `SUPABASE_AUTH_REDIRECT_URL` с production default `https://cool-duckanoo-d28d04.netlify.app/`;
- `LoginScreen` получил кнопку `Войти через Google`, loading state и общий friendly error banner;
- mock repository поддерживает Google sign-in для локальных проверок и тестов;
- `supabase/config.toml` содержит exact production и localhost redirect URLs;
- README, backend docs, Supabase setup docs и integration docs описывают Dashboard setup.

Секреты:

- Google Client ID не нужен во Flutter-коде;
- Google Client Secret вводится только в Supabase Dashboard и Google Cloud Console;
- Client Secret не добавлялся в git, docs, `--dart-define`, Netlify или GitHub Actions.

Автотесты:

- добавлена проверка, что кнопка Google OAuth отображается;
- добавлена проверка, что `AuthController.signInWithGoogle()` вызывает repository method;
- добавлена проверка error state для Google OAuth.

## 32. Frontend analytics через Yandex Metrica

Дата изменения: 19 июня 2026.

Цель: добавить frontend analytics для Flutter Web без поломки web build и без передачи персональных данных.

Роль Codex: Flutter Web Analytics Engineer и Product Analyst.

AI использован для выбора событий по ключевым продуктовым воронкам PetConnect: открытие приложения, регистрация, успешный вход, открытие ленты, создание поста, лайк, комментарий, присоединение к прогулке, auth error и backend error.

Перед изменениями прочитаны:

- `web/index.html`;
- `lib/app/`, `lib/core/`, `lib/features/feed/`, `lib/features/auth/`, `lib/features/walks/`;
- `README.md`;
- `integration_documentation.md`;
- `backend_documentation.md`;
- project routing docs from `docs/`.

Что изменено:

- добавлен `lib/core/analytics/analytics_service.dart` с конфигурацией через `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER`, `ANALYTICS_ID`;
- добавлен `AnalyticsEvent` со списком событий;
- добавлен web dispatcher со stub fallback для тестов и не-web окружений;
- `web/index.html` получил безопасный Yandex Metrica loader без hardcoded counter id;
- `AuthController`, `FeedController`, `WalksController`, `PetConnectApp` и `FeedScreen` отправляют analytics events через application layer;
- `netlify.toml` и GitHub Actions build command передают analytics dart-defines;
- README и integration docs описывают настройку, события и privacy notes;
- добавлены тесты analytics service для disabled fallback, sanitized params и backend error event.

Privacy:

- email, raw user id, tokens, passwords, post/comment text and secrets не отправляются;
- текстовые поля передаются только как coarse length buckets;
- service фильтрует чувствительные ключи параметров перед отправкой.

## 33. Monitoring и Health Check через Netlify Function

Дата изменения: 19 июня 2026.

Цель: добавить production health endpoint и monitoring setup для Flutter Web на Netlify и Supabase backend.

Роль Codex: Monitoring Engineer и Netlify/Supabase Integration Specialist.

Перед изменениями прочитаны:

- `netlify.toml`;
- `README.md`;
- `backend_documentation.md`;
- `integration_documentation.md`;
- `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`;
- `docs/supabase_security.md`;
- `supabase/migrations/`;
- relevant `lib/core/config` and Supabase initialization files.

Что изменено:

- добавлен `netlify/functions/health.js`;
- `netlify.toml` получил Functions directory и redirect `/api/health -> /.netlify/functions/health`;
- README получил health endpoint URL и описание проверок;
- `integration_documentation.md` получил monitoring setup для UptimeRobot/Pingdom/Better Stack;
- `backend_documentation.md` описывает health endpoint как инфраструктурный слой поверх Supabase BaaS.

Health endpoint возвращает JSON со `status`, `timestamp`, `checks` и `version`. Проверяются доступность Netlify Function, наличие и валидность `SUPABASE_URL`, reachability Supabase Auth и REST endpoints, а optional `posts limit 1` query выполняется только с publishable key и не использует service role.

Security:

- env values не возвращаются в response;
- `SUPABASE_PUBLISHABLE_KEY` не логируется;
- service role key не используется;
- RLS/API-grant блокировка optional query считается `skipped`, а не ошибкой backend.
