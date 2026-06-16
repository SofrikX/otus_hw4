# Supabase Setup - PetConnect HW5

Этот документ описывает, как подключить Supabase project к PetConnect без добавления секретов в репозиторий.

## 1. Создать Supabase project

1. Откройте Supabase Dashboard.
2. Создайте новый project на Free Tier.
3. Выберите регион, близкий к пользователям или проверяющему.
4. Сохраните database password в безопасном password manager, не в git.
5. Дождитесь, пока project перейдет в готовое состояние.

Project еще не создан в репозитории автоматически. Этот шаг выполняется вручную владельцем аккаунта.

## 2. Получить Project URL и client key

В Supabase Dashboard откройте project и найдите Connect/API settings.

Нужны только client-side значения:

- Project URL;
- anon public key или publishable key, если Dashboard показывает новый формат ключей.

В коде и документации проекта env-переменная называется `SUPABASE_ANON_KEY`, даже если в Dashboard ключ называется publishable key. Service role key не использовать во Flutter и не копировать в `.env.example`.

## 3. Настроить локальные переменные

Создайте локальный `.env` или используйте `--dart-define` при запуске Flutter. `.env` уже игнорируется git.

```text
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-public-client-key
USE_SUPABASE_BACKEND=true
```

В репозитории хранится только `.env.example` с пустыми значениями.

## 4. Применить SQL migrations через CLI

Если Supabase CLI установлен и project linked:

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push
```

Локальная проверка после настройки CLI:

```bash
supabase db lint
supabase db reset
```

`supabase db reset` применяет migrations и выполняет `supabase/seed.sql` для локальной базы.

## 5. Применить SQL вручную через Dashboard

Если CLI еще не подключен:

1. Откройте Supabase Dashboard.
2. Перейдите в SQL Editor.
3. Откройте `supabase/migrations/001_initial_schema.sql`.
4. Выполните SQL в project.
5. Проверьте таблицы в Table Editor.
6. Проверьте RLS policies в Authentication/Policies или Table Editor.
7. Проверьте buckets `avatars`, `pet-photos`, `post-images` в Storage.

## 6. Запустить Flutter с Supabase config

Команда запуска после технической миграции Flutter repositories на Supabase:

```bash
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL= \
  --dart-define=SUPABASE_ANON_KEY=
```

Для реального запуска заполните значения локально, но не коммитьте их.

## 7. Что не хранить в git

- `.env`;
- `.env.local`;
- Supabase service role key;
- database password;
- JWT secret;
- personal access token;
- production user data.

## References

- Supabase Flutter quickstart: `https://supabase.com/docs/guides/getting-started/quickstarts/flutter`
- Supabase CLI reference: `https://supabase.com/docs/reference/cli`
