# development_report.md — отчет о разработке PetConnect

## 1. Цель работы

Цель домашнего задания — разработать frontend MVP приложения PetConnect с использованием AI-агента, реализовать интерфейс по ранее выбранной UI-концепции, добавить тесты, проверить адаптивность и задокументировать процесс разработки.

## 2. Используемый AI-агент

В качестве AI-агента используется **OpenAI Codex**.

Для Codex создан файл `AGENTS.md`. Он является основным файлом инструкций агента в этом репозитории. Правила из ДЗ 2 были не просто скопированы, а адаптированы под Codex и распределены по двум файлам:

- `AGENTS.md` — краткие обязательные правила для агента;
- `docs/ai_agent_rules.md` — расширенные правила разработки.

Корневой `.cursorrules` не используется, потому что проект выполняется не в Cursor. Это снижает путаницу и делает workflow честным: инструмент разработки — OpenAI Codex.

## 3. Какие материалы прошлых ДЗ использованы

| Источник | Что взято | Как использовано в текущем ДЗ |
|---|---|---|
| ДЗ 2 | prompt engineering, RTCF, Role Prompting, Iterative Refinement, AI debugging | Объединено в `docs/prompt_engineering_from_dz2.md` и применяется в `prompts.md` |
| ДЗ 2 | правила AI-агента | Адаптированы в `AGENTS.md` и `docs/ai_agent_rules.md` |
| ДЗ 3 | ТЗ PetConnect | Используется как основа MVP в `docs/technical_specification.md` |
| ДЗ 3 | user stories | Используются для экранов и тестов |
| ДЗ 3 | error handling | Используется для error-state и негативных сценариев |
| ДЗ 3 | UI-концепция | Выбрана концепция №2: яркая социальная сеть |

Лишние дублирующиеся документы из ДЗ 2 не оставлены отдельными файлами. Их содержание консолидировано, чтобы Codex не тратил контекст на повторяющиеся материалы.

## 4. Выбранный стек

| Часть | Технология |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State management | Riverpod |
| Routing | go_router |
| UI | Material 3 |
| Architecture | feature-first + Clean Architecture principles |
| Tests | flutter_test, mocktail |
| MVP data source | mock-данные |

Firebase Auth, Firestore, Storage и FCM оставлены в целевой архитектуре, но в рамках текущего frontend MVP приложение работает локально без backend.

## 5. Выполнение шагов задания

### Шаг 1. Подготовка технического задания

Использовано ТЗ из ДЗ 3. MVP ограничен четырьмя frontend-функциями:

1. лента публикаций питомцев;
2. профиль питомца;
3. прогулки и присоединение к прогулке;
4. базовый экран чатов.

Scope зафиксирован в `docs/current_homework_scope.md`.

### Шаг 2. Инициализация проекта через AI-агента

Проект подготовлен как Flutter-приложение. В качестве AI-агента используется OpenAI Codex.

Настроены:

- `pubspec.yaml`;
- `analysis_options.yaml`;
- структура `lib/app`, `lib/core`, `lib/features`;
- структура тестов;
- web-заготовка;
- `AGENTS.md`;
- документация по AI workflow.

### Шаг 3. Базовая структура

Созданы основные feature-модули:

- `feed`;
- `pets`;
- `walks`;
- `chat`;
- `home`.

Роутинг реализован через `go_router`.

### Шаг 4. Компоненты интерфейса

Реализованы:

- карточка поста;
- лента;
- stories strip;
- карточка питомца;
- профиль питомца;
- карточка прогулки;
- экран прогулок;
- список чатов;
- общие состояния `EmptyState`, `ErrorState`, `AsyncContentView`.

UI опирается на Material 3 и выбранную концепцию яркой социальной сети.

### Шаг 5. Тестирование и отладка

Добавлены widget-тесты:

- `post_card_test.dart`;
- `feed_screen_test.dart`;
- `walks_screen_test.dart`;
- `pet_profile_screen_test.dart`.

Для отладки Codex должен использовать промпты из `prompts.md`:

- анализ ошибок `flutter analyze`;
- анализ ошибок `flutter test`;
- анализ скриншотов адаптивности.

### Шаг 6. Адаптивная верстка

Для адаптивности используется общий контейнер `ResponsiveCenter`, Material layout и проверка на desktop/mobile размерах. Проблемы адаптивности фиксируются через скриншоты и промпт мультимодальной отладки.

### Шаг 7. Оптимизация и рефакторинг

Код организован feature-first. Общие виджеты и утилиты вынесены в `core`. Повторяющиеся состояния вынесены в shared widgets.

### Шаг 8. Оформление результатов

Подготовлены:

- код проекта;
- README;
- `development_report.md`;
- `prompts.md`;
- `AGENTS.md`;
- тесты;
- `submission_checklist.md`.

## 6. Примеры промптов

Полный журнал находится в `prompts.md`. Основной формат промптов — RTCF:

```markdown
# Role
Ты Senior Flutter Developer и OpenAI Codex AI coding agent.

# Task
Проверь экран прогулок и тесты.

# Context
Прочитай AGENTS.md, docs/documents_index.md, docs/user_stories.md и файлы feature walks.

# Format
Верни найденные проблемы, изменения файлов и команды проверки.
```

## 7. Проблемы и решения

| Проблема | Решение через Codex |
|---|---|
| Нужно не смешивать Cursor и Codex | Вместо `.cursorrules` создан `AGENTS.md`, а старые правила адаптированы |
| Слишком много дублирующихся документов из ДЗ 2 | Документы консолидированы в `prompt_engineering_from_dz2.md` и `ai_agent_rules.md` |
| Нужно показать все источники требований | Создан `docs/documents_index.md` с явной маршрутизацией документов |
| Flutter-проект не имеет `package.json` | В README объяснено, что во Flutter используется `pubspec.yaml` |
| Требуется минимум 3 теста | Добавлены 4 widget-теста |

## 8. Команды проверки

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

## 9. Выводы

OpenAI Codex подходит для агентной разработки Flutter frontend MVP, если дать ему понятный входной контекст. Самыми полезными оказались:

- `AGENTS.md` как постоянные инструкции агента;
- `docs/documents_index.md` как карта документации;
- RTCF-промпты;
- итеративная разработка экран → состояния → тесты → рефакторинг;
- AI-assisted debugging по ошибкам терминала и скриншотам интерфейса.
