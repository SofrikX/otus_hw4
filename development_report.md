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
- `docs/current_homework_scope.md` содержит 9 шагов ДЗ 5 и Firebase mapping;
- `docs/firestore_schema.md` описывает коллекции Firestore, поля, связи, примеры документов, MVP data и индексы;
- `docs/ai_workflow.md` описывает Firestore schema, Security Rules, Cloud Functions API, frontend integration и AI-анализ логов;
- `docs/documents_index.md` маршрутизирует документы как HW5-материалы;
- `docs/ai_agent_rules.md` больше не запрещает Firebase, а задает правила безопасной интеграции;
- `README.md` больше не выглядит как HW4-only и описывает Firebase Emulator Suite.

Код приложения на этом этапе не менялся.
