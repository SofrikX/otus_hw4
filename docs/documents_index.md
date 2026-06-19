# Documents Index - какие файлы учитывать Codex для HW5

Этот файл нужен, чтобы Codex и студент не путались в документации PetConnect.

## Главный принцип

- `AGENTS.md` - инструкция для OpenAI Codex.
- `docs/current_homework_scope.md` - границы ДЗ 5 и решение Firebase -> Supabase.
- `backend_documentation.md` - целевая backend architecture на Supabase.
- `submission_checklist.md` - чек-лист для студента.
- `docs/` - документация проекта и источники требований.

Оригинальное ДЗ 5 предлагает Supabase или self-hosted PostgreSQL. Ранняя Firebase-ветка была исследована из-за предыдущего ТЗ, но текущий backend choice для HW5 - Supabase Free Tier.

## Активные документы

| Файл | Источник | Для кого | Зачем нужен | Когда читать |
|---|---|---|---|---|
| `AGENTS.md` | HW5 + ДЗ 2 | Codex | Основные правила работы агента, Flutter + Supabase стек | В начале каждой Codex-сессии |
| `README.md` | HW5 | Проверяющий, студент | Описание проекта, Supabase decision, запуск Flutter | Перед сдачей и при запуске |
| `backend_documentation.md` | HW5 | Проверяющий, Codex | Supabase backend architecture, PostgreSQL schema, RLS, Storage, API operations | При backend-задачах |
| `development_report.md` | HW5 | Проверяющий | Отчет о backend-интеграции, Firebase-прототипе и переходе на Supabase | После этапов разработки и перед сдачей |
| `prompts.md` | HW5 + ДЗ 2 | Проверяющий, студент, Codex | Журнал промптов и результатов | После каждой AI-задачи |
| `submission_checklist.md` | HW5 | Студент | Финальная проверка сдачи | Перед GitHub-публикацией |
| `docs/supabase_setup.md` | HW5 | Студент, Codex | Создание Supabase project, env, migrations, Flutter run | При подключении Supabase |
| `docs/frontend_deployment.md` | HW5 | Проверяющий, студент, Codex | Production-развертывание Flutter Web на Netlify Free | При подготовке frontend production URL |
| `docs/logging.md` | HW6 | Проверяющий, студент, Codex | Structured logging, безопасные поля логов, Netlify/Supabase log inspection и AI prompt templates | При задачах logging, monitoring, debugging и AI log analysis |
| `docs/database_schema.md` | HW5 | Codex, студент | PostgreSQL schema, constraints, indexes, Storage buckets | При изменении SQL migrations |
| `docs/seed_data.md` | HW5 | Codex, студент, проверяющий | Supabase demo seed, Auth UUID replacement, smoke checks | При наполнении Supabase demo data |
| `docs/api_spec.md` | HW5 | Codex, студент | Supabase auto REST / Flutter client operations | При backend/frontend integration |
| `docs/supabase_security.md` | HW5 | Codex, студент | RLS, Storage policies, secrets, security review | При изменении policies |
| `docs/current_homework_scope.md` | HW5 | Codex, студент | 9 шагов ДЗ 5, Supabase scope, Firebase-to-Supabase mapping | Перед изменениями scope, backend или интеграции |
| `docs/ai_workflow.md` | HW5 | Codex, проверяющий | Процесс agent-based Supabase/frontend integration | При обновлении отчета |
| `docs/ai_agent_rules.md` | HW5 + ДЗ 2 | Codex | Расширенные правила Flutter/Supabase разработки | При кодогенерации и ревью |
| `docs/technical_specification.md` | ДЗ 3 | Codex, студент | Историческое ТЗ PetConnect, где backend был описан через Firebase | При анализе user stories и причин изменения backend |
| `docs/project_description.md` | ДЗ 3 | Codex, студент | Идея продукта и бизнес-контекст | При продуктовых решениях |
| `docs/user_stories.md` | ДЗ 3 | Codex, студент | User stories и пользовательские сценарии | При разработке API, экранов и тестов |
| `docs/error_handling.md` | ДЗ 3 | Codex, студент | Негативные сценарии и UX ошибок | При error-state, backend errors и тестах |
| `docs/prompt_engineering_from_dz2.md` | ДЗ 2, адаптация | Codex, студент | RTCF-шаблоны и техники промптинга | При составлении задач Codex |
| `docs/codex_setup.md` | Предыдущий этап | Студент | Как работать с проектом через Codex | Перед началом работы |
| `docs/ui_concepts/ui_description.md` | ДЗ 3 | Codex, студент | Описание выбранной UI-концепции | При UI-задачах |
| `docs/ui_concepts/concept_2_bright_social.dart` | ДЗ 3 | Codex | Dart-прототип выбранного дизайна | При UI-задачах |
| `docs/ui_concepts/concept_2_bright_social.png` | ДЗ 3 | Codex/студент | Визуальный референс выбранного дизайна | При мультимодальной UI-проверке |

## Исторические Firebase-документы

В репозитории могут оставаться документы и файлы Firebase-прототипа:

- `docs/deployment.md`;
- `docs/firebase_security.md`;
- `docs/firestore_schema.md`;
- `firebase.json`;
- `firestore.rules`;
- `storage.rules`;
- `functions/`.

Они описывают исследованную Firebase-ветку и не являются текущим production backend decision. Не удалять их механически без отдельной задачи: они сохраняют историю AI-assisted exploration и помогают понять предыдущую интеграцию.

## Маршрутизация по типу задачи

### Project-level / HW5 planning

Читать:

- `AGENTS.md`;
- `docs/current_homework_scope.md`;
- `docs/documents_index.md`;
- `README.md`;
- `backend_documentation.md`;
- `docs/supabase_setup.md`;
- `docs/frontend_deployment.md`;
- `docs/logging.md`;
- `docs/database_schema.md`;
- `docs/seed_data.md`;
- `docs/api_spec.md`;
- `docs/supabase_security.md`;
- `development_report.md`;
- `prompts.md`.

### Supabase backend

Читать:

- `backend_documentation.md`;
- `docs/supabase_setup.md`;
- `docs/database_schema.md`;
- `docs/seed_data.md`;
- `docs/api_spec.md`;
- `docs/supabase_security.md`;
- `docs/current_homework_scope.md`;
- `docs/technical_specification.md`;
- `docs/project_description.md`;
- `docs/user_stories.md`;
- `docs/error_handling.md`;
- `docs/ai_agent_rules.md`.

Supabase files:

- `supabase/migrations/`;
- `supabase/seed.sql`;
- future Supabase config files.

### Firebase prototype history

Читать только когда задача касается истории, сравнения, переноса логики или cleanup:

- `docs/api_spec.md`;
- `docs/deployment.md`;
- `docs/firebase_security.md`;
- `docs/firestore_schema.md`;
- `docs/seed_data.md`;
- `firebase.json`;
- `firestore.rules`;
- `storage.rules`;
- `functions/`.

### Frontend integration

Читать:

- `AGENTS.md`;
- `docs/ai_agent_rules.md`;
- `docs/user_stories.md`;
- `lib/`;
- `test/`;
- relevant repository files.

### AI-process and reporting

Читать:

- `docs/ai_workflow.md`;
- `docs/prompt_engineering_from_dz2.md`;
- `prompts.md`;
- `development_report.md`.

## Что осталось из предыдущих ДЗ

Из ДЗ 4 сохраняются frontend MVP, UI-концепция, тесты и Codex workflow. Эти материалы теперь являются базой для HW5, а не финальной целью проекта.

Из ДЗ 2 сохраняются prompt engineering, RTCF-подход и правила AI-агента.

Из Firebase-ветки HW5 сохраняется история исследования, но production backend choice изменен на Supabase.
