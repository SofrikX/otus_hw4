# Deployment Guide — PetConnect Firebase HW5

## Назначение

Документ описывает безопасную подготовку Firebase backend-инфраструктуры для PetConnect.

В репозитории хранятся только шаблоны конфигурации, rules и документация. Реальные project id, токены, service account keys и приватные `.env` файлы не коммитятся.

## Firebase services

В HW5 используются:

- Firebase Auth;
- Cloud Firestore;
- Firebase Storage;
- Cloud Functions;
- Firebase Emulator Suite.

## 1. Установка Firebase CLI

Установить Firebase CLI можно через npm:

```bash
npm install -g firebase-tools
```

Проверить установку:

```bash
firebase --version
```

## 2. Firebase login

Авторизоваться в Firebase CLI:

```bash
firebase login
```

Проверить доступные проекты:

```bash
firebase projects:list
```

## 3. Firebase init

В репозитории уже подготовлены:

- `firebase.json`;
- `.firebaserc.example`;
- `firestore.rules`;
- `firestore.indexes.json`;
- `storage.rules`;
- `.env.example`.

Когда реальный Firebase project будет создан, можно выполнить:

```bash
firebase init
```

Выбрать services:

- Firestore;
- Storage;
- Functions;
- Emulators.

Если Firebase CLI предлагает перезаписать существующие `firestore.rules`, `firestore.indexes.json`, `storage.rules` или `firebase.json`, сначала сравните diff и сохраните текущие правила PetConnect.

Создать локальный `.firebaserc` на основе примера:

```bash
cp .firebaserc.example .firebaserc
```

Затем заменить `your-firebase-project-id` на реальный project id. Сам `.firebaserc` можно держать локально или коммитить только если project id не считается приватным для учебной сдачи. Для безопасного шаблона в репозитории оставлен `.firebaserc.example`.

## 4. Локальный запуск Emulator Suite

Перед запуском emulators установить зависимости Cloud Functions, когда папка `functions/` будет создана:

```bash
npm install --prefix functions
```

Запустить emulators:

```bash
firebase emulators:start
```

Ожидаемые local ports из `firebase.json`:

| Service | Port |
|---|---|
| Auth | `9099` |
| Firestore | `8080` |
| Functions | `5001` |
| Storage | `9199` |
| Emulator UI | `4000` |

Emulator UI:

```text
http://127.0.0.1:4000
```

Для автоматической проверки backend tests:

```bash
firebase emulators:exec "npm test --prefix functions"
```

## 5. Production deploy

Production deploy выполнять только после локальной проверки rules, functions и frontend integration.

Проверить активный project:

```bash
firebase use
```

Deploy rules и indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Deploy functions:

```bash
firebase deploy --only functions
```

Полный deploy Firebase backend:

```bash
firebase deploy
```

## 6. Blaze plan warning

Cloud Functions deploy в production может потребовать Firebase Blaze plan. Для HW5 основной сценарий проверки должен работать локально через Firebase Emulator Suite.

Не делайте production deploy Cloud Functions, если не готовы подключать billing к Firebase project.

## 7. Как не коммитить секреты

Нельзя коммитить:

- `serviceAccount.json`;
- любые `*-service-account.json`;
- реальные `.env`;
- приватные токены;
- Firebase Admin SDK credentials;
- CI secrets;
- debug logs с токенами.

В репозитории допустимы только безопасные placeholders:

- `.env.example`;
- `.firebaserc.example`.

Перед коммитом проверить:

```bash
git status --short
git diff --check
```

Если случайно появился файл с секретами, не коммитьте его. Удалите файл из индекса и перевыпустите скомпрометированный ключ в Firebase/Google Cloud Console.
