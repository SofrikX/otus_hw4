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
