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
- `feed_controller_test.dart`;
- `walks_screen_test.dart`;
- `pet_profile_screen_test.dart`.

Тест `pet_profile_screen_test.dart` покрывает три сценария feature pets: отображение mock-списка питомцев, открытие профиля через `go_router` и error-state для неизвестного id.

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
| Требуется минимум 3 теста | Добавлены widget-тесты ключевых экранов и unit-тесты состояния feed |
| Flutter SDK cache недоступен из sandbox Codex | Команды `flutter pub get`, `dart format .`, `flutter analyze` и `flutter test` повторены с разрешением на доступ к SDK |
| После `flutter pub get` появились сгенерированные каталоги | Добавлен `.gitignore` для `.dart_tool/`, `build/` и служебных Flutter-файлов |
| Chrome не отображался как Flutter web device | Codex помог отделить проблему окружения от кода приложения; исправление выполнено вручную установкой Google Chrome |
| `git push` завершился ошибкой `No git remote configured for push` | Codex помог проверить git-конфигурацию и определить, что для публикации нужен remote `origin` на GitHub |
| Комментарий в ленте менял только счетчик | `PetPost` получил список mock-комментариев, `FeedController.addComment` добавляет текст в локальное mock-состояние, UI показывает последние комментарии |
| Bottom sheet комментария мог пересобраться с disposed `TextEditingController` | Форма комментария вынесена в отдельный stateful widget, а состояние ленты обновляется после закрытия bottom sheet |

### Кейс доработки: feed feature

При проверке feature feed Codex сверил реализацию с user stories US-5 и US-6: лента должна показывать публикации, поддерживать лайки и комментарии, а также обрабатывать loading, error, empty и success состояния.

Изменения:

- посты используют mock-данные из `lib/core/data/mock_data.dart`;
- лайк обновляет `isLiked` и `likesCount` в `FeedController`;
- комментарий добавляется в локальное mock-состояние поста и отображается в карточке;
- `FeedScreen` покрыт тестами success/loading/empty/error;
- добавлены проверки изменения лайка и добавления комментария через UI;
- добавлен unit-тест контроллера для проверки мутаций mock-состояния.

Во время тестирования был найден UI lifecycle-дефект: отправка комментария могла обновить ленту до полного закрытия bottom sheet, из-за чего `TextEditingController` использовался после `dispose`. Решение: форма комментария вынесена в отдельный `StatefulWidget`, bottom sheet возвращает введенный текст через `Navigator.pop`, а изменение состояния выполняется после закрытия sheet.

Проверка:

```bash
flutter test test/features/feed
```

Результат: 9 feed-тестов пройдены.

### Кейс проверки: pets feature

При проверке feature pets Codex сверил реализацию с user stories профиля питомца и правилами error-state из `docs/error_handling.md`.

Результат проверки:

- `PetsScreen` показывает mock-список питомцев из `lib/core/data/mock_data.dart`;
- `PetCard` открывает профиль через `go_router` по маршруту `/pets/:petId`;
- `PetProfileScreen` показывает дружелюбное состояние "Питомец не найден" для неизвестного id;
- тесты pets расширены проверками списка, навигации и негативного сценария.

Проверка:

```bash
flutter test test/features/pets
```

Результат: 3 pets-теста пройдены.

### Кейс отладки: Chrome не отображался как Flutter web device

Симптом:

- команда `flutter run -d chrome` не запускалась;
- команда `flutter devices` показывала только `macOS`;
- устройство `Chrome (web)` не отображалось.

Диагностика показала, что проблема связана с локальным окружением, а не с кодом приложения:

- в проекте есть web-заготовка `web/index.html`;
- Flutter-приложение и тесты проверяются отдельно командами `flutter analyze` и `flutter test`;
- список устройств зависит от установленного браузера и настроек Flutter SDK.

Команды для диагностики и восстановления web-запуска:

```bash
flutter devices
flutter config --enable-web
flutter run -d chrome
```

Если Chrome недоступен, временный fallback для локальной проверки на macOS:

```bash
flutter run -d macos
```

Фактическое исправление было выполнено вручную на уровне окружения разработки: после установки Google Chrome Flutter начал видеть устройство `Chrome (web)`. Роль Codex в этом кейсе — анализ симптомов, подтверждение, что бизнес-логика и UI-компоненты не требуют изменений, повторная проверка `flutter devices` и документирование результата.

### Кейс отладки: Git push без настроенного remote

Симптом:

- команда `git push` завершилась ошибкой `No git remote configured for push`;
- код приложения при этом не требовал изменений.

Причина ошибки: локальный Git-репозиторий не знал, в какой удаленный репозиторий отправлять коммиты. Для `git push` должен быть настроен remote, обычно с именем `origin`, и текущая ветка должна быть связана с веткой на GitHub.

Команды диагностики:

```bash
git remote -v
git branch --show-current
git status --short
git config --get-regexp '^remote\.'
```

В ходе повторной проверки Codex подтвердил, что remote уже настроен:

```bash
origin git@github.com:SofrikX/otus_hw4.git
```

Текущая ветка проекта — `main`, рабочее дерево чистое. Дополнительно обнаружено, что локальные значения `user.name` и `user.email` в репозитории не заданы; это не причина ошибки remote, но может понадобиться для будущих коммитов.

Команды для настройки GitHub remote, если ошибка повторится в новом локальном клоне:

```bash
git remote add origin git@github.com:SofrikX/otus_hw4.git
git branch -M main
git push -u origin main
```

Если remote `origin` уже существует, но указывает не туда:

```bash
git remote set-url origin git@github.com:SofrikX/otus_hw4.git
git push -u origin main
```

Роль Codex в этом кейсе — анализ инфраструктурной ошибки, проверка текущей Git-конфигурации без изменения кода приложения и подготовка безопасных команд для настройки GitHub remote.

### Кейс проверки: feature walks

Задача: проверить, что экран прогулок соответствует позитивному сценарию US-8 и требованиям MVP.

Что проверено:

- `docs/user_stories.md` — сценарий поиска прогулок рядом;
- `lib/features/walks/domain/walk.dart` — модель прогулки;
- `lib/features/walks/application/walks_controller.dart` — состояние списка и join-сценарий;
- `lib/features/walks/presentation/screens/walks_screen.dart` — отображение списка прогулок;
- `lib/features/walks/presentation/widgets/walk_card.dart` — карточка, кнопка присоединения и счетчик участников;
- `test/features/walks/walks_screen_test.dart` — widget-test позитивного сценария.

Результат проверки: список прогулок отображается из mock-данных, кнопка `Присоединиться` вызывает `joinWalk`, состояние обновляется через Riverpod, карточка переключается в `Вы участвуете`, счетчик участников увеличивается на 1.

В тест добавлены явные проверки отображения прогулки, начального счетчика и исчезновения старого счетчика после присоединения.

## 8. Команды проверки

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

### Результат локальной проверки

Проверка запуска проекта через OpenAI Codex выполнена командами:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Результаты:

- `flutter pub get` — зависимости установлены, 33 пакета подключены, Firebase-зависимости не добавлены.
- `dart format .` — форматирование выполнено, изменено 10 Dart-файлов.
- `flutter analyze` — `No issues found!`.
- `flutter test` — 11 тестов пройдены, `All tests passed!`.
- Ранее `flutter run -d chrome` не запускался: `flutter devices` показывал только `macOS`.
- После ручной установки Google Chrome команда `flutter devices` показывает `Chrome (web)` и `macOS`, значит проблема была в окружении, а не в коде приложения.

Для запуска UI остается команда:

```bash
flutter run -d chrome
```

Если Chrome снова не отображается в списке устройств, нужно проверить окружение:

```bash
flutter devices
flutter config --enable-web
```

Fallback-команда для desktop-проверки:

```bash
flutter run -d macos
```

Если в локальном окружении отсутствуют platform files, нужно выполнить:

```bash
flutter create . --platforms=web,android,ios
```

## 9. Выводы

OpenAI Codex подходит для агентной разработки Flutter frontend MVP, если дать ему понятный входной контекст. Самыми полезными оказались:

- `AGENTS.md` как постоянные инструкции агента;
- `docs/documents_index.md` как карта документации;
- RTCF-промпты;
- итеративная разработка экран → состояния → тесты → рефакторинг;
- AI-assisted debugging по ошибкам терминала и скриншотам интерфейса.
