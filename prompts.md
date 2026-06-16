# prompts.md — журнал промптов для OpenAI Codex

Файл показывает активное использование AI-агента в процессе разработки. Промпты построены на техниках из ДЗ 2: Role Prompting, RTCF, Iterative Refinement, AI-assisted debugging и мультимодальный анализ интерфейса.

## Prompt 01 — первичный аудит проекта и документов

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

Результат: Codex подтвердил, что проект использует Flutter, Dart, Riverpod, go_router, Material 3, mock-данные, а основным AI-агентом является OpenAI Codex.

## Prompt 02 — проверка запуска проекта

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
- `dart format .` выполнил механическое форматирование Dart-файлов.
- `flutter analyze` завершился без замечаний: `No issues found!`.
- `flutter test` подтвердил прохождение автоматических тестов.
- На первом этапе `flutter run -d chrome` не запустился, потому что Flutter не видел устройство `chrome`; `flutter devices` показывал только `macOS`.
- Позже проблема была исправлена вручную на уровне окружения: после установки Google Chrome Flutter начал видеть `Chrome (web)`.
- Добавлен `.gitignore`, чтобы не включать в репозиторий `.dart_tool/`, `build/` и служебные Flutter-файлы.
- `development_report.md` обновлен результатами локальной проверки.

## Prompt 03 — ревью архитектуры

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

Результат: Codex подтвердил feature-first структуру `lib/app`, `lib/core`, `lib/features`, использование mock-данных и отсутствие backend-вызовов в UI текущего MVP.

## Prompt 04 — проверка ленты

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

Результат:

- Codex проверил `AGENTS.md`, `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`, `docs/user_stories.md`, `docs/ui_concepts/ui_description.md`, `docs/ui_concepts/concept_2_bright_social.dart`, `lib/features/feed/`, `lib/core/data/mock_data.dart`, `lib/core/widgets/async_content_view.dart`, `lib/core/widgets/responsive_center.dart` и `test/features/feed/`.
- В `PetPost` добавлено хранение текста mock-комментариев.
- `FeedController` хранит локальное mock-состояние ленты: лайк меняет `isLiked` и счетчик, комментарий добавляется в список комментариев и увеличивает счетчик.
- `PostCard` показывает последние комментарии и закрывает bottom sheet до изменения состояния ленты, чтобы не ломать lifecycle `TextEditingController`.
- `feed_screen_test.dart` расширен проверками success/loading/empty/error, изменения лайка и добавления комментария через UI.
- Добавлен `feed_controller_test.dart` для проверки мутаций mock-состояния на уровне контроллера.
- `flutter test test/features/feed` завершился успешно: 9 feed-тестов пройдены.

## Prompt 05 — проверка профиля питомца

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

Результат:

- Codex проверил `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`, `docs/user_stories.md`, `docs/error_handling.md`, `lib/features/pets/`, `lib/core/data/mock_data.dart`, `lib/app/router.dart` и `test/features/pets/`.
- Реализация `PetsScreen` показывала mock-список питомцев, а `PetCard` открывал профиль через `go_router`.
- `PetProfileScreen` обрабатывал неизвестный id через дружелюбный `ErrorState`.
- `pet_profile_screen_test.dart` расширен до трех widget-тестов: отображение списка питомцев, переход в профиль через `go_router`, error-state для неизвестного id.
- `flutter test test/features/pets` завершился успешно: 3 pets-теста пройдены.

## Prompt 06 — проверка прогулок

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

Результат:

- Codex проверил user story US-8 и реализацию `lib/features/walks/`.
- Логика присоединения реализована в `WalksController.joinWalk`: состояние прогулки меняется на joined, счетчик участников увеличивается.
- Widget-test `test/features/walks/walks_screen_test.dart` усилен проверками отображения прогулки, начального счетчика, кнопки присоединения и обновленного счетчика после tap.
- Targeted test `flutter test test/features/walks/walks_screen_test.dart` проходит.

## Prompt 07 — генерация и проверка тестов

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

Результат:

- Codex проверил `AGENTS.md`, `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`, `test/`, `lib/features/chat/`, `lib/core/data/mock_data.dart` и `development_report.md`.
- В проекте уже были тесты для feed, pets и walks: лента, лайки, комментарии, состояния загрузки/ошибки/пустого списка, список питомцев, переход в профиль, неизвестный id питомца и присоединение к прогулке.
- Найден пробел в покрытии MVP: базовый экран чатов не имел отдельного widget-теста.
- Добавлен `test/features/chat/chat_screen_test.dart`: проверка mock-диалогов, последнего сообщения, бейджа непрочитанных и empty-state.
- `development_report.md` обновлен итогами проверки автоматических тестов.

## Prompt 08 — отладка git push без remote

```markdown
# Role
Ты Git Debugger и Technical Writer.

# Task
Разбери ошибку `git push`: `No git remote configured for push`.

# Context
Проект PetConnect готовится к публикации на GitHub. Код приложения менять не нужно.

# Requirements
1. Проверь текущую ветку и git remote.
2. Объясни причину ошибки простыми словами.
3. Дай безопасные команды для настройки `origin`.
4. Зафиксируй кейс в `development_report.md`.

# Format
Симптом → причина → команды диагностики → команды исправления → роль Codex.
```

Результат:

- Codex проверил `git remote -v`, текущую ветку и состояние рабочего дерева.
- Причина ошибки описана как отсутствие настроенного удаленного репозитория для `git push`.
- В `development_report.md` добавлены команды `git remote add origin`, `git remote set-url origin` и `git push -u origin main`.
- Код приложения не менялся.

## Prompt 09 — UI/UX отладка bright social интерфейса

```markdown
# Role
Ты Flutter UI/UX Debugger.

# Task
Проверь интерфейс PetConnect на соответствие концепции "яркая социальная сеть" и исправь найденные layout-проблемы.

# Context
Прочитай:
- docs/ui_concepts/ui_description.md
- docs/ui_concepts/concept_2_bright_social.dart
- lib/features/home/presentation/home_screen.dart
- lib/features/feed/presentation/screens/feed_screen.dart
- lib/features/feed/presentation/widgets/post_card.dart
- lib/app/theme.dart

# Requirements
1. Найди проблемы desktop/mobile layout.
2. Предложи точечные исправления.
3. Не меняй бизнес-логику.
4. Запусти `flutter analyze` и `flutter test`.
5. Обнови `development_report.md`.

# Format
Проблема → причина → исправление → проверка.
```

Результат:

- Desktop-навигация переведена на `NavigationRail`, mobile оставлен с `NavigationBar`.
- Desktop-действие создания поста перенесено из FAB в `AppBar`.
- В ленту добавлен приветственный header, фон темы сделан теплее.
- Медиа-блок поста получил responsive-высоту с min/max ограничениями.
- `development_report.md` обновлен кейсом UI/UX отладки.

## Prompt 10 — финальный рефакторинг

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

Результат:

- Codex прочитал `AGENTS.md`, `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`, `lib/`, `test/`, `README.md`, `development_report.md` и текущий diff рабочей ветки.
- Выполнен точечный рефакторинг без изменения MVP scope и без Firebase: `HomeScreen` получил единый источник навигационных destination-данных для mobile/desktop, `PostCard` разделен на приватные виджеты header/media/actions/comments, `PetProfileScreen` разделен на summary/owner/interests блоки.
- `README.md` и `development_report.md` обновлены под фактический финальный набор тестов и refactoring-кейс.
- Проверка: `dart format .`, `flutter analyze`, `flutter test`.

## Prompt 11 — документирование кейса Flutter Web

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

## Prompt 12 — исправление кнопки назад в профиле питомца

```markdown
Нашел баг, из карточки питомца нет кнопки выхода назад.
```

Результат:

- Причина: `PetsScreen` открывал профиль через `context.go('/pets/:id')`, поэтому маршрут заменял текущий экран и у `PetProfileScreen` не было back stack для автоматической кнопки назад.
- Исправление: переход из карточки питомца переведен на `context.push('/pets/:id')`.
- Тест `PetsScreen opens pet profile through go_router` расширен проверкой `BackButton` и возврата к списку питомцев.
- Проверка: `dart format .`, `flutter analyze`, `flutter test`.

## Prompt 13 — мультимодальная проверка desktop и mobile скриншотов

```markdown
# Role
Ты Flutter UI/UX Debugger и OpenAI Codex AI coding agent.

# Task
Проведи мультимодальную проверку интерфейса PetConnect по приложенным скриншотам desktop и mobile.

# Context
Приложены скриншоты:
- docs/screenshots/petconnect_desktop.png
- docs/screenshots/petconnect_mobile.png

UI-концепция проекта: яркая социальная сеть для владельцев питомцев.
Стек: Flutter, Material 3, Riverpod, go_router.
Проект должен корректно выглядеть на desktop и mobile.

# Requirements
1. Проанализируй скриншоты.
2. Найди проблемы адаптивности, визуальной иерархии или переполнений.
3. Если критичных проблем нет, зафиксируй это честно.
4. Если есть проблемы, предложи минимальные исправления.
5. Обнови development_report.md.
6. Обнови prompts.md.
7. Не меняй бизнес-логику приложения.

# Format
Что проверено → найденные проблемы → исправления или вывод → команды проверки.
```

Результат:

- Codex проверил `docs/screenshots/petconnect_desktop.png` и `docs/screenshots/petconnect_mobile.png`.
- Критичных проблем адаптивности, визуальной иерархии или переполнений не найдено.
- Desktop корректно использует `NavigationRail`, ограниченную ширину ленты и desktop-действие в `AppBar`.
- Mobile корректно использует нижнюю навигацию и FAB; некритичная зона наблюдения — FAB находится близко к нижней части первой карточки, но в текущем состоянии не перекрывает ключевой текст или действие.
- Код приложения не менялся, обновлены только `development_report.md` и `prompts.md`.

## Prompt 14 — финальная проверка документации

```markdown
# Role
Ты Technical Writer и QA Reviewer.

# Task
Почисти финальную документацию перед сдачей ДЗ и проверь, что документы выглядят профессионально.

# Context
Проект PetConnect готовится к сдаче ДЗ "Разработка Frontend-приложения с AI-агентом". Основной AI-агент проекта: OpenAI Codex.

# Requirements
1. Удали слабые debug-кейсы и служебные заглушки.
2. Проверь `README.md`, `development_report.md`, `prompts.md`, `AGENTS.md` и документы в `docs/`.
3. Сохрани только реальные кейсы использования Codex.
4. Исправь нумерацию prompts.
5. Не меняй код приложения, тесты и `pubspec.yaml`.

# Format
Summary → Files changed → Removed weak fragments → Replaced prompts → Kept real AI-agent cases → Prompt numbering → Documentation consistency → Remaining risks → Suggested commands → Diff.
```

Результат:

- Удален слабый debug-кейс без фактической команды и ошибки.
- Prompt с debug-заглушками заменен на реальный кейс `git push` без настроенного remote.
- Запись про проверку интерфейса без фактического пользовательского изображения заменена на реальные проверяемые кейсы: UI/UX отладку bright social интерфейса и мультимодальную проверку `docs/screenshots/petconnect_desktop.png` / `docs/screenshots/petconnect_mobile.png`.
- Нумерация prompts приведена к последовательности Prompt 01-14.
- Код приложения не менялся.

## Prompt 15 — обновление документации под HW5 Firebase

```markdown
# Role
Ты Technical Writer и AI Workflow Engineer.

# Task
Обнови проектные инструкции и документацию под ДЗ 5.

# Context
Проект переехал в новый репозиторий `otus_hw5`.
Теперь цель проекта — интегрировать Flutter frontend PetConnect с Firebase backend.

# Required reading
Прочитай:
- AGENTS.md
- README.md
- development_report.md
- prompts.md
- docs/documents_index.md
- docs/ai_agent_rules.md
- docs/ai_workflow.md
- docs/current_homework_scope.md

# Requirements
1. Обнови `AGENTS.md` под HW5:
   - основной AI-агент: OpenAI Codex;
   - стек: Flutter + Firebase;
   - backend: Firebase Auth, Firestore, Storage, Cloud Functions;
   - обязательные проверки: flutter analyze, flutter test, npm test для functions, firebase emulators.
2. Обнови `docs/current_homework_scope.md`:
   - описать 9 шагов текущего ДЗ;
   - заменить Supabase/PostgreSQL на Firebase-эквиваленты.
3. Обнови `docs/ai_workflow.md`:
   - добавить проектирование Firestore schema;
   - генерацию Security Rules;
   - генерацию Cloud Functions API;
   - интеграцию frontend-backend;
   - AI-анализ логов.
4. Обнови `docs/documents_index.md`, чтобы было понятно, какие документы относятся к HW5.
5. Добавь запись в `prompts.md` об этом prompt-е.
6. Не меняй код приложения.

# Done when
- Документация больше не выглядит как HW4-only.
- Везде основным агентом указан OpenAI Codex.
- Firebase указан как backend-решение.
- Supabase упоминается только как технология из оригинального задания, замененная на Firebase по причине согласованности с ТЗ PetConnect.

# Output format
1. Summary.
2. Files changed.
3. Firebase mapping from original homework.
4. Diff.
```

Результат:

- `AGENTS.md` обновлен под HW5: OpenAI Codex, Flutter + Firebase, Auth, Firestore, Storage, Cloud Functions, Security Rules, Emulator Suite и обязательные проверки.
- `docs/current_homework_scope.md` переписан как scope ДЗ 5 с 9 шагами и таблицей замены Supabase/PostgreSQL на Firebase.
- `docs/ai_workflow.md` дополнен этапами Firestore schema, Storage, Security Rules, Cloud Functions API, frontend-backend integration и AI-анализом логов.
- `docs/documents_index.md` обновлен как навигатор по HW5-документации.
- `docs/ai_agent_rules.md`, `README.md` и `development_report.md` обновлены, чтобы документация не оставалась HW4-only.
- Код приложения не менялся.
