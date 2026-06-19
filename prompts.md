# prompts.md — журнал промптов для OpenAI Codex

Файл показывает активное использование AI-агента в процессе разработки. Промпты построены на техниках из ДЗ 2: Role Prompting, RTCF, Iterative Refinement, AI-assisted debugging и мультимодальный анализ интерфейса.

Важно: записи до Prompt 31 сохраняют историю предыдущей Firebase-ветки HW5. После архитектурного решения `Architecture Decision: Firebase to Supabase` текущим backend choice для ДЗ является Supabase Free Tier, а Firebase описывается как исследованный вариант.

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

## Prompt 16 — проектирование Firestore schema

```markdown
# Role
Ты Firebase Data Architect и Backend Engineer.

# Task
Спроектируй структуру базы данных PetConnect для Cloud Firestore.

# Context
PetConnect — приложение для владельцев питомцев.
Основные функции:
- лента публикаций;
- профили питомцев;
- прогулки;
- комментарии;
- лайки;
- базовые чаты.

# Required reading
Прочитай:
- docs/technical_specification.md
- docs/project_description.md
- docs/user_stories.md
- docs/current_homework_scope.md
- lib/features/
- README.md

# Requirements
1. Создай файл `docs/firestore_schema.md`.
2. Опиши коллекции:
   - users
   - pets
   - posts
   - posts/{postId}/comments
   - walks
   - chats
   - chats/{chatId}/messages
3. Для каждой коллекции укажи:
   - назначение;
   - поля;
   - типы данных;
   - обязательность;
   - связи;
   - пример документа.
4. Опиши, какие данные нужны для MVP HW5.
5. Опиши индексы, которые могут понадобиться.
6. Добавь раздел "AI-assisted database design", где указано, что схема спроектирована с помощью OpenAI Codex.
7. Обнови `prompts.md`.
8. Не меняй Flutter-код.

# Output format
1. Summary.
2. Collections.
3. Indexes.
4. Files changed.
5. Diff.
```

Результат:

- Создан `docs/firestore_schema.md` со схемой Cloud Firestore для `users`, `pets`, `posts`, `posts/{postId}/comments`, `walks`, `chats`, `chats/{chatId}/messages`.
- Дополнительно описана рекомендуемая техническая подколлекция `posts/{postId}/likes/{uid}` для корректной реализации лайков.
- Для каждой коллекции указаны назначение, поля, типы, обязательность, связи и пример документа.
- Добавлены разделы MVP HW5 Data, Indexes, Security Notes и AI-assisted database design.
- `docs/documents_index.md` и `development_report.md` обновлены ссылкой на новый документ.
- Flutter-код не менялся.

## Prompt 17 — подготовка Firebase configuration

```markdown
# Role
Ты Firebase DevOps Engineer.

# Task
Подготовь Firebase configuration для проекта PetConnect.

# Context
Нужно добавить backend-инфраструктуру для ДЗ 5.
Firebase project может быть подключен позже через Firebase CLI.
Секреты нельзя коммитить.

# Requirements
Создай или обнови файлы:
- firebase.json
- .firebaserc.example
- firestore.rules
- firestore.indexes.json
- storage.rules
- .env.example
- docs/deployment.md

# Firebase services
Используются:
- Firestore
- Storage
- Functions
- Auth
- Emulators

# Requirements for firebase.json
1. Настрой Firestore rules и indexes.
2. Настрой Storage rules.
3. Настрой Functions source: `functions`.
4. Настрой Emulators:
   - auth
   - firestore
   - functions
   - storage
   - ui

# Requirements for .env.example
Добавь только безопасные placeholder-переменные:
- FIREBASE_PROJECT_ID
- FIREBASE_REGION
- API_BASE_URL
- USE_FIREBASE_BACKEND

Не добавляй реальные ключи.

# Requirements for docs/deployment.md
Опиши:
1. Установку Firebase CLI.
2. `firebase login`.
3. `firebase init`.
4. Локальный запуск emulator suite.
5. Production deploy.
6. Предупреждение, что Cloud Functions deploy может требовать Firebase Blaze plan.
7. Как не коммитить секреты.

# Security
1. Не добавляй serviceAccount.json.
2. Не добавляй реальные токены.
3. Не добавляй реальные Firebase API keys в .env.
4. Обнови `.gitignore`, если нужно.

# Output format
1. Summary.
2. Files changed.
3. Security notes.
4. Commands to run manually.
5. Diff.
```

Результат:

- Созданы `firebase.json`, `.firebaserc.example`, `firestore.rules`, `firestore.indexes.json`, `storage.rules`, `.env.example` и `docs/deployment.md`.
- `firebase.json` настраивает Firestore rules/indexes, Storage rules, Functions source `functions` и emulators для Auth, Firestore, Functions, Storage и UI.
- `.env.example` содержит только безопасные placeholders без реальных ключей.
- `.gitignore` дополнен правилами для `.env`, `.firebaserc`, service account файлов, Firebase debug logs и `functions/node_modules`.
- `docs/deployment.md`, `docs/documents_index.md` и `development_report.md` обновлены под Firebase CLI/emulator/deploy workflow.
- Flutter-код не менялся.

## Prompt 18 — реализация Firestore Security Rules

```markdown
# Role
Ты Firebase Security Engineer.

# Task
Реализуй Firestore Security Rules для PetConnect.

# Context
Backend использует Firebase Auth и Cloud Firestore.
Нужно заменить логику Supabase RLS из оригинального ДЗ на Firebase Security Rules.

# Required reading
Прочитай:
- docs/firestore_schema.md
- docs/current_homework_scope.md
- docs/technical_specification.md
- firestore.rules

# Requirements
Настрой правила для коллекций:

1. users
   - пользователь может читать базовые публичные профили;
   - пользователь может создавать/обновлять только свой документ.

2. pets
   - читать можно всем авторизованным пользователям;
   - создавать может авторизованный пользователь;
   - обновлять/удалять может только ownerId.

3. posts
   - читать можно всем авторизованным пользователям;
   - создавать может авторизованный пользователь;
   - authorId должен совпадать с request.auth.uid;
   - обновлять/удалять может только автор.

4. posts/{postId}/comments
   - читать можно всем авторизованным пользователям;
   - создавать может авторизованный пользователь;
   - authorId должен совпадать с request.auth.uid;
   - удалять может автор комментария или автор поста.

5. walks
   - читать можно всем авторизованным пользователям;
   - создавать может авторизованный пользователь;
   - creatorId должен совпадать с request.auth.uid;
   - обновлять может creatorId или участник при join-сценарии.

6. chats/messages
   - читать и писать можно только участникам чата.

# Validation
Добавь helper-функции:
- signedIn()
- isOwner(ownerId)
- isAuthor(authorId)
- isChatParticipant()

# Documentation
Обнови или создай:
- docs/firebase_security.md

В документации объясни:
- чем Firebase Security Rules заменяют Supabase RLS;
- какие операции разрешены;
- какие операции запрещены.

# Output format
1. Summary.
2. Rules implemented.
3. Security assumptions.
4. Files changed.
5. Diff.
```

Результат:

- `firestore.rules` переписан под Firebase Auth и коллекции PetConnect: users, pets, posts, comments, likes, walks, chats и messages.
- Добавлены helper-функции `signedIn()`, `isOwner(ownerId)`, `isAuthor(authorId)` и `isChatParticipant()`.
- Реализовано удаление комментария автором комментария или автором родительского поста.
- Для прогулок добавлен join-сценарий участника: добавление своего UID и увеличение `participantsCount` на 1.
- Создан `docs/firebase_security.md` с объяснением замены Supabase RLS на Firebase Security Rules, списком разрешенных и запрещенных операций.
- Flutter-код не менялся.

## Prompt 19 — Cloud Functions HTTP API

```markdown
# Role
Ты Backend Developer, Firebase Cloud Functions Engineer.

# Task
Создай Cloud Functions HTTP API для PetConnect.

# Context
Оригинальное ДЗ требует API endpoints и минимум 3 CRUD операции.
В проекте используется Firebase вместо Supabase.
API должен работать с Firestore через Firebase Admin SDK.

# Requirements
Создай структуру:

- functions/package.json
- functions/tsconfig.json
- functions/src/index.ts
- functions/src/app.ts
- functions/src/middleware/auth.ts
- functions/src/middleware/errorHandler.ts
- functions/src/repositories/postsRepository.ts
- functions/src/repositories/walksRepository.ts
- functions/src/routes/posts.ts
- functions/src/routes/walks.ts
- functions/src/types.ts

# API endpoints
Реализуй минимум:

1. GET /posts
   - возвращает список постов;
   - поддерживает limit;
   - сортировка по createdAt desc.

2. POST /posts
   - требует Firebase ID token;
   - создает пост;
   - валидирует text, petId, authorId.

3. POST /posts/:postId/like
   - требует Firebase ID token;
   - toggle like;
   - возвращает новое количество лайков.

4. GET /walks
   - возвращает список прогулок.

5. POST /walks/:walkId/join
   - требует Firebase ID token;
   - добавляет текущего пользователя в participants.

# Error handling
Добавь единый формат ошибок:

{
  "error": {
    "code": "validation-error",
    "message": "..."
  }
}

Нужны статусы:
- 400 validation error
- 401 unauthorized
- 403 forbidden
- 404 not found
- 500 internal error

# Logging
Используй functions logger для:
- входящих операций;
- ошибок;
- важных backend-событий.

# CORS
Настрой CORS для локального Flutter Web и production origin через env/config.

# Testing
Добавь базовые npm scripts:
- build
- lint
- test
- serve

# Documentation
Создай или обнови:
- docs/api_spec.md

# Restrictions
1. Не добавляй реальные секреты.
2. Не меняй Flutter-код на этом шаге.
3. Не подключай Supabase.

# Output format
1. Summary.
2. Endpoints created.
3. Error model.
4. Files changed.
5. Commands to run.
6. Diff.
```

Результат:

- Создан TypeScript/Express backend в `functions/` с экспортом Cloud Function `api`.
- Добавлены middleware Firebase ID token auth и единый error handler.
- Добавлены repositories для `posts` и `walks`, работающие через Firebase Admin SDK и Firestore transactions.
- Реализованы endpoints `GET /posts`, `POST /posts`, `POST /posts/:postId/like`, `GET /walks`, `POST /walks/:walkId/join`.
- Настроен CORS для локальных Flutter Web origins и production origins через `CORS_ORIGIN`.
- Создан `docs/api_spec.md` с описанием endpoints, auth, CORS, error model и команд запуска.
- Flutter-код не менялся, Supabase не подключался.

## Prompt 20 — seed-данные для Firebase Emulator

```markdown
# Role
Ты Firebase Backend Developer и QA Engineer.

# Task
Добавь seed-данные для локального Firebase Emulator Suite.

# Context
Для проверки ДЗ преподаватель должен иметь возможность запустить backend локально и увидеть данные в приложении.

# Required reading
Прочитай:
- docs/firestore_schema.md
- functions/src/
- firestore.rules
- README.md

# Requirements
Создай:
- scripts/seed_firestore.js
- docs/seed_data.md

# Seed data
Добавь тестовые данные:
- 2 users
- 3 pets
- 4 posts
- comments к постам
- 3 walks
- 1 chat
- 2 messages

# Requirements for script
1. Скрипт должен работать с Firestore Emulator.
2. Не использовать production credentials.
3. Использовать FIRESTORE_EMULATOR_HOST.
4. Иметь npm script или понятную команду запуска.
5. Не требовать serviceAccount.json.
6. Данные должны соответствовать docs/firestore_schema.md.

# Documentation
В docs/seed_data.md опиши:
- как запустить emulators;
- как выполнить seed;
- какие данные создаются.

# Update
Обнови:
- README.md
- prompts.md

# Output format
1. Summary.
2. Seed data overview.
3. Commands.
4. Files changed.
5. Diff.
```

Результат:

- Создан `scripts/seed_firestore.js` для наполнения Firestore Emulator.
- Скрипт требует `FIRESTORE_EMULATOR_HOST`, не использует `serviceAccount.json` и не содержит production credentials.
- Добавлен npm script `seed` в `functions/package.json`.
- Создан `docs/seed_data.md` с командами запуска emulators и seed.
- `README.md`, `docs/documents_index.md`, `development_report.md` и `prompts.md` обновлены ссылками на seed workflow.
- Flutter-код не менялся.

## Prompt 21 — Firebase Auth во Flutter frontend

```markdown
# Role
Ты Senior Flutter Developer и Firebase Auth Engineer.

# Task
Добавь базовую интеграцию Firebase Auth во Flutter frontend.

# Context
ДЗ требует аутентификацию: регистрация и вход пользователей.
Проект уже использует Flutter, Riverpod и go_router.

# Requirements
1. Добавь firebase_core и firebase_auth.
2. Создай auth domain/data/presentation структуру.
3. Реализуй email/password login, registration, logout и auth state provider.
4. Добавь loading/error/success состояния.
5. Обнови routing: /login, /register и auth redirect.
6. Не ломай текущие mock-экраны.
7. Предусмотри Firebase Auth Emulator.
8. Не коммить реальные Firebase secrets.

# Testing
Добавь минимум 2 widget/unit tests для auth controller или screen.

# Documentation
Обнови README.md, development_report.md, prompts.md.
```

Результат:

- `firebase_core` и `firebase_auth` добавлены через `flutter pub add`.
- Созданы `AppUser`, `FirebaseAuthRepository`, `AuthController`, `LoginScreen` и `RegisterScreen`.
- Добавлен Firebase bootstrap с demo options для Auth Emulator через `--dart-define=USE_FIREBASE_AUTH_EMULATOR=true`.
- `go_router` получил routes `/login`, `/register` и redirect для protected screens.
- В `HomeScreen` добавлен logout, mock-экраны feed/pets/walks/chat не переводились на Firebase и не сломались.
- Добавлен `test/features/auth/auth_controller_test.dart` с двумя unit-тестами loading/success и error сценариев.
- `dart format .`, `flutter analyze`, `flutter test` завершились успешно.

## Prompt 22 — API client для Cloud Functions HTTP API

```markdown
# Role
Ты Senior Flutter Developer и API Integration Engineer.

# Task
Создай API client для общения Flutter frontend с Firebase Cloud Functions HTTP API.

# Context
Cloud Functions API реализует:
- GET /posts
- POST /posts
- POST /posts/:postId/like
- GET /walks
- POST /walks/:walkId/join

Frontend должен постепенно перейти с mock-данных на backend-данные.

# Required reading
Прочитай:
- docs/api_spec.md
- functions/src/routes/
- lib/features/feed/
- lib/features/walks/
- lib/core/
- pubspec.yaml

# Requirements
1. Добавь HTTP-клиент.
2. Создай backend config, api client, api error и auth token provider.
3. Читай baseUrl из API_BASE_URL.
4. Добавляй Authorization Bearer token для авторизованного пользователя.
5. Обрабатывай 400, 401, 403, 404, 500 typed exceptions.
6. Добавь fallback: USE_FIREBASE_BACKEND=false использует mock repositories.
7. Не удаляй mock repositories.
8. Обнови documentation.

# Testing
Добавь unit tests для успешного GET, 401 unauthorized и 500 server error.
```

Результат:

- Добавлен `package:http` как direct dependency и выбран как легкий клиент для текущего REST-like API.
- Созданы `lib/core/config/backend_config.dart`, `lib/core/network/api_client.dart`, `lib/core/network/api_error.dart`, `lib/core/network/auth_token_provider.dart`.
- Добавлены Feed/Walks repository interfaces и mock/api реализации.
- `FeedController` и `WalksController` переключаются на HTTP repositories при `USE_FIREBASE_BACKEND=true`, иначе используют mock repositories.
- Добавлен `test/core/network/api_client_test.dart` для успешного GET, 401 и 500.
- Проверка: `dart format .`, `flutter analyze`, `flutter test`.

## Prompt 23 — интеграция экрана ленты с backend API

```markdown
# Role
Ты Senior Flutter Developer, Riverpod Engineer.

# Task
Интегрируй экран ленты PetConnect с backend API.

# Context
Сейчас feed работает на mock-данных.
Нужно добавить Firebase/Cloud Functions implementation, сохранив mock fallback.

# Required reading
Прочитай:
- docs/api_spec.md
- lib/features/feed/
- lib/core/network/
- lib/core/config/backend_config.dart
- test/features/feed/

# Requirements
1. Создай или обнови repository abstraction для feed.
2. Добавь Firebase/Api implementation:
   - fetchPosts()
   - createPost()
   - toggleLike()
   - addComment(), если endpoint уже есть; иначе оставить mock или документировать как next step.
3. Обнови Riverpod providers:
   - если USE_FIREBASE_BACKEND=true, использовать backend repository;
   - иначе mock repository.
4. Обнови Feed screen:
   - loading state;
   - error state с retry;
   - empty state;
   - success state.
5. Не ломай существующие UI-тесты.
6. Обнови тесты или добавь новые:
   - успешная загрузка feed;
   - backend error;
   - like action.
7. Обнови documentation:
   - development_report.md;
   - prompts.md.
```

Результат:

- Подтвержден и усилен `FeedRepository` contract для `fetchPosts`, `createPost` и `toggleLike`.
- `ApiFeedRepository` проверен тестами через `ApiClient` и `MockClient` для `GET /posts`, `POST /posts` и `POST /posts/:postId/like`.
- `feedRepositoryProvider` покрыт тестами выбора `MockFeedRepository` при `USE_FIREBASE_BACKEND=false` и `ApiFeedRepository` при `USE_FIREBASE_BACKEND=true`.
- `FeedController.refresh()` переведен на реальную repository error handling через `AsyncValue.guard`; искусственный `shouldFail` удален.
- `AsyncContentView` показывает `ApiException.message`, чтобы backend error-state был дружелюбным.
- `addComment()` оставлен локальным fallback/next step, потому что endpoint комментариев отсутствует в `docs/api_spec.md` и текущих Cloud Functions routes.
- Проверка: `flutter test test/features/feed`, `flutter analyze`, `flutter test` завершились успешно.

## Prompt 24 — интеграция экрана прогулок с backend API

```markdown
# Role
Ты Senior Flutter Developer и Backend Integration Engineer.

# Task
Интегрируй экран прогулок PetConnect с backend API.

# Context
Сейчас walks работают на mock-данных.
Cloud Functions API содержит:
- GET /walks
- POST /walks/:walkId/join

# Required reading
Прочитай:
- docs/api_spec.md
- lib/features/walks/
- lib/core/network/
- test/features/walks/

# Requirements
1. Создай или обнови WalkRepository abstraction.
2. Добавь Firebase/Api implementation:
   - fetchWalks()
   - joinWalk(walkId)
3. Обнови Riverpod providers:
   - USE_FIREBASE_BACKEND=true => backend;
   - false => mock.
4. UI должен поддерживать:
   - loading;
   - error с retry;
   - empty;
   - success;
   - join success.
5. Обработай ошибки:
   - 401 unauthorized;
   - 403 forbidden;
   - 404 walk not found;
   - network error.
6. Добавь или обнови тесты:
   - список прогулок отображается;
   - join работает;
   - error state отображается.
7. Обнови:
   - development_report.md;
   - prompts.md.
```

Результат:

- Подтвержден `WalksRepository` contract для `fetchWalks` и `joinWalk`.
- `ApiWalksRepository` проверен тестами через `ApiClient` и `MockClient` для `GET /walks` и `POST /walks/:walkId/join`.
- `walksRepositoryProvider` покрыт тестами выбора `MockWalksRepository` при `USE_FIREBASE_BACKEND=false` и `ApiWalksRepository` при `USE_FIREBASE_BACKEND=true`.
- `WalksController.joinWalk()` теперь обновляет состояние только после результата repository, а success snackbar показывается только после успешного join.
- `ApiClient` расширен `ApiNetworkException`; тестами покрыты 401, 403, 404, 500 и network failure.
- `WalksScreen` покрыт widget-тестами для списка, join success и error state с retry.

## Prompt 25 — интеграция данных питомцев с backend

```markdown
# Role
Ты Senior Flutter Developer и Firebase Integration Engineer.

# Task
Интегрируй данные питомцев PetConnect с backend.

# Context
Питомцы используются в профиле питомца и в постах.
Для MVP нужно получать данные питомца с backend вместо mock, сохранив fallback.

# Required reading
Прочитай:
- docs/firestore_schema.md
- docs/api_spec.md
- lib/features/pets/
- lib/features/feed/
- test/features/pets/

# Requirements
1. Добавь PetRepository abstraction, если ее нет.
2. Добавь Firebase/Api implementation:
   - getPetById(petId)
   - getPetsByOwner(ownerId), если это уже поддерживается backend.
3. Если API endpoint для pets отсутствует, добавь его в Cloud Functions:
   - GET /pets/:petId
   - POST /pets
4. Обнови UI:
   - loading;
   - error;
   - not found;
   - success.
5. Обнови tests:
   - pet profile success;
   - pet not found;
   - backend error.
6. Обнови:
   - docs/api_spec.md;
   - development_report.md;
   - prompts.md.
```

Результат:

- Добавлен `PetRepository` contract и `ApiPetRepository` / `MockPetRepository`.
- `PetProfileScreen` получает питомца через `petByIdProvider` и показывает loading, error, not found и success states.
- `PetsScreen` переведен на `AsyncContentView` с mock fallback для MVP.
- `ApiClient` получил методы `getPet` и `getPetsByOwner`.
- Cloud Functions API расширен endpoints `GET /pets/:petId`, `GET /pets?ownerId=...` и `POST /pets`.
- `POST /pets` защищен Firebase Auth и валидирует ownerId против uid.
- Добавлены tests для pet profile success, not found, backend error и API mapping.

## Prompt 26 — backend API endpoint tests и curl examples

```markdown
# Role
Ты Backend QA Engineer.

# Task
Добавь тестирование API endpoints и примеры запросов для PetConnect backend.

# Context
ДЗ требует протестировать API endpoints, проверить ответы и обработку ошибок.

# Required reading
Прочитай:
- functions/src/
- docs/api_spec.md
- docs/deployment.md
- docs/seed_data.md

# Requirements
1. Добавь backend tests для Cloud Functions API:
   - GET /posts success;
   - POST /posts unauthorized;
   - POST /posts validation error;
   - POST /posts/:postId/like success;
   - GET /walks success;
   - POST /walks/:walkId/join unauthorized.
2. Используй подходящий тестовый стек для TypeScript functions.
3. Добавь `docs/api_examples.md`.
4. В `docs/api_examples.md` добавь curl-примеры:
   - GET /posts;
   - POST /posts;
   - like post;
   - GET /walks;
   - join walk.
5. Для protected endpoints покажи Authorization Bearer token placeholder.
6. Обнови npm scripts:
   - test
   - build
   - lint, если возможно.
7. Обнови:
   - README.md;
   - backend_documentation.md, если он уже есть;
   - prompts.md.
```

Результат:

- Codex прочитал `functions/src/`, `docs/api_spec.md`, `docs/deployment.md`, `docs/seed_data.md`, а также проектные инструкции `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`.
- Добавлен `createApp` и factory-функции для routers/auth middleware, чтобы endpoint tests могли подставлять fake repositories и fake auth без обращения к production Firebase.
- Добавлен `functions/src/test/api.test.ts` на встроенном `node:test`; покрыты 6 требуемых API scenarios.
- `functions/package.json` теперь запускает `npm test` как `npm run build && node --test lib/test/*.test.js`; `build` и `lint` сохранены.
- Добавлен `docs/api_examples.md` с curl-примерами и Bearer token placeholder для protected endpoints.
- Обновлены `README.md`, `development_report.md` и `prompts.md`.
- `backend_documentation.md` в репозитории отсутствовал, поэтому не обновлялся.
- Проверки: `npm run lint --prefix functions` прошел; `npm test --prefix functions` прошел 6/6 tests после разрешения локального запуска, потому что sandbox блокировал `listen` для test sockets.

## Prompt 27 — финальная backend-документация для ДЗ 5

```markdown
# Role
Ты Technical Writer и Backend Architect.

# Task
Создай финальный файл `backend_documentation.md` для сдачи ДЗ 5.

# Context
Формат сдачи требует документацию:
- описание архитектуры;
- инструкции по развертыванию;
- описание API endpoints;
- примеры запросов;
- описание процесса разработки с AI.

# Required reading
Прочитай:
- README.md
- docs/firestore_schema.md
- docs/firebase_security.md
- docs/api_spec.md
- docs/api_examples.md
- docs/deployment.md
- docs/seed_data.md
- docs/ai_workflow.md
- prompts.md
- development_report.md
- firebase.json
- firestore.rules
- storage.rules
- functions/

# Requirements
Создай `backend_documentation.md` со структурой из 17 разделов: цель, Firebase mapping, архитектура, Firestore schema, security model, API endpoints, примеры запросов, emulator workflow, production deploy, переменные окружения, ошибки, логирование, тестирование, frontend-backend integration, AI-assisted development, ограничения MVP и чек-лист.
```

Результат:

- Создан `backend_documentation.md` как финальная документация для преподавателя по backend-части ДЗ 5.
- Документ объединяет сведения из README, Firestore schema, Security Rules, API spec/examples, deployment guide, seed data, AI workflow, `firebase.json`, `firestore.rules`, `storage.rules` и исходников Cloud Functions.
- Описаны реальные endpoints текущего Express API: `/health`, `/pets`, `/pets/:petId`, `/posts`, `/posts/:postId/like`, `/walks`, `/walks/:walkId/join`.
- Зафиксированы локальный запуск через Firebase Emulator Suite, production deploy, защита секретов, error model, logging, тестирование, frontend-backend integration и известные ограничения MVP.

## Prompt 28 — финальный README для сдачи ДЗ 5

```markdown
# Role
Ты Technical Writer и QA Reviewer.

# Task
Обнови README.md под финальную сдачу ДЗ 5.

# Context
README должен объяснять, как запустить frontend, backend, emulators, tests и как проверить end-to-end сценарий.

# Required reading
Прочитай:
- README.md
- backend_documentation.md
- docs/deployment.md
- docs/api_spec.md
- docs/api_examples.md
- docs/seed_data.md
- pubspec.yaml
- firebase.json
- functions/package.json

# Requirements
README.md должен содержать название проекта, описание, стек, объяснение отсутствия root package.json, основные функции, backend architecture, локальный запуск, тесты, production deploy, API summary, troubleshooting и AI-assisted development.

# Restrictions
Не меняй код приложения. Не добавляй ложных утверждений о production deploy, если он не выполнен.
```

Результат:

- README.md переписан как финальный runbook для проверяющего ДЗ 5.
- Добавлены инструкции по Flutter frontend, Cloud Functions dependencies, Firebase Emulator Suite, seed data, Flutter Web запуску и API smoke-check.
- Зафиксировано, что production deploy не подтвержден как выполненный; вместо этого описаны безопасные deploy-инструкции и локальный emulator-сценарий.
- Добавлены разделы про отсутствие `package.json` в корне, API endpoints summary, troubleshooting и AI-assisted development.
- Код приложения и backend-логика не менялись.

## Prompt 29 — error handling, logging и AI-анализ логов

```markdown
# Role
Ты Fullstack QA Engineer и Error Handling Specialist.

# Task
Проверь и доработай обработку ошибок и логирование в frontend и backend.

# Context
ДЗ требует:
- обработку сетевых ошибок;
- обработку ошибок валидации;
- обработку ошибок доступа;
- логирование;
- использование AI для анализа логов.

# Required reading
Прочитай:
- functions/src/
- lib/core/network/
- lib/features/feed/
- lib/features/walks/
- lib/features/pets/
- docs/api_spec.md
- backend_documentation.md
- development_report.md

# Requirements
1. Backend:
   - единый error response;
   - logger для 400/401/403/404/500;
   - validation errors;
   - auth errors.
2. Frontend:
   - typed exceptions;
   - user-friendly error messages;
   - retry actions;
   - loading/error/success states.
3. Документация:
   - добавь раздел в development_report.md про AI-анализ ошибок;
   - добавь пример логов Firebase Functions;
   - добавь prompt в prompts.md.
4. Не меняй UX без необходимости.
5. Не скрывай ошибки пустыми catch-блоками.

# Output format
1. Summary.
2. Backend error handling.
3. Frontend error handling.
4. Logging.
5. Files changed.
6. Diff.
```

Результат:

- Backend error envelope расширен optional-полями `details` и `requestId` без смены базовой формы `{ "error": { "code", "message" } }`.
- `HttpError` и `errorHandler` теперь покрывают validation details, malformed JSON, auth/access errors, `404` и unexpected `500`.
- Firebase Functions logger пишет структурированные записи для 400/401/403/404/500 с `requestId`.
- Flutter `ApiClient` сохраняет typed exceptions, `details` и `requestId`; UI показывает локализованный `ApiException.userMessage`.
- Backend endpoint tests расширены malformed JSON, 404 envelope и 500 envelope.
- `development_report.md`, `docs/api_spec.md` и `backend_documentation.md` обновлены разделами про AI-анализ ошибок и примерами Firebase Functions logs.

## Prompt 30 — end-to-end QA и release review HW5

```markdown
# Role
Ты QA Engineer и Release Reviewer.

# Task
Проведи end-to-end проверку проекта PetConnect HW5.

# Context
Нужно убедиться, что backend запускается, frontend подключается к backend, данные загружаются и отправляются на сервер, тесты проходят, документация готова к сдаче.

# Required reading
Прочитай:
- README.md
- backend_documentation.md
- docs/deployment.md
- docs/api_spec.md
- docs/seed_data.md
- development_report.md
- prompts.md
- firebase.json
- functions/package.json
- pubspec.yaml

# Commands
- flutter pub get
- flutter analyze
- flutter test
- cd functions && npm install
- cd functions && npm run build
- cd functions && npm test
- firebase emulators:start
- seed script
- flutter run -d chrome --dart-define=USE_FIREBASE_BACKEND=true

# Manual scenarios
Проверь регистрацию, вход, загрузку ленты, создание поста, лайк, прогулки, join, 401, backend error и адаптивность mobile/desktop.

# Requirements
Не меняй код без необходимости. Если найдена ошибка, объясни причину и предложи минимальный fix. Обнови development_report.md и prompts.md. Подготовь remaining risks.
```

Результат:

- Прочитаны обязательные документы, Firebase config, Functions package и Flutter dependencies.
- `flutter pub get`, `flutter analyze`, `flutter test`, `npm install`, `npm run build`, `npm test`, `firebase emulators:start`, seed script и Flutter Web запуск проверены.
- Backend emulators поднялись на портах из `firebase.json`; seed загрузил users/pets/posts/comments/walks/chat/messages.
- API smoke подтвердил `GET /health`, `GET /posts`, `GET /walks`, `GET /pets`, `401 unauthorized` без token и protected операции с Firebase ID token.
- Manual UI подтвердил регистрацию, загрузку backend feed, исправленное создание поста, лайк, загрузку прогулок, join и responsive mobile/desktop.
- Найден дефект: create-post UI был stub-сообщением, хотя backend/repository уже поддерживали `POST /posts`.
- Минимальный fix: `FeedController.createPost`, bottom sheet в `HomeScreen`, unit test для controller, уточнение README.
- Повторные проверки после fix: `dart format`, `flutter analyze`, `flutter test test/features/feed`, полный `flutter test` и `npm test` прошли.
- Remaining risks зафиксированы в `development_report.md`.

## Prompt 31 — Architecture Decision: Firebase to Supabase

```markdown
# Role
Ты OpenAI Codex, AI coding agent, Senior Flutter + Supabase Architect.

# Task
Органично переведи backend-стек проекта PetConnect с Firebase на Supabase и задокументируй архитектурное решение.

# Context
В предыдущих ДЗ в ТЗ упоминался Firebase, поэтому первая backend-ветка была спроектирована вокруг Firebase Auth, Firestore, Storage и Cloud Functions.

На этапе подготовки production-развертывания выяснилось, что Firebase Cloud Functions требуют Blaze/pay-as-you-go plan. Для учебного проекта важно сохранить бесплатный и воспроизводимый backend deployment.

Оригинальное ДЗ прямо предлагает Supabase как BaaS-решение. Поэтому принято решение перейти на Supabase Free Tier:
- Supabase Auth;
- PostgreSQL database;
- Row Level Security;
- Supabase Storage;
- auto REST API через PostgREST;
- Flutter SDK через supabase_flutter.

# Requirements
1. Не менять Flutter UI и бизнес-логику.
2. Обновить README.md, backend_documentation.md, development_report.md, prompts.md, docs/current_homework_scope.md, docs/ai_workflow.md и docs/ai_agent_rules.md.
3. Не удалять историю Firebase полностью: описать ее как исследованный вариант.
4. Добавить раздел "Architecture Decision: Firebase to Supabase".
5. Не утверждать, что Supabase уже развернут, если проект еще не создан.
```

Результат:

- `README.md` переписан как основной входной документ для Supabase Free Tier backend decision.
- `backend_documentation.md` теперь описывает Supabase architecture, PostgreSQL schema, RLS, Storage, API operations и migration plan.
- `docs/current_homework_scope.md` обновлен: Supabase указан как текущий backend для ДЗ, Firebase сохранен как исследованный вариант.
- `docs/ai_workflow.md` переведен с Firebase workflow на Supabase workflow.
- `docs/ai_agent_rules.md` и `AGENTS.md` обновлены под Flutter + Supabase правила.
- `docs/documents_index.md` обновлен, чтобы исторические Firebase-документы не воспринимались как текущий production backend.
- `development_report.md` сохраняет историю Firebase-прототипа и добавляет текущий Supabase architecture update.
- Flutter UI, бизнес-логика, `lib/`, `test/` и `pubspec.yaml` не менялись.
- Supabase URL, publishable key и service role key не добавлялись.

## Prompt 32 — подготовка проекта к подключению Supabase

```markdown
# Role
Ты Supabase DevOps Engineer и Technical Writer.

# Task
Подготовь проект к подключению Supabase.

# Context
Backend PetConnect теперь реализуется через Supabase.
Нужно подготовить структуру файлов, инструкции запуска и безопасную работу с переменными окружения.

# Requirements
1. Создать `supabase/`, `supabase/migrations/`, `supabase/seed.sql`.
2. Создать `docs/supabase_setup.md`, `docs/database_schema.md`, `docs/api_spec.md`, `docs/supabase_security.md`.
3. Обновить `.env.example`:
   - `SUPABASE_URL=`
   - `SUPABASE_PUBLISHABLE_KEY=`
   - `USE_SUPABASE_BACKEND=true`
4. Проверить `.gitignore`.
5. Обновить `README.md`, `backend_documentation.md`, `prompts.md`.
6. Не добавлять реальные ключи.
7. Не менять Flutter-код.
```

Результат:

- Создан Supabase scaffold с migration и seed placeholder.
- Добавлена начальная PostgreSQL schema, indexes, triggers, RLS policies и Storage bucket policies.
- `.env.example` переведен на Supabase placeholders без реальных значений.
- `.gitignore` закрывает реальные `.env` и локальные Supabase CLI файлы.
- Созданы документы setup/schema/API/security.
- README и backend documentation обновлены инструкциями dashboard setup, Project URL, anon/public key, migrations и Flutter `--dart-define`.
- Flutter-код, `pubspec.yaml`, `lib/` и `test/` не менялись.

## Prompt 33 — проектирование Supabase PostgreSQL schema

```markdown
# Role
Ты PostgreSQL Database Architect и Supabase Engineer.

# Task
Спроектируй базу данных PetConnect для Supabase PostgreSQL и создай SQL migrations.

# Context
PetConnect — приложение для владельцев питомцев. Нужно заменить Firestore collections на PostgreSQL tables.

# Requirements
1. Создать migration `supabase/migrations/001_initial_schema.sql`.
2. Спроектировать таблицы:
   - profiles
   - pets
   - posts
   - comments
   - post_likes
   - walks
   - walk_participants
   - chats
   - chat_participants
   - messages
3. Для каждой таблицы добавить `id uuid primary key`, timestamps, foreign keys, constraints и indexes.
4. Связать `profiles.id` с `auth.users.id`.
5. Добавить unique `(post_id, user_id)` и `(walk_id, user_id)`.
6. Добавить indexes для posts, comments, pets, walks и messages.
7. Добавить trigger/function для `updated_at`.
8. Обновить `docs/database_schema.md`.
9. Не менять Flutter-код.
```

Результат:

- Создана migration `supabase/migrations/001_initial_schema.sql`.
- Таблицы спроектированы под Supabase PostgreSQL и текущие Flutter domain entities.
- `profiles.id` связан с `auth.users.id`.
- `post_likes` и `walk_participants` имеют `id uuid primary key` и уникальные пары.
- Добавлены constraints, foreign keys, required indexes, updated_at triggers, counter triggers и RLS policies.
- `docs/database_schema.md` обновлен: таблицы, поля, связи, индексы, примеры данных и соответствие Flutter сущностям.
- Flutter-код, `lib/`, `test/` и `pubspec.yaml` не менялись.

## Prompt 34 — Supabase Row Level Security policies

```markdown
# Role
Ты Supabase Security Engineer.

# Task
Настрой Row Level Security policies для PetConnect.

# Context
Оригинальное ДЗ требует безопасность и политики доступа. Для Supabase это реализуется через RLS.

# Requirements
1. Создать `supabase/migrations/002_rls_policies.sql`.
2. Включить RLS для profiles, pets, posts, comments, post_likes, walks, walk_participants, chats, chat_participants, messages.
3. Настроить read для authenticated users.
4. Защитить writes по owner/author/self/chat participant.
5. Не использовать небезопасные write policies вида `using (true)` / `with check (true)`.
6. Обновить `docs/supabase_security.md`, `backend_documentation.md`, `prompts.md`.
```

Результат:

- Создана migration `supabase/migrations/002_rls_policies.sql`.
- Табличные RLS policies вынесены из `001_initial_schema.sql` в отдельную security migration.
- Read-доступ открыт только роли `authenticated`, anon/public read не используется.
- Write-доступ ограничен владельцем профиля/питомца, автором поста/комментария, self-like, self-join и участниками чата.
- Прямое client-side создание чата не открыто; для этого нужна будущая безопасная RPC/серверная операция.
- `docs/supabase_security.md` и `backend_documentation.md` обновлены описанием security model.

## Prompt 35 — Supabase seed data для backend QA

```markdown
# Role
Ты Supabase QA Engineer и Database Developer.

# Task
Создай seed-данные для проверки PetConnect в Supabase.

# Context
Для сдачи ДЗ нужно, чтобы backend был проверяемым и приложение показывало реальные данные после подключения к Supabase.

# Required reading
Прочитай:
- supabase/migrations/001_initial_schema.sql
- supabase/migrations/002_rls_policies.sql
- docs/database_schema.md
- docs/current_homework_scope.md
- README.md

# Requirements
1. Создай или обнови `supabase/seed.sql` и `docs/seed_data.md`.
2. Seed должен включать 2 demo profiles, 3 pets, 4 posts, comments, post_likes, 3 walks, walk_participants, 1 chat и messages.
3. Seed должен быть совместим со schema.
4. Не используй реальные персональные данные.
5. Объясни ограничение hosted Supabase Auth users и замену UUID.
6. Обнови README.md, backend_documentation.md и prompts.md.
```

Результат:

- `supabase/seed.sql` заменен с placeholder на идемпотентный demo seed для публичных Supabase tables.
- Seed создает 2 profiles, 3 pets, 4 posts, 5 comments, 4 post_likes, 3 walks, 4 walk_participants, 1 chat, 2 chat_participants и 3 messages.
- Seed не содержит реальных персональных данных, production emails, URL, keys, tokens или service role secrets.
- Для локальной проверки seed создает минимальные demo rows в `auth.users`, чтобы `profiles.id -> auth.users.id` проходил при `supabase db reset`.
- Документация объясняет, что в hosted Supabase Auth users нужно создать через Authentication UI или регистрацию в приложении, затем заменить demo UUID на реальные `auth.users.id`.
- `docs/seed_data.md`, `README.md` и `backend_documentation.md` обновлены командами применения seed, ожидаемыми данными и smoke checks.
- После установки Supabase CLI 2.106.0, Docker CLI и Colima выполнены проверки: `supabase db start`, `supabase db reset`, `supabase db lint` и SQL smoke checks. `db reset` и lint прошли, counts соответствуют ожидаемому seed.

## Prompt 36 — Supabase Auth во Flutter frontend

```markdown
# Role
Ты Senior Flutter Developer и Supabase Auth Engineer.

# Task
Интегрируй Supabase Auth во Flutter frontend.

# Context
ДЗ требует аутентификацию: регистрация и вход пользователей. В Supabase это делается через Supabase Auth.

# Required reading
Прочитай:
- lib/features/auth/
- lib/app/
- lib/core/
- pubspec.yaml
- docs/supabase_security.md
- backend_documentation.md

# Requirements
1. Реализуй auth layer: AuthRepository abstraction, SupabaseAuthRepository, AuthController через Riverpod, auth state provider.
2. Поддержи sign up, sign in, sign out, current user, auth state changes.
3. UI должен иметь login/register screens, loading/error states и success redirect.
4. Routing: при `USE_SUPABASE_BACKEND=true` anonymous users идут на login; mock mode не ломается.
5. После регистрации создай/обнови profile в `profiles`, если это предусмотрено schema.
6. Обработай invalid credentials, email already registered и network error.
7. Добавь/обнови тесты auth controller success/error и login screen loading/error.
8. Обнови README.md, development_report.md и prompts.md.
```

Результат:

- Добавлена зависимость `supabase_flutter`.
- Auth abstraction вынесена в `lib/features/auth/domain/auth_repository.dart`.
- Добавлены `SupabaseAuthRepository` и `MockAuthRepository`; Firebase repository оставлен как legacy fallback.
- `AuthController` выбирает Supabase Auth при `USE_SUPABASE_BACKEND=true`, Firebase legacy при `USE_FIREBASE_BACKEND=true`, mock repository по умолчанию.
- Добавлен Supabase initializer в `lib/core/supabase/supabase_initializer.dart`.
- `BackendConfig` читает `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` и `USE_SUPABASE_BACKEND`.
- `AuthTokenProvider` умеет отдавать Supabase access token.
- Router защищает app routes только в backend auth mode; mock mode открывает Home без login.
- `SupabaseAuthRepository` после sign up/sign in делает upsert в `public.profiles`.
- Обновлены auth tests и добавлены widget/router tests.
- Проверки прошли: `dart format .`, `flutter analyze`, полный `flutter test` — 52 tests passed.

## Prompt 37 — Supabase feed integration

```markdown
# Role
Ты Senior Flutter Developer, Riverpod Engineer и Supabase Integration Engineer.

# Task
Интегрируй ленту PetConnect с Supabase.

# Context
Feed сейчас работает на mock-данных.
Нужно добавить Supabase implementation, сохранив mock fallback.

# Required reading
Прочитай:
- lib/features/feed/
- lib/core/
- docs/database_schema.md
- docs/api_spec.md
- supabase/migrations/
- test/features/feed/

# Requirements
1. Создай или обнови FeedRepository abstraction.
2. Добавь SupabaseFeedRepository.
3. Реализуй операции fetchPosts(), createPost(), toggleLike(), addComment().
4. USE_SUPABASE_BACKEND=true -> SupabaseFeedRepository; false -> MockFeedRepository.
5. UI должен показывать loading, error with retry, empty, success.
6. Не превращай backend ошибки в пустые списки без отображения error state.
7. Обработай PostgREST/Supabase exceptions.
8. Добавь/обнови тесты feed success, empty state, error state, like action, comment action.
9. Обнови docs/api_spec.md, development_report.md, prompts.md.
```

Результат:

- `FeedRepository` расширен методом `addComment(AddCommentInput)`.
- Добавлен `SupabaseFeedRepository` на `supabase_flutter` для таблиц `posts`, `post_likes` и `comments`.
- `feedRepositoryProvider` теперь выбирает `SupabaseFeedRepository` при `USE_SUPABASE_BACKEND=true`, иначе `MockFeedRepository`.
- `MockFeedRepository` поддерживает `addComment`; legacy `ApiFeedRepository` оставлен компилируемым.
- `FeedController.addComment()` стал async, делает optimistic update и переводит state в error при backend failure.
- `FeedScreen` продолжает использовать `AsyncContentView` для loading/error/empty/success и передает текущего auth user в comment action, если он есть.
- `docs/api_spec.md`, `README.md` и `development_report.md` обновлены под Supabase feed data flow.
- Проверки прошли: `flutter test test/features/feed`, `flutter analyze`, полный `flutter test` — 53 tests passed.

## Prompt 38 — Supabase pet profiles integration

```markdown
# Role
Ты Senior Flutter Developer и Supabase Integration Engineer.

# Task
Интегрируй профили питомцев PetConnect с Supabase.

# Context
Профиль питомца должен получать реальные данные из Supabase в backend mode.

# Required reading
Прочитай:
- lib/features/pets/
- docs/database_schema.md
- supabase/migrations/
- test/features/pets/

# Requirements
1. Создай или обнови PetRepository abstraction.
2. Добавь SupabasePetRepository.
3. Реализуй getPetById(petId), getPetsByOwner(ownerId), createPet() при необходимости.
4. Сохрани mock fallback.
5. UI должен поддерживать loading, error, not found, success.
6. Обработай RLS/permission errors.
7. Добавь/обнови тесты pet profile success, pet not found, backend error.
8. Обнови docs/api_spec.md.
9. Обнови development_report.md.
10. Обнови prompts.md.
```

Результат:

- `PetRepository` расширен операциями `fetchPets` и `createPet`; `getPetById` и `getPetsByOwner` сохранены.
- Добавлен `SupabasePetRepository` на `supabase_flutter` для таблицы `pets`.
- `petRepositoryProvider` выбирает Supabase implementation при `USE_SUPABASE_BACKEND=true`, legacy API при `USE_FIREBASE_BACKEND=true`, mock fallback по умолчанию.
- `PetsScreen` теперь получает список через repository abstraction и в backend mode не подменяет результат mock-данными.
- `PetProfileScreen` сохраняет loading/error/not found/success через `AsyncContentView`.
- RLS denial/PostgREST code `42501` мапится в `ApiForbiddenException`.
- Добавлены тесты `supabase_pet_repository_test.dart`; widget tests профиля сохранены и обновлены под Supabase terminology.
- `docs/api_spec.md` и `development_report.md` обновлены под pet profile Supabase data flow.

## Prompt 39 — Supabase walks integration

```markdown
# Role
Ты Senior Flutter Developer и Supabase Integration Engineer.

# Task
Интегрируй прогулки PetConnect с Supabase.

# Context
Walks сейчас работают на mock-данных.
Нужно добавить Supabase implementation, сохранив mock fallback.

# Required reading
Прочитай:
- lib/features/walks/
- docs/database_schema.md
- supabase/migrations/
- test/features/walks/

# Requirements
1. Создай или обнови WalkRepository abstraction.
2. Добавь SupabaseWalkRepository.
3. Реализуй fetchWalks(); createWalk(), если нужно для CRUD; joinWalk(walkId); leaveWalk(walkId), если удобно.
4. Для join используй таблицу walk_participants.
5. Обработай unique constraint: если пользователь уже присоединился, показать понятное состояние, а не падение.
6. UI должен показывать loading; error with retry; empty; success; join success.
7. Добавь/обнови тесты: walks list success; join success; already joined; error state.
8. Обнови docs/api_spec.md.
9. Обнови development_report.md.
10. Обнови prompts.md.
```

Результат:

- `WalksRepository` расширен операциями `createWalk` и `leaveWalk`; mock fallback обновлен.
- Добавлен `SupabaseWalkRepository` на `supabase_flutter` для таблиц `walks` и `walk_participants`.
- `walksRepositoryProvider` выбирает Supabase implementation при `USE_SUPABASE_BACKEND=true`, legacy API при `USE_FIREBASE_BACKEND=true`, mock fallback по умолчанию.
- `fetchWalks` загружает активные прогулки и joined state текущего пользователя.
- `joinWalk` пишет в `walk_participants`, перечитывает `walks.participants_count` и обрабатывает unique constraint `23505` как `alreadyJoined`.
- `leaveWalk` удаляет строку `walk_participants` текущего пользователя и перечитывает счетчик.
- `WalksScreen` сохраняет loading, error with retry, empty, success и join success states; already joined показывает понятный snackbar.
- Добавлены Supabase repository tests и обновлены controller/widget tests.
- `docs/api_spec.md`, `development_report.md` и `prompts.md` обновлены под walks Supabase data flow.
- Проверки прошли: `dart format .`, `flutter analyze`, `flutter test test/features/walks`, полный `flutter test` — 68 tests passed.

## Prompt 40 — Supabase error handling and logging

```markdown
# Role
Ты Fullstack QA Engineer и Supabase Debugger.

# Task
Проверь и доработай обработку ошибок и логирование для Supabase backend integration.

# Context
ДЗ требует обработку сетевых ошибок, ошибок валидации, ошибок доступа, логирование и использование AI для анализа логов.

# Required reading
Прочитай:
- lib/core/
- lib/features/auth/
- lib/features/feed/
- lib/features/pets/
- lib/features/walks/
- docs/supabase_security.md
- backend_documentation.md
- README.md

# Requirements
1. Frontend должен различать network error, unauthorized, forbidden/RLS violation, validation error, not found, unknown error.
2. Добавь единый AppException или используй существующий.
3. UI должен показывать user-friendly messages.
4. Не скрывай ошибки пустыми catch-блоками.
5. Добавь debug logging только безопасного уровня без токенов, publishable key и персональных данных.
6. Обнови README troubleshooting.
7. Обнови backend_documentation.md: error handling, logging, AI-assisted debugging.
8. Обнови development_report.md: реальные кейсы отладки Supabase.
9. Обнови prompts.md.
```

Результат:

- Использован существующий единый `ApiException` layer.
- Добавлен `lib/core/supabase/supabase_error_mapper.dart` с `guardSupabaseOperation`, Supabase Auth/PostgREST mapper и safe debug logging.
- Feed/pets/walks Supabase repositories переведены на общий guard вместо дублирующих catch-блоков.
- Supabase Auth repository теперь логирует безопасные коды и возвращает friendly `AuthFailure`.
- `ApiException.userMessage` больше не показывает raw backend/PostgreSQL text для validation/server/unknown errors.
- README расширен troubleshooting cases: wrong `SUPABASE_URL`, wrong `SUPABASE_PUBLISHABLE_KEY`, RLS denied, missing seed, email confirmation и browser/CORS.
- `backend_documentation.md` дополнен разделами error handling, logging и AI-assisted debugging.
- `development_report.md` дополнен реальными кейсами отладки Supabase.
- Проверки прошли: `flutter analyze`, полный `flutter test` — 68 tests passed.

## Prompt 41 — Supabase production release documentation

```markdown
Role
Ты Supabase Release Engineer и QA Reviewer.

Task
Подготовь и задокументируй production-развертывание Supabase backend.

Context
Supabase backend должен быть развернут и доступен.
Для сдачи нужно показать, что:
* Supabase project создан;
* migrations применены;
* RLS включен;
* frontend подключается к backend;
* приложение работает end-to-end.

Required reading
Прочитай:
* README.md
* backend_documentation.md
* docs/supabase_setup.md
* docs/database_schema.md
* docs/supabase_security.md
* docs/api_spec.md
* supabase/migrations/
* supabase/seed.sql

Requirements
1. Обнови docs/supabase_setup.md.
2. Обнови backend_documentation.md.
3. Обнови README.md.
4. Добавь раздел "Production verification".
5. Не добавляй реальные publishable key в git.
6. Если production еще не проверен вручную, не утверждай, что проверен. Напиши "Manual verification checklist".
7. Обнови development_report.md.
8. Обнови prompts.md.
```

Результат:

- `docs/supabase_setup.md` переписан как production Supabase runbook: project creation, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, SQL Editor migrations, seed, table checks, RLS checks, Flutter launch and manual verification checklist.
- `backend_documentation.md` дополнен `Production project status` и `Production verification`.
- `README.md` обновлен под production backend setup, Flutter launch command и release checklist.
- `development_report.md` дополнен записью о release documentation review.
- Реальные Supabase keys/secrets не добавлялись.
- Hosted production smoke test не заявлен как выполненный; проверка оформлена как `Manual verification checklist`.

## Prompt 42 — end-to-end QA review with Supabase backend

```markdown
Role
Ты QA Engineer и Release Reviewer.

Task
Проведи end-to-end проверку PetConnect с Supabase backend.

Context
Нужно убедиться, что frontend работает с Supabase end-to-end.

Required reading
Прочитай:
* README.md
* backend_documentation.md
* docs/supabase_setup.md
* docs/api_spec.md
* docs/supabase_security.md
* development_report.md
* prompts.md
* lib/
* test/

Manual scenarios to verify
1. Запуск mock mode.
2. Запуск Supabase mode.
3. Регистрация пользователя.
4. Вход пользователя.
5. Загрузка ленты из Supabase.
6. Создание поста.
7. Лайк поста.
8. Добавление комментария.
9. Открытие профиля питомца.
10. Загрузка прогулок.
11. Присоединение к прогулке.
12. Проверка error state при неправильном SUPABASE_URL.
13. Проверка RLS: пользователь не может менять чужие данные.
14. Проверка mobile/desktop адаптивности.

Commands to run
* flutter pub get
* dart format .
* flutter analyze
* flutter test
* flutter run -d chrome --dart-define=USE_SUPABASE_BACKEND=false
* flutter run -d chrome --dart-define=USE_SUPABASE_BACKEND=true --dart-define=SUPABASE_URL= --dart-define=SUPABASE_PUBLISHABLE_KEY=

Requirements
1. Если найдена ошибка, объясни причину и предложи минимальный fix.
2. Не скрывай реальные проблемы.
3. Обнови development_report.md:
    * команды;
    * результаты;
    * найденные проблемы;
    * исправления.
4. Обнови prompts.md.
5. Не добавляй secrets.

Output format
1. Summary.
2. Commands run.
3. Manual checks.
4. Issues found.
5. Fixes applied.
6. Remaining risks.
7. Diff.
```

Результат:

- Прочитаны README, backend documentation, Supabase setup/security/API docs, development report, prompts, структура `lib/` и `test/`.
- Выполнены `flutter pub get`, `dart format .`, `flutter analyze`, `flutter test`.
- Mock mode запущен через `flutter run -d chrome --dart-define=USE_SUPABASE_BACKEND=false`.
- Supabase mode с пустыми `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY` сначала показал дефект: приложение падало до UI с `DartError`.
- Добавлен startup error screen для `BackendConfigException`, чтобы неправильная Supabase-конфигурация давала user-facing error state.
- Добавлен `test/app/startup_error_app_test.dart`.
- После исправления повторная проверка прошла: `dart format .`, `flutter analyze`, `flutter test` — 69 tests passed; повторный Supabase blank запуск больше не падает на bootstrap.
- На первичном QA pass hosted credentials еще не были подключены, поэтому live e2e был перенесен в следующий release step; secrets не добавлялись.

## Prompt 43 — prepare real Supabase deploy

```markdown
Для сдачи ДЗ необходима интеграция с настоящим сервером и деплой, делаем
```

Результат:

- Проверен статус рабочей ветки: есть незакоммиченные QA-изменения из предыдущего шага, они не откатывались.
- Прочитаны routing docs для Supabase задач: `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`, `docs/supabase_setup.md`, Supabase migrations, seed и backend docs.
- Проверен Supabase CLI: установлен `2.106.0`.
- Выполнен `supabase init`, добавлен `supabase/config.toml` и локальный `supabase/.gitignore`.
- Docker runtime поднят через `colima start`.
- `supabase start` сначала упал на `supabase_vector_*` из-за Colima docker socket mount. Использован минимальный workaround: `supabase start --exclude vector`.
- Локальный Supabase успешно применил migrations и seed.
- `supabase db lint` прошел: `No schema errors found`.
- `supabase db reset` прошел успешно.
- SQL smoke checks подтвердили demo counts, private Storage buckets, RLS enabled для всех application tables и корректные trigger counters.
- Повторно выполнены `dart format .`, `flutter analyze`, `flutter test`; результат: analyzer clean, 69 tests passed.
- Hosted deploy был продолжен после локальной CLI-авторизации и project link.
- Добавлена migration `003_api_grants.sql`, потому что hosted PostgREST authenticated writes сначала получили `403` из-за отсутствующих table grants.
- Hosted smoke checks прошли: Supabase Auth login, feed/walks read, like, comment, join walk, RLS negative check и Flutter Web Supabase init.
- Прямой SQL insert в `auth.users` для hosted login оказался ненадежным; рабочий flow — создать demo Auth users через Auth Admin/Dashboard/API, затем применить public seed rows.
- Реальные Supabase URL, publishable key, database password и access token не записывались в tracked files или отчеты.

## Prompt 44 — final backend documentation for Supabase submission

```markdown
# Role
Ты Technical Writer и Backend Architect.

# Task
Подготовь финальный файл backend_documentation.md для сдачи ДЗ с Supabase backend.

# Context
Формат сдачи требует описание архитектуры, инструкции по развертыванию, описание API endpoints, примеры запросов и описание процесса разработки с AI.

# Required reading
Прочитай README.md, docs/supabase_setup.md, docs/database_schema.md, docs/supabase_security.md, docs/api_spec.md, docs/seed_data.md, development_report.md, prompts.md, supabase/migrations/ и supabase/seed.sql.

# Requirements
backend_documentation.md должен содержать цель, выбор Supabase вместо Firebase, архитектуру, schema, migrations, seed, RLS, API operations, examples, deployment, env/secrets, error handling, logging/debugging, frontend integration, testing, AI-assisted development, ограничения MVP и финальный checklist.

# Output format
1. Summary.
2. Sections updated.
3. Files changed.
4. Diff.
```

Результат:

- Прочитаны обязательные документы, SQL migrations и seed.
- `backend_documentation.md` пересобран как финальная сдаваемая документация для преподавателя.
- Документ синхронизирован с фактическим состоянием Supabase backend: hosted deployment, `003_api_grants.sql`, trigger counters, RLS policies, Storage buckets, seed flow и Supabase Flutter repositories.
- Добавлены примеры Supabase Flutter SDK и REST requests для required operations.
- Обновлены `prompts.md` и `development_report.md` как журнал AI-assisted documentation work.
- Код Flutter, SQL migrations и secrets не менялись.

## Prompt 45 — план production-развертывания Flutter Web

```markdown
# Role
Ты Release Engineer, Flutter Web Developer и OpenAI Codex AI coding agent.

# Task
Добавь в проект план production-развертывания Flutter Web приложения PetConnect.

# Context
Backend PetConnect переведен на Supabase и должен быть доступен из production frontend.
Planned frontend hosting: Netlify Free.
Supabase project URL задан в пользовательском контексте, но реальные keys нельзя добавлять в репозиторий.

# Requirements
1. Не менять бизнес-логику приложения на первом шаге.
2. Предложить Netlify как static hosting для Flutter Web.
3. Объяснить backend = Supabase, frontend = Flutter Web static build, hosting = Netlify.
4. Описать production build command `flutter build web --release`.
5. Описать build output `build/web`.
6. Обновить README, backend documentation, development report, prompts and deployment docs.
7. Не добавлять реальные Supabase keys.
```

Результат:

- создан `docs/frontend_deployment.md` с планом Netlify Free deployment;
- `README.md` получил раздел Frontend Production Deployment;
- `backend_documentation.md` дополнен production split и Netlify build шагом;
- `development_report.md` обновлен Netlify hosting decision и командой production build;
- реальные Supabase keys не добавлялись;
- Flutter бизнес-логика и UI не изменялись.

## Prompt 46 — Netlify production config

```markdown
# Role
Ты Flutter Web Release Engineer и Netlify Deployment Specialist.

# Task
Добавь конфигурацию Netlify для production-развертывания Flutter Web приложения PetConnect.

# Requirements
1. Создай `netlify.toml`.
2. Build command должен передавать `USE_SUPABASE_BACKEND=true`, `SUPABASE_URL=$SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY`.
3. Publish directory: `build/web`.
4. SPA redirect: `/* -> /index.html 200`.
5. Не записывай реальный `SUPABASE_PUBLISHABLE_KEY` в файлы.
6. Обнови README, frontend deployment docs, backend documentation, development report and prompts.
7. Добавь fallback для Netlify без Flutter SDK: локальный build и ручной deploy `build/web`.
```

Результат:

- добавлен `netlify.toml` с production build command, publish directory `build/web` и SPA redirect;
- `README.md` получил раздел Netlify deployment с Environment Variables, build command, publish directory и redirects;
- `docs/frontend_deployment.md` расширен пошаговой инструкцией Git-based Netlify deploy и manual drag-and-drop fallback;
- `backend_documentation.md` дополнен frontend deployment section для Netlify;
- `development_report.md` обновлен записью о Netlify production configuration;
- реальные Supabase keys не добавлялись в repository files.

## Prompt 47 — migrate Supabase frontend key to publishable key

```markdown
# Role
Ты Supabase Security Reviewer, Flutter Web Release Engineer и OpenAI Codex AI coding agent.

# Task
Обнови проект PetConnect с legacy Supabase client-key terminology на новый Supabase Publishable Key.

# Requirements
1. Замени старую frontend-переменную ключа на `SUPABASE_PUBLISHABLE_KEY`.
2. Flutter config должен читать `USE_SUPABASE_BACKEND`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`.
3. Переименуй старое config-поле ключа в `supabasePublishableKey`.
4. В `Supabase.initialize` передавай publishable key и называй его publishable key в коде/документации.
5. Mock mode должен запускаться без Supabase credentials.
6. Обнови README, backend documentation, Supabase security/setup/API docs, frontend deployment docs, Netlify config, `.env.example`, development report and prompts.
7. Не записывай реальный publishable key, secret key или service role key в файлы проекта.
```

Результат:

- `BackendConfig` обновлен на `SUPABASE_PUBLISHABLE_KEY` и `supabasePublishableKey`.
- `initializeSupabaseApp()` передает publishable key в Supabase Flutter SDK.
- Startup error text обновлен под `SUPABASE_PUBLISHABLE_KEY`.
- Тестовые конфигурации переведены на `supabasePublishableKey`.
- `.env.example` содержит только placeholders: `USE_SUPABASE_BACKEND=true`, `SUPABASE_URL=<your-supabase-url>`, `SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>`.
- `netlify.toml` и deployment docs используют `--dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY`.
- README и security docs явно запрещают Supabase secret key/service role key во Flutter Web и фиксируют RLS как security boundary.
- Реальный publishable key из задания не записывался в repository files.

## Prompt 48 — актуализация production deployment plan

```markdown
# Role
Ты Release Engineer, Flutter Web Developer и OpenAI Codex AI coding agent.

# Task
Добавь в проект план production-развертывания Flutter Web приложения PetConnect.

# Project inputs
- GitHub repository: https://github.com/SofrikX/otus_hw4/tree/hw5-sb
- Planned frontend hosting: Netlify Free
- Supabase project URL: https://<project-ref>.supabase.co

# Requirements
1. Не менять бизнес-логику приложения.
2. Объяснить Netlify Free как static hosting для Flutter Web.
3. Описать frontend = Flutter Web static build, hosting = Netlify, backend = Supabase.
4. Описать `flutter build web --release` и output `build/web`.
5. Обновить README, backend documentation, development report, prompts and frontend deployment docs.
6. Не добавлять реальные Supabase keys.
```

Результат:

- Прочитаны required files: README, backend docs, development report, prompts, Supabase setup/security/API docs, `pubspec.yaml`, `web/`, `lib/core/config/`, `lib/core/supabase/`, `lib/app/`.
- `docs/frontend_deployment.md` уточнен под GitHub branch `hw5-sb`, Netlify Free, Supabase project URL, Netlify environment variables and manual `build/web` fallback.
- `README.md` и `backend_documentation.md` синхронизированы с frontend production architecture and build-time Supabase configuration.
- `development_report.md` получил отдельную запись о frontend production target.
- Flutter business logic, UI, migrations and real Supabase keys не менялись.

## Prompt 49 — Netlify production deployment configuration refresh

```markdown
# Role
Ты Flutter Web Release Engineer и Netlify Deployment Specialist.

# Task
Добавь конфигурацию Netlify для production-развертывания Flutter Web приложения PetConnect.

# Project inputs
GitHub repository:
https://github.com/SofrikX/otus_hw4/tree/hw5-sb

Supabase project URL:
https://<project-ref>.supabase.co

Important:
Не записывай реальный SUPABASE_PUBLISHABLE_KEY в файлы.
Netlify должен получать SUPABASE_URL и SUPABASE_PUBLISHABLE_KEY через Environment Variables в UI.

# Requirements
1. Создай `netlify.toml`.
2. Настрой build command для Flutter Web.
3. Publish directory: `build/web`.
4. Добавь redirect rule для SPA: `/* -> /index.html 200`.
5. Build command должен использовать Netlify environment variables `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY`.
6. Flutter build command должен передавать:
   - `--dart-define=USE_SUPABASE_BACKEND=true`
   - `--dart-define=SUPABASE_URL=$SUPABASE_URL`
   - `--dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY`
7. Не хардкодь реальные Supabase values.
8. Обнови README, docs/frontend_deployment.md, backend_documentation.md, development_report.md и prompts.md.
9. Документация должна содержать manual drag-and-drop fallback, если Netlify build environment не содержит Flutter SDK.
```

Результат:

- Подтвержден `netlify.toml` с production Flutter Web build command, publish directory `build/web` и SPA redirect на `/index.html`.
- Проверены README, `docs/frontend_deployment.md`, `backend_documentation.md`, `development_report.md`, `pubspec.yaml`, `web/index.html`, `lib/core/config/` и `lib/core/supabase/`.
- Документация содержит GitHub branch `hw5-sb`, production Supabase URL, Netlify Environment Variables, build command, publish directory, SPA redirects и manual deploy fallback.
- `prompts.md` дополнен этой записью с актуальными project inputs и результатом.
- Реальный `SUPABASE_PUBLISHABLE_KEY` не записывался в repository files.

## Prompt 50 — security review production environment variables

```markdown
# Role
Ты Security Reviewer и Flutter Web Release Engineer.

# Task
Проверь production environment variables для Flutter Web deployment.

# Context
Flutter Web build получает Supabase configuration через dart-define.
Нужно убедиться, что в репозиторий не попали реальные secrets и что README корректно объясняет, какие значения публичные, а какие нельзя коммитить.

# Requirements
1. Проверь `.env.example`, `.gitignore`, `netlify.toml`, `lib/core/config/` и `lib/core/supabase/`.
2. Убедись, что frontend использует только `SUPABASE_URL` и `SUPABASE_PUBLISHABLE_KEY`.
3. Проверь, что service role key не используется во Flutter Web.
4. Проверь grep по `service_role`, `SUPABASE_SERVICE`, `sb_secret_`, `SUPABASE_ANON_KEY`, `supabase.co`.
5. Обнови документацию, `development_report.md` и `prompts.md`.
```

Результат:

- Подтверждено, что `.env.example` содержит только `USE_SUPABASE_BACKEND=true`, `SUPABASE_URL=<your-supabase-url>` и `SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>`.
- `.gitignore` игнорирует реальные `.env` и `.env.*`; tracked set содержит только `.env.example`.
- Локальный `.env.deploy` найден как ignored файл и не попадает в commit.
- Flutter config читает Supabase values через `String.fromEnvironment`, а `Supabase.initialize` получает только `publishableKey`.
- Service role key, `SUPABASE_SERVICE` и `sb_secret_` в tracked frontend/config files не обнаружены.
- README и `docs/frontend_deployment.md` усилены пояснением, что publishable key публичен в Flutter Web bundle, а безопасность обеспечивают Supabase Auth, RLS и Storage policies.

## Prompt 51 — production Flutter Web build against Supabase

```markdown
# Role
Ты Flutter Web QA Engineer.

# Task
Проведи production build Flutter Web приложения PetConnect против Supabase backend.

# Project inputs for local command only
Supabase project URL:
https://<project-ref>.supabase.co

Supabase publishable key:
<production-supabase-publishable-key>

Important:
Используй Supabase publishable key только для локальной команды build/run.
Не записывай реальный key в README.md, backend_documentation.md, prompts.md, docs, .env.example, netlify.toml или исходный код.

# Required reading
Прочитай:
- README.md
- docs/frontend_deployment.md
- backend_documentation.md
- development_report.md
- prompts.md
- pubspec.yaml
- web/
- lib/

# Commands to run
Выполни:
- flutter pub get
- dart format .
- flutter analyze
- flutter test
- flutter build web --release --dart-define=USE_SUPABASE_BACKEND=true --dart-define=SUPABASE_URL=[ВСТАВИТЬ_SUPABASE_PROJECT_URL] --dart-define=SUPABASE_PUBLISHABLE_KEY=[ВСТАВИТЬ_SUPABASE_PUBLISHABLE_KEY]

# Requirements
1. Если build успешен, зафиксируй:
   - build output: build/web;
   - command used, но в документации с placeholders, не с реальным ключом;
   - target backend: Supabase.
2. Если build падает, исправь минимально.
3. Не коммить build/web, если он не должен быть в git.
4. Обнови development_report.md.
5. Обнови prompts.md.
6. Обнови README, если команда запуска/сборки была неточной.
7. Не записывай реальные Supabase keys в docs.
```

Результат:

- Прочитаны required files и project routing docs.
- Выполнены `flutter pub get`, `dart format .`, `flutter analyze`, `flutter test`.
- Проверки прошли: format без изменений, analyzer без замечаний, полный тестовый набор `69 tests passed`.
- Production build против Supabase backend выполнен успешно командой `flutter build web --release --dart-define=USE_SUPABASE_BACKEND=true --dart-define=SUPABASE_URL=<production-supabase-project-url> --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>`.
- Build result: `✓ Built build/web`.
- `build/web` подтвержден как ignored artifact и не должен коммититься.
- README не менялся, потому что существующая build command была корректной.
- Реальный publishable key использовался только в локальной CLI-команде и не записывался в repository files.

## Prompt 52 — Netlify secrets scanning cleanup

```markdown
Отвечай на русском.

Netlify deploy падает:
Secrets scanning found secret env var `SUPABASE_URL`.
Scanner нашел реальное значение в README.md, backend_documentation.md, development_report.md, docs/frontend_deployment.md и prompts.md.

Нужно исправить репозиторий так, чтобы:
1. Реальный Supabase project URL не был записан в tracked docs.
2. Flutter Web deploy на Netlify не падал из-за ожидаемого public client config в build output.
3. Service role key, database password и private tokens не добавлялись во frontend и не скрывались от scanner.
4. Документация объясняла это решение.
```

Результат:

- Реальный Supabase project URL заменен в tracked documentation на `https://<project-ref>.supabase.co`.
- В `netlify.toml` добавлен `SECRETS_SCAN_OMIT_KEYS = "SUPABASE_URL,SUPABASE_PUBLISHABLE_KEY"` для публичных Flutter Web client settings.
- README, `backend_documentation.md` и `docs/frontend_deployment.md` дополнены security note про Netlify secrets scanning.
- `development_report.md` обновлен разделом `Netlify secrets scanning cleanup`.

## Prompt 53 — Final production E2E release review

```markdown
# Role
Ты QA Engineer и Release Reviewer.

# Task
Проведи финальную end-to-end проверку production версии PetConnect.

# Project inputs
GitHub repository:
https://github.com/SofrikX/otus_hw4/tree/hw5-sb

Production frontend URL:
https://cool-duckanoo-d28d04.netlify.app

Supabase project URL:
https://fivtpxsjcjirddogngtl.supabase.co

Supabase project status:
Healthy

# Required reading
Прочитай README.md, backend_documentation.md, docs/frontend_deployment.md,
docs/supabase_setup.md, docs/seed_data.md, docs/supabase_security.md,
development_report.md, prompts.md и lib/features/.

# Manual checks
Проверь production URL, регистрацию, вход, feed, post, like, comment,
pet profile, walks, join walk, errors, mobile и desktop layouts.

# Requirements
Обнови README.md, backend_documentation.md, development_report.md и prompts.md.
Не добавляй secrets.
```

Результат:

- Production URL открылся, Flutter Web shell и auth screen доступны.
- Production bundle проверен: используется Supabase URL `https://fivtpxsjcjirddogngtl.supabase.co` и public publishable key.
- Регистрация через fresh email заблокирована Supabase email rate limit: `over_email_send_rate_limit`.
- Seed demo user `demo.alina@petconnect-demo.com` успешно логинится через Supabase Auth API.
- UI login с demo credentials приводит к переходу на `/`, после чего production frontend падает на белый экран.
- Browser console показывает `Null check operator used on a null value` и `Cannot read properties of undefined (reading 'init')`.
- Backend Supabase REST smoke checks прошли: database не пустая, comment insert `201`, like insert `201`, walk join `201`.
- Локальный минимальный fix применен в `web/index.html`: Corbado/passkeys bundle загружается перед `flutter_bootstrap.js`.
- После fix выполнены `flutter analyze` и `flutter test`; analyzer без замечаний, `69 tests passed`.
- README, `backend_documentation.md`, `development_report.md` и `prompts.md` обновлены итогами release review.

## Prompt 54 — HW6 CI/CD and service integrations planning

```markdown
# Role
Ты OpenAI Codex, AI coding agent, DevOps Engineer и Flutter/Supabase Release Architect.

# Task
Подготовь проект PetConnect к выполнению ДЗ «Настройка CI/CD и интеграция сервисов».

# Context
PetConnect уже реализован как Flutter Web приложение с Supabase backend и Netlify deployment.

Текущий стек:
- Flutter Web
- Dart
- Riverpod
- go_router
- Material 3
- Supabase Auth
- Supabase PostgreSQL
- RLS policies
- Supabase Storage
- Netlify hosting
- OpenAI Codex как AI-агент разработки

Новое ДЗ требует:
1. CI/CD pipeline.
2. Security audit.
3. OAuth2 integration.
4. Analytics integration.
5. Monitoring.
6. Logging.
7. Testing and optimization.
8. Documentation:
   - integration_documentation.md
   - security_audit.md

# Project inputs
GitHub repo:
https://github.com/SofrikX/otus_hw4/tree/hw6

Production frontend:
https://cool-duckanoo-d28d04.netlify.app

Supabase project URL:
https://fivtpxsjcjirddogngtl.supabase.co

# Required reading
Прочитай:
- README.md
- backend_documentation.md
- development_report.md
- prompts.md
- AGENTS.md
- pubspec.yaml
- netlify.toml
- supabase/
- lib/
- test/
- docs/

# Requirements
1. Не меняй код на первом шаге.
2. Составь план выполнения ДЗ на базе текущего проекта.
3. Подтверди, какие части уже реализованы:
   - Netlify deployment;
   - Supabase backend;
   - auth через email/password;
   - RLS;
   - документация;
   - AI workflow.
4. Определи, что нужно добавить:
   - GitHub Actions CI/CD;
   - Google OAuth через Supabase Auth;
   - analytics;
   - health check;
   - logging;
   - security audit;
   - integration_documentation.md;
   - security_audit.md.
5. Платежи отметить как optional и не реализовывать, если они не требуются продуктом.
6. Предложи структуру новых файлов.
7. Обнови prompts.md, добавив этот prompt.
8. Не добавляй реальные secrets.

# Output format
1. Current status.
2. Homework gap analysis.
3. Proposed integrations.
4. Files to create.
5. Risks.
6. Next Codex task.
```

Результат:

- Выполнен первый planning pass без изменений Flutter-кода, Supabase migrations или Netlify config.
- Прочитаны проектные правила, README, backend documentation, development report, prompts, pubspec, Netlify config, Supabase migrations, срез `lib/`, `test/` и `docs/`.
- Подтверждено, что база HW5 уже содержит Netlify deployment config, Supabase backend, email/password auth, RLS, Storage policies, тесты, документацию и AI workflow.
- Для HW6 определены gaps: GitHub Actions CI/CD, Google OAuth через Supabase Auth, privacy-friendly analytics, health check, structured logging/monitoring, security audit и новые документы `integration_documentation.md`, `security_audit.md`.
- Реальные secrets не добавлялись.

## Prompt 55 — GitHub Actions CI/CD for Flutter Web and Netlify

```markdown
# Role
Ты DevOps Engineer и GitHub Actions Specialist.

# Task
Создай CI/CD pipeline для Flutter Web проекта PetConnect.

# Context
Приложение уже деплоится на Netlify.
Нужно настроить GitHub Actions pipeline, который при push в main:
- устанавливает Flutter;
- загружает зависимости;
- проверяет форматирование;
- запускает analyze;
- запускает tests;
- собирает Flutter Web release;
- деплоит на Netlify.

# Project inputs
GitHub repo:
https://github.com/SofrikX/otus_hw4/tree/hw6

Netlify production site:
https://cool-duckanoo-d28d04.netlify.app/

# Required reading
Прочитай:
- README.md
- netlify.toml
- pubspec.yaml
- test/
- .gitignore
- docs/frontend_deployment.md, если есть

# Requirements
1. Создай GitHub Actions workflow:
   - `.github/workflows/ci_cd.yml`
2. Pipeline должен запускаться:
   - on pull_request;
   - on push to main.
3. Этапы:
   - checkout;
   - setup Flutter stable;
   - flutter pub get;
   - dart format --set-exit-if-changed .;
   - flutter analyze;
   - flutter test;
   - flutter build web --release with dart-defines;
   - deploy to Netlify only on push to main.
4. Используй GitHub repository secrets:
   - NETLIFY_AUTH_TOKEN;
   - NETLIFY_SITE_ID;
   - SUPABASE_URL;
   - SUPABASE_PUBLISHABLE_KEY.
5. Не записывай значения secrets в workflow.
6. Добавь caching, если это безопасно и не усложняет workflow.
7. Обнови README.md:
   - как работает CI/CD;
   - какие secrets нужно добавить;
   - что проверяет pipeline.
8. Создай или обнови `integration_documentation.md`:
   - раздел CI/CD.
9. Обнови development_report.md:
   - AI использован для генерации CI/CD.
10. Обнови prompts.md.

# Expected build command
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=${{ secrets.SUPABASE_PUBLISHABLE_KEY }}

# Deploy
Используй Netlify CLI или официальный подход через npm/npx.
Deploy должен использовать:
- NETLIFY_AUTH_TOKEN
- NETLIFY_SITE_ID
- build/web

# Restrictions
1. Не коммить build/web.
2. Не добавляй реальные secrets.
3. Не отключай tests ради зеленого pipeline.

# Output format
1. Summary.
2. Workflow created.
3. Required GitHub secrets.
4. Files changed.
5. Commands to test locally.
6. Diff.
```

Результат:

- Создан `.github/workflows/ci_cd.yml`.
- Workflow запускается на `pull_request` и `push` в `main`.
- Pipeline устанавливает Flutter stable, использует cache, выполняет `flutter pub get`, format check, analyze, tests и Flutter Web release build.
- Deploy to Netlify выполняется только на `push` в `main` через `npx netlify-cli deploy --prod --dir=build/web`.
- Workflow ссылается только на GitHub repository secrets: `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`.
- README, `integration_documentation.md` и `development_report.md` обновлены.
- Реальные secrets и `build/web` не добавлялись.

## Prompt 56 — Security Audit for Flutter, Supabase and Dependencies

```markdown
# Role
Ты Security Auditor, Flutter Reviewer и Supabase Security Engineer.

# Task
Проведи аудит безопасности проекта PetConnect и создай `security_audit.md`.

# Required checks
- hardcoded secrets;
- service role key / `sb_secret_`;
- real Supabase publishable key in docs;
- `.env` in git;
- RLS policies;
- OAuth redirect URLs;
- XSS risks in Flutter Web;
- SQL injection risks in Supabase queries;
- insecure logging;
- dependency risks;
- `flutter pub outdated`;
- `flutter analyze`;
- grep checks for secrets;
- `npm audit` when package.json exists;
- GitHub/Netlify secret scanning notes;
- OWASP mapping for Injection, Broken Auth, Sensitive Data Exposure, Security Misconfiguration and XSS.

# Documentation updates
Update README.md, integration_documentation.md, development_report.md and prompts.md.
```

Результат:

- Создан `security_audit.md`.
- Проверены Flutter, Supabase migrations/config, Netlify config, GitHub Actions, historical Firebase Functions package dependencies, tracked docs/source and ignored env behavior.
- Service role key, `sb_secret_`, private token-like values and real publishable key strings in tracked source/docs не найдены.
- Подтверждено, что service role key не используется во frontend, а `SUPABASE_PUBLISHABLE_KEY` используется как public frontend config.
- Усилены RLS policies для `posts`, `comments`, `post_likes` и `walk_participants`.
- Исправлены exact redirect URLs в `supabase/config.toml`.
- `functions/package.json` и `functions/package-lock.json` обновлены: `npm audit` после fix возвращает `found 0 vulnerabilities`.
- README получил security audit commands.
- `integration_documentation.md` получил security audit summary.
- `development_report.md` получил раздел Security Audit.
- `flutter analyze`: `No issues found!`.
- `supabase db lint`: заблокирован, потому что local Supabase Postgres на `127.0.0.1:54322` не запущен.
