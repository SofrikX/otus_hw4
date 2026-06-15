# prompts.md — журнал промптов для OpenAI Codex

Файл показывает активное использование AI-агента в процессе разработки. Промпты построены на техниках из ДЗ 2: Role Prompting, RTCF, Iterative Refinement и AI-assisted debugging.

## Prompt 00 — первичный аудит проекта и документов

```markdown
# Role
Ты OpenAI Codex, AI coding agent для Flutter-проекта.

# Task
Подготовься к работе с проектом PetConnect и проведи первичный аудит.

# Context
Прочитай:
- AGENTS.md
- docs/documents_index.md
- docs/current_homework_scope.md
- docs/technical_specification.md
- docs/project_description.md
- docs/user_stories.md
- docs/error_handling.md
- docs/ai_agent_rules.md
- docs/ai_workflow.md
- docs/prompt_engineering_from_dz2.md
- docs/ui_concepts/ui_description.md
- README.md
- development_report.md
- pubspec.yaml

# Requirements
1. Не меняй файлы на первом шаге.
2. Подтверди стек проекта.
3. Подтверди минимум 3 функции MVP.
4. Проверь, что нет привязки к Cursor как основному инструменту.
5. Составь список команд проверки.

# Format
1. Что прочитано.
2. Что уже готово.
3. Что нужно проверить локально.
4. Риски.
5. Следующая задача для Codex.
```

Ожидаемый результат: Codex подтверждает, что проект использует Flutter, Dart, Riverpod, go_router, Material 3, mock-данные, а основным агентом является OpenAI Codex.

## Prompt 01 — проверка запуска проекта

```markdown
# Role
Ты Flutter Developer и OpenAI Codex AI coding agent.

# Task
Проверь, что проект PetConnect запускается локально.

# Context
Используй AGENTS.md и docs/documents_index.md. MVP не должен подключать Firebase.

# Requirements
Выполни или попроси выполнить:
- flutter pub get
- dart format .
- flutter analyze
- flutter test

Если не хватает platform files, предложи:
- flutter create . --platforms=web,android,ios

# Format
1. Результаты команд.
2. Ошибки, если есть.
3. Исправления.
4. Обновления в development_report.md.
```

Результат:

- `flutter pub get` установил зависимости проекта без добавления Firebase.
- `dart format .` выполнил механическое форматирование 10 Dart-файлов.
- `flutter analyze` завершился без замечаний: `No issues found!`.
- `flutter test` подтвердил прохождение 4 widget-тестов: `All tests passed!`.
- На первом этапе `flutter run -d chrome` не запустился, потому что Flutter не видел устройство `chrome`; `flutter devices` показывал только `macOS`.
- Позже проблема была исправлена вручную на уровне окружения: после установки Google Chrome Flutter начал видеть `Chrome (web)`.
- Добавлен `.gitignore`, чтобы не включать в репозиторий `.dart_tool/`, `build/` и служебные Flutter-файлы.
- `development_report.md` обновлен результатами локальной проверки.

## Prompt 02 — ревью архитектуры

```markdown
# Role
Ты Senior Flutter Architect.

# Task
Проведи архитектурное ревью структуры lib/ и test/.

# Context
Прочитай:
- AGENTS.md
- docs/ai_agent_rules.md
- docs/current_homework_scope.md
- lib/
- test/

# Requirements
1. Проверь feature-first структуру.
2. Проверь разделение domain/application/presentation.
3. Проверь, что UI не обращается к backend.
4. Проверь, что mock data лежит в core/data.
5. Не переписывай проект полностью.

# Format
Audit report → проблемы → точечные исправления → команды проверки.
```

## Prompt 03 — проверка ленты

```markdown
# Role
Ты Senior Flutter Developer.

# Task
Проверь feature feed и улучши ее при необходимости.

# Context
Прочитай:
- AGENTS.md
- docs/user_stories.md
- docs/ui_concepts/ui_description.md
- lib/features/feed/
- test/features/feed/

# Requirements
1. Лента должна показывать mock-посты.
2. Лайк должен менять состояние.
3. Комментарий должен добавляться на уровне mock-состояния.
4. Должны быть loading/error/empty/success состояния.
5. Тесты должны проходить.

# Format
Файлы → изменения → тесты → команды проверки.
```

## Prompt 04 — проверка профиля питомца

```markdown
# Role
Ты Flutter Developer.

# Task
Проверь feature pets.

# Context
Прочитай:
- docs/user_stories.md
- docs/error_handling.md
- lib/features/pets/
- test/features/pets/

# Requirements
1. Список питомцев отображается.
2. Профиль питомца открывается через go_router.
3. Для неизвестного id есть error-state.
4. Тесты проходят.

# Format
Проблемы → исправления → результат тестов.
```

## Prompt 05 — проверка прогулок

```markdown
# Role
Ты Flutter Developer и Test Engineer.

# Task
Проверь feature walks.

# Context
Прочитай:
- docs/user_stories.md
- lib/features/walks/
- test/features/walks/

# Requirements
1. Список прогулок отображается.
2. Кнопка присоединения работает.
3. Счетчик участников обновляется.
4. Есть тест позитивного сценария.

# Format
Файлы → изменения → тесты → результат.
```

## Prompt 06 — генерация и проверка тестов

```markdown
# Role
Ты Flutter Test Engineer.

# Task
Проверь, что в проекте есть минимум 3 автоматических теста и они покрывают ключевые функции.

# Context
Прочитай:
- AGENTS.md
- test/
- docs/current_homework_scope.md

# Requirements
1. Не удаляй тесты ради прохождения.
2. Добавь тесты, если покрытие слабое.
3. Запусти flutter test.
4. Обнови development_report.md.

# Format
Список тестов → покрытые сценарии → результат flutter test.
```

## Prompt 07 — анализ ошибки из консоли

```markdown
# Role
Ты Flutter Debugger.

# Task
Проанализируй ошибку из терминала и предложи минимальное исправление.

# Context
Команда:
<paste_command>

Ошибка:
<paste_error>

# Requirements
1. Найди причину.
2. Исправь только связанные файлы.
3. Повтори проверку.
4. Зафиксируй кейс в development_report.md.

# Format
Причина → исправление → файлы → повторная команда.
```

## Prompt 08 — мультимодальная проверка скриншота

```markdown
# Role
Ты Flutter UI/UX Debugger.

# Task
Проанализируй приложенный скриншот PetConnect.

# Context
UI-концепция: яркая социальная сеть.
Приложение должно корректно выглядеть на desktop и mobile.

# Requirements
1. Найди проблемы верстки.
2. Укажи вероятную причину.
3. Предложи точечные исправления.
4. После подтверждения внеси изменения.
5. Обнови development_report.md.

# Format
Проблема → причина → исправление → проверка.
```

## Prompt 09 — финальный рефакторинг

```markdown
# Role
Ты Senior Flutter Architect.

# Task
Проведи финальный рефакторинг проекта перед сдачей.

# Context
Прочитай:
- AGENTS.md
- docs/documents_index.md
- lib/
- test/
- README.md
- development_report.md

# Requirements
1. Улучши читаемость кода.
2. Не меняй scope MVP.
3. Не подключай Firebase.
4. Запусти dart format, flutter analyze, flutter test.
5. Обнови документацию, если изменения существенные.

# Format
Изменения → команды проверки → готовность к сдаче.
```

## Prompt 10 — документирование кейса Flutter Web

```markdown
# Role
Ты Flutter Debugger, QA Engineer и Technical Writer.

# Task
Зафиксируй уже исправленную проблему запуска Flutter Web в проекте PetConnect и органично добавь ее в AI-agent workflow.

# Context
Ранее `flutter run -d chrome` не запускался, потому что `flutter devices` показывал только `macOS`, а Chrome не отображался как Flutter web device. Проблема была исправлена вручную на уровне окружения: после установки Google Chrome Flutter начал видеть устройство Chrome.

# Requirements
1. Не менять бизнес-логику Flutter-приложения.
2. Не переписывать UI-компоненты.
3. Проверить, что это проблема окружения, а не кода приложения.
4. Добавить кейс в `development_report.md`.
5. Добавить запись в `prompts.md`.
6. При необходимости добавить troubleshooting в `README.md`.
7. Честно указать, что исправление окружения было выполнено вручную.

# Commands
- flutter devices
- flutter config --enable-web
- flutter run -d chrome
- flutter run -d macos

# Format
Что проверено → что изменено → diff → команды валидации.
```

Результат:

- Codex прочитал обязательные документы проекта и не менял бизнес-логику Flutter-приложения.
- `flutter devices` после ручной установки Google Chrome показывает `Chrome (web)` и `macOS`.
- `flutter config --list` показал, что `enable-web` явно не установлен, но Chrome уже доступен как web device; команда `flutter config --enable-web` оставлена в документации как шаг восстановления, если web-поддержка отключена.
- В `development_report.md` добавлен кейс "Chrome не отображался как Flutter web device".
- В `README.md` добавлены инструкции запуска, troubleshooting для Flutter Web и fallback `flutter run -d macos`.
