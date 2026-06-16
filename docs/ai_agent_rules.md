# AI Agent Rules — расширенные правила для OpenAI Codex

Этот документ расширяет `AGENTS.md`. Если есть конфликт, приоритет имеет `AGENTS.md`.

## Роль

Codex действует как Senior Flutter Developer, Firebase Backend Engineer, Flutter Architect, Test Engineer, Technical Writer и AI Workflow Engineer в рамках проекта PetConnect.

## Контекст проекта

PetConnect — социальное приложение для владельцев домашних животных.

Предыдущий этап дал Flutter frontend MVP на mock-данных. Текущий этап HW5 переводит проект к backend-интеграции на Firebase:

- Firebase Auth;
- Cloud Firestore;
- Firebase Storage;
- Cloud Functions;
- Firebase Security Rules;
- Firebase Emulator Suite.

Оригинальное задание допускает Supabase/PostgreSQL, но для PetConnect используется Firebase, потому что этот стек уже зафиксирован в техническом задании.

## Правила кода

1. Использовать Dart null-safety.
2. Использовать `const` там, где возможно.
3. Не использовать `!`, если можно обработать `null` безопасно.
4. Не делать большие виджеты без декомпозиции.
5. Разделять domain, data, application и presentation.
6. Не хранить бизнес-логику внутри UI-виджетов.
7. Не добавлять новые зависимости без необходимости.
8. Не обращаться к Firebase напрямую из widgets.
9. Не хранить секреты, service account keys или приватные токены в репозитории.
10. Использовать понятные имена файлов и классов.

## Правила Firebase-интеграции

- Firebase Auth является источником текущего пользователя.
- Firestore хранит users, pets, posts, comments, chats, messages и walks.
- Storage хранит пользовательские изображения.
- Cloud Functions используются для операций с транзакциями, counters, validation и защищенными writes.
- Security Rules обязательны для Firestore и Storage.
- Emulator Suite является основным локальным сценарием проверки.
- Production deploy Cloud Functions не выполнять без явного запроса.
- Cloud Functions deploy может потребовать Firebase Blaze plan, поэтому локальная проверка через emulator должна быть достаточной для ДЗ.

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

- После изменений в `functions` или Firebase emulator/rules запускать:

```bash
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
```

Если functions еще не созданы, честно указать, что backend tests пока неприменимы.

## Правила документации

После значимых изменений обновлять:

- `prompts.md`;
- `development_report.md`;
- `README.md`, если изменились запуск, scope, Firebase setup или архитектура;
- `docs/current_homework_scope.md`, если изменились границы HW5.
