# PetConnect — Flutter + Firebase with OpenAI Codex

PetConnect — приложение для владельцев домашних животных. Проект в репозитории `otus_hw5` готовится к ДЗ 5 «Развертывание Backend и интеграция с Frontend».

Предыдущий этап дал Flutter frontend MVP: лента питомцев, профили, прогулки и базовые чаты. Текущий этап переводит проект к backend-интеграции на Firebase.

В качестве AI-агента используется **OpenAI Codex**. Для Codex подготовлен корневой файл `AGENTS.md`; он заменяет IDE-специфичные правила и содержит инструкции, адаптированные из ДЗ 2 и обновленные под HW5.

## Стек

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

Оригинальное задание предлагает Supabase или self-hosted PostgreSQL. Для PetConnect эти технологии заменены на Firebase, потому что Firebase уже выбран в техническом задании проекта.

## Что уже есть во frontend MVP

1. **Лента публикаций питомцев**
   - список mock-постов;
   - лайки;
   - добавление комментария на уровне состояния;
   - состояния loading/error/empty/success.

2. **Питомцы и профиль питомца**
   - список питомцев;
   - карточки питомцев;
   - экран профиля;
   - error-state для неизвестного питомца.

3. **Прогулки**
   - список прогулок;
   - присоединение к прогулке;
   - обновление счетчика участников;
   - состояния loading/error/empty/success.

4. **Чаты**
   - базовый экран mock-диалогов как задел под будущую функцию сообщений.

5. **Firebase Auth integration**
   - вход по email/password;
   - регистрация по email/password;
   - выход из аккаунта;
   - Riverpod auth state provider;
   - protected routing через `go_router`;
   - локальный режим Firebase Auth Emulator без production secrets.

## Цель HW5

HW5 должен подготовить и интегрировать backend:

- Firestore schema для `users`, `pets`, `posts`, `comments`, `chats`, `messages`, `walks`;
- Firebase Storage paths для фото питомцев и изображений постов;
- Cloud Functions API минимум для 3 операций;
- Firestore и Storage Security Rules;
- Firebase Emulator Suite для локальной проверки;
- repository layer во Flutter, чтобы UI не обращался к Firebase напрямую.

## Структура проекта

```text
lib/
  app/                 # приложение, роутинг, тема
  core/                # shared widgets, data/utils, будущие Firebase providers
  features/
    auth/              # Firebase Auth repository, controller, login/register UI
    feed/              # лента
    pets/              # питомцы и профиль
    walks/             # прогулки
    chat/              # чаты
    home/              # оболочка навигации
test/                  # Flutter widget/unit-тесты
docs/                  # активная документация проекта
AGENTS.md              # инструкции для OpenAI Codex
prompts.md             # журнал промптов
development_report.md  # отчет о разработке
submission_checklist.md# чек-лист студента перед сдачей
```

После добавления Firebase backend ожидаются также:

```text
firebase.json
.firebaserc
firestore.rules
firestore.indexes.json
storage.rules
functions/
```

## Документация

Главный навигатор по документации: `docs/documents_index.md`.

Самые важные файлы:

- `AGENTS.md` — правила для Codex;
- `docs/current_homework_scope.md` — scope HW5 и Firebase mapping;
- `docs/technical_specification.md` — ТЗ PetConnect;
- `docs/user_stories.md` — пользовательские сценарии;
- `docs/ai_workflow.md` — процесс работы через AI-агента;
- `prompts.md` — журнал промптов;
- `development_report.md` — отчет для сдачи.

## Как запустить Flutter

### 1. Установить зависимости

```bash
flutter pub get
```

### 2. При необходимости создать platform files

Если локальный Flutter попросит platform files:

```bash
flutter create . --platforms=web,android,ios
```

### 3. Запустить Flutter-проверки

```bash
dart format .
flutter analyze
flutter test
```

### 4. Запустить приложение

Проверить доступные устройства Flutter:

```bash
flutter devices
```

Основной запуск для Flutter Web:

```bash
flutter run -d chrome
```

Для локальной проверки Firebase Auth через Emulator Suite:

```bash
firebase emulators:start --only auth --project demo-petconnect
flutter run -d chrome \
  --dart-define=USE_FIREBASE_AUTH_EMULATOR=true \
  --dart-define=FIREBASE_PROJECT_ID=demo-petconnect
```

В emulator-режиме приложение использует demo Firebase options. Реальные
Firebase ключи и service account files в репозиторий не добавляются.

Fallback для локальной desktop-проверки на macOS:

```bash
flutter run -d macos
```

## Firebase Emulator Suite

После добавления Firebase config и functions локальная проверка backend должна выполняться через Emulator Suite:

```bash
firebase emulators:start
```

Для автоматических backend-проверок:

```bash
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
```

Cloud Functions deploy в production может потребовать Firebase Blaze plan. Для ДЗ основной проверяемый сценарий должен работать локально через emulators.

### Seed-данные для Firestore Emulator

После запуска emulators можно наполнить локальный Firestore тестовыми данными:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

Скрипт `scripts/seed_firestore.js` создает пользователей, питомцев, посты, комментарии, прогулки, чат и сообщения. Он не использует production credentials и не запускается без `FIRESTORE_EMULATOR_HOST`.

Подробнее: `docs/seed_data.md`.

## Тесты

В проекте уже есть автоматические Flutter-тесты для ключевых функций:

- `test/features/feed/post_card_test.dart`
- `test/features/feed/feed_screen_test.dart`
- `test/features/feed/feed_controller_test.dart`
- `test/features/auth/auth_controller_test.dart`
- `test/features/walks/walks_screen_test.dart`
- `test/features/pets/pet_profile_screen_test.dart`
- `test/features/chat/chat_screen_test.dart`

Запуск:

```bash
flutter test
```

Для HW5 нужно сохранить эти тесты и добавить backend/emulator tests, когда появятся Cloud Functions и Security Rules.

## Использование OpenAI Codex

Codex применяется для:

- анализа ТЗ и user stories;
- адаптации оригинального задания Supabase/PostgreSQL на Firebase;
- проектирования Firestore schema;
- генерации Security Rules;
- генерации Cloud Functions API;
- интеграции frontend-backend через repositories;
- анализа логов Flutter, npm и Firebase emulators;
- подготовки документации.

Для работы с Codex см. `docs/codex_setup.md`, `AGENTS.md` и `prompts.md`.
