# AI Workflow — разработка PetConnect через OpenAI Codex

## Используемый AI-агент

OpenAI Codex.

## Основные файлы agent workflow

| Файл | Назначение |
|---|---|
| `AGENTS.md` | Постоянные инструкции для Codex |
| `docs/documents_index.md` | Навигация по документации |
| `docs/ai_agent_rules.md` | Расширенные правила разработки |
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
Codex анализирует задачу
  ↓
Codex предлагает план
  ↓
Codex меняет файлы
  ↓
Запускаются проверки
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
- `docs/user_stories.md`.

Результат: подтвержден scope MVP и стек.

### 2. Инициализация проекта

Codex проверяет:

- `pubspec.yaml`;
- структуру `lib/`;
- структуру `test/`;
- web-заготовку.

Результат: проект готов к локальному запуску.

### 3. Разработка экранов

Codex работает по feature-модулям:

- feed;
- pets;
- walks;
- chat.

Для каждого экрана проверяются:

- базовая функциональность;
- состояния loading/error/empty/success;
- адаптивность;
- тесты.

### 4. Отладка

Codex получает ошибки из терминала и исправляет их итеративно.

### 5. Мультимодальная проверка

Студент передает Codex скриншоты desktop/mobile. Codex анализирует визуальные проблемы и предлагает исправления.

### 6. Финальный рефакторинг

Codex проверяет архитектуру, тесты и документацию перед сдачей.

## Команды проверки

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```
