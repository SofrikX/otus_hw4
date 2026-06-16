# Scope текущего ДЗ - HW5 Backend и интеграция с Frontend

## Основа

Текущее ДЗ выполняется на основе Flutter frontend MVP PetConnect из предыдущего этапа.

Оригинальное задание предлагает Supabase или self-hosted PostgreSQL. В ранней технической спецификации PetConnect был указан Firebase, поэтому сначала была исследована Firebase-ветка: Auth, Firestore, Storage, Cloud Functions, Security Rules и Emulator Suite.

На этапе production planning принято архитектурное решение перейти на Supabase Free Tier. Причина: Firebase Cloud Functions production deploy может требовать Blaze/pay-as-you-go plan, а для учебного проекта нужен бесплатный и воспроизводимый backend deployment.

## AI-агент

Используется OpenAI Codex.

Основной файл правил для агента: `AGENTS.md`.

## Актуальный стек HW5

- Flutter
- Dart
- Riverpod
- go_router
- Material 3
- feature-first + Clean Architecture principles
- Supabase Auth
- PostgreSQL database
- Row Level Security
- Supabase Storage
- Supabase auto REST API через PostgREST
- `supabase_flutter`
- flutter_test
- mocktail
- mock repositories для тестов, fallback и постепенной миграции

## Architecture Decision: Firebase to Supabase

Firebase остается в истории проекта как исследованный backend-вариант, основанный на предыдущем ТЗ. Он больше не является выбранным production backend для текущего ДЗ.

Supabase выбран потому что:

- исходное ДЗ прямо поддерживает Supabase;
- Free Tier подходит для учебного production backend;
- PostgreSQL schema и RLS легко проверять и документировать;
- auto REST API снижает потребность в отдельном Cloud Functions/API deployment;
- Flutter SDK позволяет сохранить repository layer без изменения UI.

Supabase project еще не считается созданным. Реальные URL и keys не добавляются.

## Firebase-to-Supabase Mapping

| Firebase-прототип | Supabase HW5 |
|---|---|
| Firebase Auth | Supabase Auth |
| Cloud Firestore | PostgreSQL tables |
| Firestore Security Rules | Row Level Security |
| Cloud Functions API | Supabase auto REST API / Supabase client |
| Firebase Storage | Supabase Storage |
| Firebase Emulator Suite | Supabase project/local validation |

## 9 шагов текущего ДЗ

1. **Аудит frontend MVP и документации.**
   Проверить текущие функции PetConnect, структуру `lib/`, тесты, README, отчет и правила Codex.

2. **Архитектурное решение Supabase вместо Firebase.**
   Зафиксировать, что Firebase был исследованным вариантом, а Supabase выбран для бесплатного production backend.

3. **Проектирование PostgreSQL schema.**
   Описать таблицы `profiles`, `pets`, `posts`, `comments`, `post_likes`, `walks`, `walk_participants`, `chats`, `chat_participants`, `messages`.

4. **Проектирование Supabase Storage.**
   Описать buckets для аватаров, фото питомцев и изображений постов, а также policies доступа.

5. **Проектирование API operations.**
   Использовать Supabase auto REST API / client для минимум 3 операций: создание поста, лайк, присоединение к прогулке, создание питомца или загрузка ленты.

6. **Row Level Security.**
   Подготовить RLS policies: доступ по `auth.uid()`, владелец управляет своими питомцами, автор управляет своими постами, участники видят свои чаты, пользователь изменяет только свои likes/join rows.

7. **Frontend integration.**
   Сохранить UI и бизнес-логику. Перевод backend implementations выполнить через repository interfaces и Riverpod providers.

8. **Validation.**
   Проверять Flutter через `dart format .`, `flutter analyze`, `flutter test`. После добавления Supabase CLI/migrations проверять SQL/RLS через `supabase db lint` и `supabase db reset` или dashboard checks.

9. **Документирование AI workflow и результатов.**
   Обновить `prompts.md`, `development_report.md`, `README.md`, `backend_documentation.md`, `docs/ai_workflow.md`.

## Что входит в HW5 scope

1. Supabase architecture для PetConnect.
2. PostgreSQL schema для основных сущностей.
3. RLS security model.
4. Supabase Storage buckets/policies.
5. Минимум 3 backend/API operations через Supabase client/auto REST.
6. Repository layer для frontend integration.
7. Сохранение существующих Flutter tests.
8. Документация решения Firebase -> Supabase.
9. История Firebase как исследованного варианта без выбора его production backend.

## Что не входит в обязательный scope

- Платные сервисы.
- Хранение секретов в репозитории.
- Firebase Blaze plan как обязательное условие проверки.
- Production deploy Firebase Cloud Functions.
- Замена Flutter на другой frontend stack.
- Полная переработка UI.
- Утверждение, что Supabase уже развернут, до фактического создания проекта.

## Обязательные артефакты сдачи

- GitHub-репозиторий.
- Код Flutter-приложения.
- `README.md` с Supabase architecture decision и запуском Flutter.
- `backend_documentation.md` с PostgreSQL/RLS/Storage/API описанием.
- `development_report.md`.
- `prompts.md`.
- `AGENTS.md`.
- Минимум 3 frontend/backend теста или существующие frontend tests плюс план Supabase validation.
- Инструкции по локальному запуску и проверке.

## Критерии готовности

- В документации основным AI-агентом указан OpenAI Codex.
- Supabase указан как backend-решение PetConnect для текущего ДЗ.
- Firebase сохранен как исследованный вариант, а не как production backend.
- Явно объяснено ограничение Firebase Cloud Functions Blaze/pay-as-you-go.
- Есть раздел `Architecture Decision: Firebase to Supabase`.
- Есть mapping Firebase -> Supabase.
- PostgreSQL schema и RLS model описаны.
- Frontend должен получать данные через repository layer, а не напрямую из UI.
- Существующие Flutter tests не удалены ради прохождения.
