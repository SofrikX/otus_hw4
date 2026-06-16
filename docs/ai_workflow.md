# AI Workflow - PetConnect HW5 через OpenAI Codex

## Используемый AI-агент

OpenAI Codex.

Codex используется как Technical Writer, Flutter Architect, Supabase Backend Architect, Test Engineer и AI Workflow Engineer.

## Основные файлы agent workflow

| Файл | Назначение |
|---|---|
| `AGENTS.md` | Постоянные инструкции для Codex |
| `docs/documents_index.md` | Навигация по документации HW5 |
| `docs/current_homework_scope.md` | Scope ДЗ 5 и Supabase decision |
| `docs/ai_agent_rules.md` | Расширенные правила разработки |
| `docs/technical_specification.md` | Историческое ТЗ PetConnect, где backend был описан через Firebase |
| `docs/user_stories.md` | Пользовательские сценарии для frontend/backend операций |
| `docs/error_handling.md` | Негативные сценарии и сообщения ошибок |
| `docs/prompt_engineering_from_dz2.md` | Техники и шаблоны промптов из ДЗ 2 |
| `prompts.md` | Журнал фактически используемых промптов |
| `development_report.md` | Отчет о процессе разработки |
| `backend_documentation.md` | Архитектура Supabase backend |
| `submission_checklist.md` | Чек-лист студента перед сдачей |

## Процесс

```text
Студент
  ↓
OpenAI Codex читает AGENTS.md
  ↓
Codex выбирает документы через docs/documents_index.md
  ↓
Codex анализирует HW5 scope, user stories и предыдущую Firebase-ветку
  ↓
Codex фиксирует Architecture Decision: Firebase to Supabase
  ↓
Codex проектирует Supabase backend: PostgreSQL, RLS, Storage, API
  ↓
Codex меняет документацию или repository layer без изменения UI
  ↓
Запускаются Flutter checks и Supabase validation checks, когда migrations добавлены
  ↓
Codex анализирует ошибки и фиксирует решения
  ↓
Результат фиксируется в prompts.md и development_report.md
```

## Architecture Decision: Firebase to Supabase

Первичная Firebase-ветка была логичной для прошлого ТЗ, но не стала финальным production-решением ДЗ 5. Причина - Firebase Cloud Functions production deploy может требовать Blaze/pay-as-you-go plan.

Supabase выбран как текущий backend, потому что:

- он прямо предложен исходным заданием;
- Free Tier подходит для учебного deployment;
- PostgreSQL schema дает явную структуру данных;
- RLS заменяет Firestore Rules;
- PostgREST auto REST API заменяет Cloud Functions API для MVP;
- Supabase Storage заменяет Firebase Storage;
- Flutter SDK позволяет сохранить существующую архитектуру с repositories/controllers.

## Этапы работы

### 1. Аудит требований

Codex читает:

- `AGENTS.md`;
- `docs/documents_index.md`;
- `docs/current_homework_scope.md`;
- `docs/technical_specification.md`;
- `docs/project_description.md`;
- `docs/user_stories.md`;
- `docs/error_handling.md`.

Результат: подтверждается, какие части старого Firebase ТЗ являются историей, а какие user stories остаются обязательными для Supabase backend.

### 2. PostgreSQL schema design

Codex проектирует:

- таблицы `profiles`, `pets`, `posts`, `comments`, `post_likes`, `walks`, `walk_participants`, `chats`, `chat_participants`, `messages`;
- primary keys, foreign keys и unique constraints;
- timestamps и soft delete поля;
- связи между пользователями, питомцами, постами, прогулками и чатами;
- индексы для ленты, питомцев пользователя, прогулок и чатов.

### 3. Row Level Security

Codex готовит RLS model:

- пользователь обновляет только свой `profiles` row;
- владелец управляет своими `pets`;
- автор управляет своими `posts`;
- пользователь управляет только своим row в `post_likes`;
- пользователь присоединяет к прогулке только себя;
- участники читают только свои `chats` и `messages`.

### 4. Supabase Storage

Codex описывает:

- buckets `avatars`, `pet-photos`, `post-images`;
- policies чтения и записи;
- связь Storage paths с владельцем файла;
- запрет service role key в Flutter-клиенте и git.

### 5. API operations

Codex проектирует минимум 3 backend/API операции через Supabase client или auto REST:

- создание питомца;
- создание поста;
- лайк/анлайк поста;
- загрузка ленты;
- загрузка прогулок;
- присоединение к прогулке.

Если для counters нужна атомарность, Codex предлагает PostgreSQL RPC/trigger как отдельное расширение, а не обязательный Cloud Functions слой.

### 6. Frontend integration

Codex сохраняет текущий UI и бизнес-логику:

- domain содержит repository interfaces;
- data содержит Supabase и mock implementations;
- application содержит Riverpod providers/controllers;
- presentation не знает о Supabase SDK;
- mock data сохраняется для тестов и fallback.

### 7. AI-анализ ошибок

Codex анализирует:

- ошибки `flutter analyze`;
- ошибки `flutter test`;
- ошибки Supabase SQL/RLS policies;
- ошибки auth/session в Flutter;
- ошибки permission denied из RLS;
- несовпадение frontend DTO и SQL schema.

Для каждой ошибки фиксируются симптом, причина, исправление и результат проверки.

### 8. Проверка

Flutter:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

Supabase после добавления CLI/migrations:

```bash
supabase db lint
supabase db reset
```

Если Supabase CLI еще не подключен, SQL/RLS проверяется через Supabase dashboard SQL editor и ручные сценарии.

### 9. Документирование результата

Codex обновляет:

- `prompts.md` - фактические prompts и результаты;
- `development_report.md` - архитектура, проблемы, решения, проверки;
- `README.md` - запуск Flutter и Supabase decision;
- `backend_documentation.md` - PostgreSQL/RLS/Storage/API;
- `docs/current_homework_scope.md` - актуальные границы HW5;
- `docs/documents_index.md` - активные документы HW5.

## Правило про Firebase

Firebase больше не описывается как выбранный production backend для текущего ДЗ. Он сохраняется в документации как исследованный вариант и источник уже выполненного анализа, от которого отказались из-за ограничения Cloud Functions Blaze/pay-as-you-go.
