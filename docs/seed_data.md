# Seed Data — PetConnect Firebase Emulator

## Назначение

Seed-данные нужны, чтобы преподаватель мог запустить локальный Firebase Emulator Suite и увидеть наполненную базу PetConnect без production credentials.

Скрипт:

```text
scripts/seed_firestore.js
```

Скрипт работает только с Firestore Emulator и отказывается запускаться без `FIRESTORE_EMULATOR_HOST`.

## Что создается

Seed соответствует `docs/firestore_schema.md` и создает:

| Коллекция | Количество |
|---|---:|
| `users` | 2 |
| `pets` | 3 |
| `posts` | 4 |
| `posts/{postId}/comments` | 4 |
| `posts/{postId}/likes` | 2 |
| `walks` | 3 |
| `chats` | 1 |
| `chats/{chatId}/messages` | 2 |

Тестовые пользователи:

- `user-anya`
- `user-maksim`

Тестовые питомцы:

- `pet-bruno`
- `pet-mia`
- `pet-rocky`

## Как запустить emulators

Установить зависимости Functions:

```bash
npm install --prefix functions
```

Запустить Firebase Emulator Suite:

```bash
firebase emulators:start
```

Firestore emulator по умолчанию слушает:

```text
127.0.0.1:8080
```

Emulator UI:

```text
http://127.0.0.1:4000
```

## Как выполнить seed

В отдельном терминале из корня проекта:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

Если нужен явный local project id:

```bash
FIREBASE_PROJECT_ID=petconnect-local FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed --prefix functions
```

## Safety

Скрипт не использует `serviceAccount.json`, реальные токены или production credentials.

Защита от случайной записи в production:

- требуется `FIRESTORE_EMULATOR_HOST`;
- используется Firebase Admin SDK только против emulator host;
- project id берется из `FIREBASE_PROJECT_ID` или безопасного fallback `petconnect-local`;
- фиксированные document ids делают повторный запуск idempotent.

Если `FIRESTORE_EMULATOR_HOST` не задан, скрипт завершится ошибкой и ничего не запишет.
