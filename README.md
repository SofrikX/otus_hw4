# PetConnect — Flutter Frontend MVP with OpenAI Codex

PetConnect — frontend MVP приложения для владельцев домашних животных. Проект выполнен для ДЗ «Разработка Frontend-приложения с AI-агентом».

В качестве AI-агента используется **OpenAI Codex**. Для Codex подготовлен корневой файл `AGENTS.md`; он заменяет IDE-специфичные правила и содержит инструкции, адаптированные из ДЗ 2.

## Стек

| Часть | Технология |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State management | Riverpod |
| Routing | go_router |
| UI | Material 3 |
| Architecture | feature-first + Clean Architecture principles |
| Tests | flutter_test, mocktail |
| Data source | mock-данные |

> В задании упоминается `package.json`, но для Flutter-проекта используется `pubspec.yaml`.

## Что реализовано

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

## Структура проекта

```text
lib/
  app/                 # приложение, роутинг, тема
  core/                # shared widgets, mock data, utils
  features/
    feed/              # лента
    pets/              # питомцы и профиль
    walks/             # прогулки
    chat/              # чаты
    home/              # оболочка навигации
test/                  # widget-тесты
docs/                  # активная документация проекта
AGENTS.md              # инструкции для OpenAI Codex
prompts.md             # журнал промптов
development_report.md  # отчет о разработке
submission_checklist.md# чек-лист студента перед сдачей
```

## Документация

Главный навигатор по документации: `docs/documents_index.md`.

Самые важные файлы:

- `AGENTS.md` — правила для Codex;
- `docs/current_homework_scope.md` — scope текущего ДЗ;
- `docs/technical_specification.md` — ТЗ из ДЗ 3;
- `docs/user_stories.md` — пользовательские сценарии;
- `docs/prompt_engineering_from_dz2.md` — адаптированные техники из ДЗ 2;
- `docs/ai_workflow.md` — процесс работы через AI-агента;
- `prompts.md` — журнал промптов;
- `development_report.md` — отчет для сдачи.

## Как запустить

### 1. Установить зависимости

```bash
flutter pub get
```

### 2. При необходимости создать platform files

Если локальный Flutter попросит platform files:

```bash
flutter create . --platforms=web,android,ios
```

### 3. Запустить проверки

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

Если Chrome не отображается в `flutter devices`, проверьте, что Google Chrome установлен в системе, и при необходимости включите web-поддержку Flutter:

```bash
flutter config --enable-web
flutter devices
```

Fallback для локальной desktop-проверки на macOS:

```bash
flutter run -d macos
```

### Troubleshooting: Flutter Web и Chrome

В проекте был зафиксирован кейс окружения: `flutter run -d chrome` не запускался, потому что `flutter devices` показывал только `macOS`, а `Chrome (web)` отсутствовал. Причина была не в коде PetConnect, а в локальном окружении разработки: Google Chrome не был установлен или не определялся Flutter.

Исправление было выполнено вручную на уровне окружения: после установки Google Chrome Flutter начал видеть устройство `Chrome (web)`. Codex использовался для анализа симптомов, проверки команд и документирования результата.

## Тесты

В проекте есть widget-тесты для ключевых функций:

- `test/features/feed/post_card_test.dart`
- `test/features/feed/feed_screen_test.dart`
- `test/features/walks/walks_screen_test.dart`
- `test/features/pets/pet_profile_screen_test.dart`

Запуск:

```bash
flutter test
```

## Использование OpenAI Codex

Codex применялся для:

- анализа ТЗ и user stories;
- адаптации правил из ДЗ 2 в `AGENTS.md`;
- проектирования Flutter-структуры;
- генерации компонентов;
- генерации mock-данных;
- создания тестов;
- анализа ошибок консоли;
- анализа скриншотов интерфейса;
- рефакторинга;
- подготовки документации.

Для работы с Codex см. `docs/codex_setup.md` и `prompts.md`.
