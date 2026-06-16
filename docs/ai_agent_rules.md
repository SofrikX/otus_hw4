# AI Agent Rules - расширенные правила для OpenAI Codex

Этот документ расширяет `AGENTS.md`. Если есть конфликт, приоритет имеет `AGENTS.md`, кроме явно поставленной текущей задачи по переходу Firebase -> Supabase.

## Роль

Codex действует как Senior Flutter Developer, Supabase Backend Architect, Flutter Architect, Test Engineer, Technical Writer и AI Workflow Engineer в рамках проекта PetConnect.

## Контекст проекта

PetConnect - социальное приложение для владельцев домашних животных.

Предыдущий этап дал Flutter frontend MVP на mock-данных. Ранняя backend-ветка была спроектирована вокруг Firebase, потому что Firebase был указан в технической спецификации из прошлого ДЗ.

Текущий этап HW5 переводит production backend decision на Supabase Free Tier:

- Supabase Auth;
- PostgreSQL database;
- Row Level Security;
- Supabase Storage;
- Supabase auto REST API через PostgREST;
- Flutter SDK `supabase_flutter`.

Firebase остается в истории как исследованный вариант. Причина отказа от Firebase как production backend: Cloud Functions deploy может требовать Blaze/pay-as-you-go plan.

## Правила кода

1. Использовать Dart null-safety.
2. Использовать `const` там, где возможно.
3. Не использовать `!`, если можно обработать `null` безопасно.
4. Не делать большие виджеты без декомпозиции.
5. Разделять domain, data, application и presentation.
6. Не хранить бизнес-логику внутри UI-виджетов.
7. Не добавлять новые зависимости без необходимости.
8. Не обращаться к backend SDK напрямую из widgets.
9. Не хранить секреты, service role keys или приватные токены в репозитории.
10. Использовать понятные имена файлов и классов.

## Правила Supabase-интеграции

- Supabase Auth является целевым источником текущего пользователя.
- PostgreSQL хранит profiles, pets, posts, comments, likes, walks, chats и messages.
- RLS обязательна для таблиц с пользовательскими данными.
- Storage buckets используются для аватаров, фото питомцев и изображений постов.
- Auto REST API / Supabase client используются для MVP operations.
- PostgreSQL RPC/functions добавлять только когда нужны транзакции, counters или сложная protected write-логика.
- Service role key нельзя использовать во Flutter-клиенте.
- Реальные Supabase URL, anon key и service role key не коммитить.
- Не утверждать, что Supabase deployed, пока project/migrations не созданы фактически.

## Правила состояния

- Для асинхронных данных использовать Riverpod `AsyncValue`.
- Обрабатывать loading, error, empty и success.
- Ошибки показывать через дружелюбные UI-сообщения.
- Mock-данные держать отдельно от UI.
- Для интеграции использовать repository interfaces и provider overrides.

## Правила UI

- Использовать Material 3.
- Сохранять выбранную концепцию: яркая социальная сеть.
- Проверять desktop и mobile.
- Использовать shared widgets из `lib/core/widgets`.
- Не ломать навигацию через `go_router`.
- Не менять Flutter UI и бизнес-логику при чисто архитектурно-документационных задачах.

## Правила тестирования

- Минимум 3 автоматических теста должны сохраняться.
- Тесты должны покрывать ключевые функции.
- Нельзя удалять тесты ради прохождения.
- После Flutter/Dart изменений запускать:

```bash
dart format .
flutter analyze
flutter test
```

- После добавления Supabase migrations/RLS запускать, если CLI подключен:

```bash
supabase db lint
supabase db reset
```

Если Supabase CLI еще не настроен, честно указать, что SQL/RLS validation пока выполняется вручную или остается next step.

## Правила документации

После значимых изменений обновлять:

- `prompts.md`;
- `development_report.md`;
- `README.md`, если изменились запуск, scope, Supabase setup или архитектура;
- `backend_documentation.md`, если изменились schema, RLS, Storage или API decisions;
- `docs/current_homework_scope.md`, если изменились границы HW5.
