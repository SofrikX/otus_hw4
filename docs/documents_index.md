# Documents Index — какие файлы учитывать Codex для HW5

Этот файл нужен, чтобы Codex и студент не путались в документации. Здесь перечислены актуальные документы проекта PetConnect в репозитории `otus_hw5`.

## Главный принцип

- `AGENTS.md` — инструкция для OpenAI Codex.
- `docs/current_homework_scope.md` — границы ДЗ 5 и Firebase mapping.
- `submission_checklist.md` — чек-лист для студента.
- `docs/` — документация проекта и источники требований.
- Старые документы из ДЗ 2 не копируются отдельными файлами, если они дублируют друг друга. Их полезная часть объединена в `docs/prompt_engineering_from_dz2.md` и `docs/ai_agent_rules.md`.

Оригинальное ДЗ 5 предлагает Supabase или self-hosted PostgreSQL. Для PetConnect активным backend-решением является Firebase, потому что Firebase уже указан в техническом задании проекта.

## Активные документы

| Файл | Источник | Для кого | Зачем нужен | Когда читать |
|---|---|---|---|---|
| `AGENTS.md` | HW5 + ДЗ 2 | Codex | Основные правила работы агента, Flutter + Firebase стек | В начале каждой Codex-сессии |
| `README.md` | HW5 | Проверяющий, студент | Описание проекта, запуск Flutter и Firebase emulator workflow | Перед сдачей и при запуске |
| `development_report.md` | HW5 | Проверяющий | Отчет о backend-интеграции через AI | После этапов разработки и перед сдачей |
| `prompts.md` | HW5 + ДЗ 2 | Проверяющий, студент, Codex | Журнал промптов и результатов | После каждой AI-задачи |
| `submission_checklist.md` | HW5 | Студент | Финальная проверка сдачи | Перед GitHub-публикацией |
| `docs/api_spec.md` | HW5 | Codex, студент | HTTP API endpoints, auth, CORS, error model и examples | При разработке Cloud Functions API и frontend integration |
| `docs/current_homework_scope.md` | HW5 | Codex, студент | 9 шагов ДЗ 5, Firebase mapping, критерии готовности | Перед изменениями scope, backend или интеграции |
| `docs/deployment.md` | HW5 | Codex, студент | Firebase CLI, Emulator Suite, deploy и правила работы с секретами | При настройке Firebase project, emulators и deploy |
| `docs/firebase_security.md` | HW5 | Codex, студент | Firestore Security Rules, замена Supabase RLS, разрешенные и запрещенные операции | При изменении `firestore.rules` и backend-доступов |
| `docs/firestore_schema.md` | HW5 | Codex, студент | Схема Cloud Firestore, поля, связи, примеры документов и индексы | При проектировании backend, repositories, rules и Cloud Functions |
| `docs/seed_data.md` | HW5 | Codex, студент | Seed-данные для локального Firestore Emulator | При проверке backend локально и подготовке демо-данных |
| `docs/technical_specification.md` | ДЗ 3 | Codex, студент | Техническое задание PetConnect с Firebase-архитектурой | При изменении функций, backend schema и архитектуры |
| `docs/project_description.md` | ДЗ 3 | Codex, студент | Идея продукта и бизнес-контекст | При продуктовых решениях |
| `docs/user_stories.md` | ДЗ 3 | Codex, студент | User stories и пользовательские сценарии | При разработке API, экранов и тестов |
| `docs/error_handling.md` | ДЗ 3 | Codex, студент | Негативные сценарии и UX ошибок | При error-state, Cloud Functions errors и тестах |
| `docs/ai_agent_rules.md` | HW5 + ДЗ 2 | Codex | Расширенные правила Flutter/Firebase разработки | При кодогенерации и ревью |
| `docs/ai_workflow.md` | HW5 | Codex, проверяющий | Процесс agent-based backend/frontend интеграции | При обновлении отчета |
| `docs/prompt_engineering_from_dz2.md` | ДЗ 2, адаптация | Codex, студент | RTCF-шаблоны и техники промптинга | При составлении задач Codex |
| `docs/codex_setup.md` | Предыдущий этап | Студент | Как работать с проектом через Codex | Перед началом работы |
| `docs/ui_concepts/ui_description.md` | ДЗ 3 | Codex, студент | Описание выбранной UI-концепции | При UI-задачах |
| `docs/ui_concepts/concept_2_bright_social.dart` | ДЗ 3 | Codex | Dart-прототип выбранного дизайна | При UI-задачах |
| `docs/ui_concepts/concept_2_bright_social.png` | ДЗ 3 | Codex/студент | Визуальный референс выбранного дизайна | При мультимодальной UI-проверке |

## Маршрутизация по типу задачи

### Project-level / HW5 planning

Читать:

- `AGENTS.md`;
- `docs/current_homework_scope.md`;
- `docs/documents_index.md`;
- `README.md`;
- `development_report.md`;
- `prompts.md`.

### Firebase backend

Читать:

- `docs/current_homework_scope.md`;
- `docs/technical_specification.md`;
- `docs/project_description.md`;
- `docs/user_stories.md`;
- `docs/error_handling.md`;
- `docs/ai_agent_rules.md`;
- `docs/api_spec.md`;
- `docs/deployment.md`;
- `docs/firebase_security.md`;
- `docs/firestore_schema.md`.
- `docs/seed_data.md`.

Когда задача касается Firebase CLI, emulators, deploy или секретов, обязательно читать `docs/deployment.md`.

Когда появятся файлы Firebase, также читать:

- `firebase.json`;
- `.firebaserc`;
- `firestore.rules`;
- `firestore.indexes.json`;
- `storage.rules`;
- `functions/`.

### Frontend integration

Читать:

- `AGENTS.md`;
- `docs/ai_agent_rules.md`;
- `docs/user_stories.md`;
- `lib/`;
- `test/`;
- relevant Firebase repository files when they exist.

### AI-process and reporting

Читать:

- `docs/ai_workflow.md`;
- `docs/prompt_engineering_from_dz2.md`;
- `prompts.md`;
- `development_report.md`.

## Что осталось из предыдущих ДЗ

Из ДЗ 4 сохраняются frontend MVP, UI-концепция, тесты и Codex workflow. Эти материалы теперь являются базой для HW5, а не финальной целью проекта.

Из ДЗ 2 сохраняются prompt engineering, RTCF-подход и правила AI-агента.

## Что удалено из рабочей документации

Из архива убраны отдельные файлы ДЗ 2, которые дублировали друг друга и создавали шум:

- `prompt_methodology.md`
- `prompt_templates.md`
- `testing.md`
- `rules.md`
- `hw_ai_rules.md`
- корневой `.cursorrules`

Их содержательная часть перенесена в:

- `AGENTS.md`
- `docs/ai_agent_rules.md`
- `docs/prompt_engineering_from_dz2.md`

Так Codex получает компактный и понятный контекст, а проверяющий видит, что материалы предыдущих ДЗ применены, но не скопированы без необходимости.
