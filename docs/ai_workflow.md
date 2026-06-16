# AI Workflow — PetConnect HW5 через OpenAI Codex

## Используемый AI-агент

OpenAI Codex.

Codex используется как Technical Writer, Flutter Architect, Firebase Backend Engineer, Test Engineer и AI Workflow Engineer.

## Основные файлы agent workflow

| Файл | Назначение |
|---|---|
| `AGENTS.md` | Постоянные инструкции для Codex |
| `docs/documents_index.md` | Навигация по документации HW5 |
| `docs/current_homework_scope.md` | Scope ДЗ 5 и Firebase mapping |
| `docs/ai_agent_rules.md` | Расширенные правила разработки |
| `docs/technical_specification.md` | Исходное ТЗ PetConnect с Firebase-архитектурой |
| `docs/user_stories.md` | Пользовательские сценарии для frontend/backend операций |
| `docs/error_handling.md` | Негативные сценарии и сообщения ошибок |
| `docs/prompt_engineering_from_dz2.md` | Техники и шаблоны промптов из ДЗ 2 |
| `prompts.md` | Журнал фактически используемых промптов |
| `development_report.md` | Отчет о процессе разработки |
| `submission_checklist.md` | Чек-лист студента перед сдачей |

## Процесс

```text
Студент
  ↓
OpenAI Codex читает AGENTS.md
  ↓
Codex выбирает документы через docs/documents_index.md
  ↓
Codex анализирует HW5 scope и ТЗ PetConnect
  ↓
Codex проектирует Firebase backend
  ↓
Codex предлагает план изменений
  ↓
Codex меняет документацию, Firebase config, backend или Flutter layer
  ↓
Запускаются Flutter, Functions и emulator-проверки
  ↓
Codex анализирует логи и исправляет ошибки
  ↓
Результат фиксируется в prompts.md и development_report.md
```

## Этапы работы

### 1. Аудит требований

Codex читает:

- `AGENTS.md`;
- `docs/documents_index.md`;
- `docs/current_homework_scope.md`;
- `docs/technical_specification.md`;
- `docs/user_stories.md`;
- `docs/error_handling.md`.

Результат: подтверждено, что HW5 использует Firebase вместо Supabase/PostgreSQL, потому что Firebase уже выбран в ТЗ PetConnect.

### 2. Проектирование Firestore schema

Codex проектирует:

- коллекции `users`, `pets`, `posts`, `comments`, `chats`, `messages`, `walks`;
- связи между владельцами, питомцами, постами, чатами и прогулками;
- поля документов и типы данных;
- индексы для ленты, чатов и прогулок;
- ограничения, которые должны быть проверены rules или Cloud Functions.

Результат: схема Firestore согласована с user stories и frontend-моделями.

### 3. Проектирование Firebase Storage

Codex описывает:

- пути для аватаров пользователей;
- пути для фото питомцев;
- пути для изображений постов;
- ограничения по MIME type и размеру файла;
- связь Storage paths с Firestore documents.

Результат: Storage используется только для пользовательских изображений, без секретов и внешних API.

### 4. Генерация Security Rules

Codex готовит Firestore и Storage rules:

- неавторизованные пользователи не получают доступ к приватным данным;
- пользователь редактирует только свои `users/{uid}` и `pets`;
- посты создаются авторизованным автором;
- чаты и сообщения видны только участникам;
- защищенные counters и join/like операции не изменяются напрямую клиентом;
- Storage upload разрешен только владельцу соответствующего пути.

Результат: правила безопасности становятся частью backend-реализации, а не устным допущением.

### 5. Генерация Cloud Functions API

Codex проектирует и реализует минимум 3 backend/API операции, например:

- `postsToggleLike`;
- `commentsCreate`;
- `walksJoin`;
- `messagesSend`;
- `postsCreate`.

Для операций, где важны counters, validation или права доступа, использовать Cloud Functions и Firestore transactions/batches.

### 6. Интеграция frontend-backend

Codex переводит frontend на repository layer:

- domain содержит repository interfaces;
- data содержит Firebase и mock implementations;
- application содержит Riverpod providers/controllers;
- presentation не знает о Firebase SDK;
- mock data сохраняется для тестов и локального fallback.

Результат: UI остается тестируемым, а backend можно подменять в ProviderScope.

### 7. AI-анализ логов

Codex анализирует:

- ошибки `flutter analyze`;
- ошибки `flutter test`;
- ошибки TypeScript/ESLint/Jest в `functions`;
- ошибки `firebase emulators:start`;
- ошибки `firebase emulators:exec`;
- ошибки Security Rules tests;
- runtime-логи Cloud Functions emulator.

Для каждой ошибки фиксируются симптом, причина, исправление и результат проверки.

### 8. Локальная проверка

Основные команды:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
firebase emulators:start
flutter run -d chrome
```

Если production deploy Cloud Functions требует Firebase Blaze plan, локальный emulator-сценарий остается основным способом проверки ДЗ.

### 9. Документирование результата

Codex обновляет:

- `prompts.md` — фактические prompts и результаты;
- `development_report.md` — архитектура, проблемы, решения, проверки;
- `README.md` — запуск Flutter и Firebase emulators;
- `docs/current_homework_scope.md` — актуальные границы HW5;
- `docs/documents_index.md` — активные документы HW5.

## Правило про Supabase

Supabase/PostgreSQL упоминаются только как исходные технологии из оригинального задания. Для PetConnect они заменены на Firebase, потому что это согласовано с техническим заданием проекта.
