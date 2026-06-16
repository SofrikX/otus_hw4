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
