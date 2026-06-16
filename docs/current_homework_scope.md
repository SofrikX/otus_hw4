# Scope текущего ДЗ — HW5 Backend и интеграция с Frontend

## Основа

Текущее ДЗ выполняется в новом репозитории `otus_hw5` на основе Flutter frontend MVP PetConnect из предыдущего этапа.

Оригинальное задание предлагает Supabase или self-hosted PostgreSQL. Для PetConnect backend адаптируется на Firebase, потому что Firebase уже выбран в техническом задании проекта из ДЗ 3.

## AI-агент

Используется OpenAI Codex.

Основной файл правил для агента: `AGENTS.md`.

## Стек

- Flutter
- Dart
- Riverpod
- go_router
- Material 3
- feature-first + Clean Architecture principles
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Cloud Functions
- Firebase Security Rules
- Firebase Emulator Suite
- flutter_test
- mocktail
- npm test для Cloud Functions и emulator-сценариев

## Firebase mapping вместо Supabase/PostgreSQL

| Оригинальное задание | PetConnect HW5 |
|---|---|
| Supabase Auth | Firebase Auth |
| Supabase Database / PostgreSQL tables | Cloud Firestore collections |
| SQL schema and migrations | Firestore schema, indexes, seed data, rules |
| Supabase Storage | Firebase Storage |
| Edge Functions / backend API | Cloud Functions callable/HTTPS API |
| Row Level Security | Firebase Security Rules |
| Local Supabase stack | Firebase Emulator Suite |

Supabase упоминается только как технология из оригинального текста задания. В реализации PetConnect используется Firebase для согласованности с ТЗ.

## 9 шагов текущего ДЗ

1. **Аудит frontend MVP и документации.**
   Проверить текущие функции PetConnect, структуру `lib/`, тесты, README, отчет и правила Codex.

2. **Адаптация backend-стека.**
   Зафиксировать замену Supabase/PostgreSQL на Firebase: Auth, Firestore, Storage, Cloud Functions, Security Rules, Emulator Suite.

3. **Проектирование Firestore schema.**
   Описать коллекции `users`, `pets`, `posts`, `comments`, `chats`, `messages`, `walks`, связи между документами, индексы и ограничения.

4. **Проектирование Storage structure.**
   Описать хранение фото питомцев и изображений постов, правила путей, ограничения типа файла и размера.

5. **Проектирование Cloud Functions API.**
   Реализовать или подготовить минимум 3 backend/API операции, например `postsToggleLike`, `commentsCreate`, `walksJoin`, `messagesSend`, `postsCreate`.

6. **Security Rules.**
   Подготовить Firestore и Storage rules: доступ только авторизованным пользователям, владелец управляет своими питомцами, участники видят свои чаты, защищенные счетчики меняются через backend.

7. **Frontend integration.**
   Заменить прямую зависимость от mock data на repository interfaces и Firebase/mock implementations. UI должен работать через Riverpod controllers/providers.

8. **Локальная проверка через Emulator Suite.**
   Настроить и описать запуск Firebase Auth/Firestore/Storage/Functions emulators. Production deploy Cloud Functions не является обязательным для локальной сдачи.

9. **Документирование AI workflow и результатов.**
   Обновить `prompts.md`, `development_report.md`, `README.md`, `docs/ai_workflow.md`, зафиксировать prompts, ошибки, логи, решения и выводы.

## Что входит в HW5 scope

1. Firebase architecture для PetConnect.
2. Firestore collections и индексы.
3. Security Rules для Firestore и Storage.
4. Cloud Functions API минимум для 3 операций.
5. Firebase Emulator Suite как локальный backend.
6. Repository layer для frontend integration.
7. Сохранение существующих Flutter tests.
8. Backend tests для functions/rules, если functions уже добавлены.
9. Документация процесса через OpenAI Codex.

## Что не входит в обязательный scope

- Платные сервисы.
- Хранение секретов в репозитории.
- Production deploy Cloud Functions без явного запроса.
- Firebase Blaze plan как обязательное условие проверки.
- Push-уведомления FCM, если они не нужны для минимальной HW5-интеграции.
- Полная переработка UI.
- Замена Flutter или Firebase на другой стек.

## Обязательные артефакты сдачи

- GitHub-репозиторий `otus_hw5`.
- Код Flutter-приложения.
- Firebase config/rules/functions files, когда backend-часть реализована.
- `README.md` с запуском Flutter и Firebase Emulator Suite.
- `development_report.md`.
- `prompts.md`.
- `AGENTS.md`.
- Минимум 3 frontend/backend теста или существующие frontend tests плюс backend tests.
- Инструкции по локальному запуску и проверке.

## Критерии готовности

- В документации основным AI-агентом указан OpenAI Codex.
- Firebase указан как backend-решение PetConnect.
- Supabase/PostgreSQL упоминаются только как исходное предложение задания, замененное на Firebase.
- Firestore schema и Security Rules описаны или реализованы.
- Cloud Functions API содержит минимум 3 операции или подготовленный план их реализации.
- Frontend получает данные через repository layer, а не напрямую из UI.
- Локальный emulator-сценарий описан.
- Команды проверки задокументированы.
- Существующие Flutter tests не удалены ради прохождения.
