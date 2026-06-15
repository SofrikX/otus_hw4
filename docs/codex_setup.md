# Codex Setup — порядок работы студента

## 1. Распаковать проект

```bash
unzip petconnect_ai_agent_homework_codex_clean.zip
cd petconnect_ai_agent_homework_codex_clean
```

## 2. Открыть проект в OpenAI Codex

Открыть именно корневую папку проекта, где лежит `AGENTS.md`.

## 3. Первый промпт для Codex

```markdown
# Role
Ты OpenAI Codex, AI coding agent для Flutter-проекта.

# Task
Подготовься к работе с проектом PetConnect.

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
- prompts.md
- development_report.md
- pubspec.yaml

# Requirements
1. Не меняй файлы на первом шаге.
2. Составь audit report.
3. Подтверди стек и функции MVP.
4. Скажи, какие проверки нужно запустить.
5. Укажи, какие документы являются активными источниками требований.

# Format
1. Что прочитано.
2. Что уже готово.
3. Что проверить.
4. Риски.
5. Следующий промпт.
```

## 4. Команды проверки

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

Если Flutter попросит platform files:

```bash
flutter create . --platforms=web,android,ios
```

## 5. Как фиксировать AI workflow

После каждой значимой задачи обновлять:

- `prompts.md` — промпт и результат;
- `development_report.md` — проблема, решение, вклад Codex;
- git commit — изменения по этапу.

## 6. Что показать проверяющему

- GitHub-репозиторий;
- README;
- development_report.md;
- prompts.md;
- тесты в `test/`;
- скриншоты Codex-задач;
- скриншот `flutter test`;
- скриншоты desktop и mobile UI.
