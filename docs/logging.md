# PetConnect Logging and AI Log Analysis

## Logging Strategy

PetConnect uses structured JSON logs for application diagnostics, Netlify health checks and AI-assisted debugging.

Goals:

- make typical production failures easy to filter by `level`, `component` and `event`;
- keep logs useful for Supabase, auth, analytics and health-check debugging;
- avoid secrets, tokens, email addresses, raw user ids, post/comment text and other personal data;
- provide prompt templates for AI analysis without pasting private values into chats or reports.

Log levels:

| Level | Usage |
|---|---|
| `info` | normal lifecycle events such as app startup and Supabase initialization; release builds suppress verbose info logs |
| `warning` | recoverable failures such as auth failure, optional health-check query skipped, degraded service |
| `error` | failed startup, Supabase request errors, analytics dispatch errors, required health-check failure |

Flutter logging is centralized in:

```text
lib/core/logging/app_logger.dart
```

Netlify health logging is implemented in:

```text
netlify/functions/health.js
```

## Structured Format

Flutter log example:

```json
{
  "timestamp": "2026-06-19T12:00:00.000Z",
  "level": "error",
  "component": "supabase",
  "event": "supabase_request_error",
  "message": "Supabase request failed.",
  "details": {
    "operation": "feed.fetchPosts",
    "status_code": 403,
    "error_code": "42501",
    "error_type": "ApiForbiddenException"
  }
}
```

Netlify Function log example:

```json
{
  "level": "warning",
  "message": "Optional posts query was blocked by RLS or API grants",
  "service": "petconnect-health",
  "event": "health_check",
  "check": "supabase_posts_query",
  "httpStatus": 403,
  "durationMs": 214,
  "timestamp": "2026-06-19T12:00:00.000Z"
}
```

Important events currently logged:

| Event | Component | Level |
|---|---|---|
| `app_startup` | `startup` | `info` |
| `app_startup_completed` | `startup` | `info` |
| `app_startup_failed` | `startup` | `error` |
| `supabase_initialization_started` | `supabase` | `info` |
| `supabase_initialization_completed` | `supabase` | `info` |
| `supabase_request_error` | `supabase` | `error` |
| `auth_success` | `auth` | `info` |
| `auth_failure` | `auth` | `warning` |
| `analytics_not_configured` | `analytics` | `warning` |
| `analytics_dispatch_error` | `analytics` | `error` |
| `health_check` | `petconnect-health` | `info`, `warning`, `error` |

## What Not To Log

Never log:

- access tokens, refresh tokens, service role keys, publishable keys, database passwords or OAuth secrets;
- `Authorization`, `apikey`, cookies or raw request headers;
- email addresses, phone numbers, display names, raw user ids or raw object ids;
- profile bio, city, address, post text, comment text, chat messages or image URLs;
- full Supabase environment values or private Netlify/GitHub settings;
- full exception messages when they may contain request payloads.

Allowed diagnostic fields:

- operation names such as `auth.signIn`, `feed.fetchPosts`, `walk.join`;
- status codes, error codes and exception class names;
- boolean configuration flags such as `use_supabase_backend`;
- duration in milliseconds;
- coarse labels such as `method=email` or `method=google`.

## Inspect Netlify Logs

Netlify Dashboard:

1. Open Netlify Dashboard.
2. Select the PetConnect site.
3. Go to `Logs` or `Functions`.
4. Open function logs for `health`.
5. Filter by `level`, `message`, `check` or `event`.

CLI option:

```bash
netlify logs:function health
```

When sharing logs with AI, copy only JSON lines after removing any project-specific URL, token-like string or private deployment metadata.

## Inspect Supabase Logs

Supabase Dashboard:

1. Open Supabase Dashboard.
2. Select the PetConnect project.
3. Use `Logs` for Auth/API/Postgres logs.
4. Check Auth logs for sign-in failures.
5. Check API/PostgREST logs for status codes such as `401`, `403`, `404` and `5xx`.
6. Check Postgres logs for RLS or permission errors such as `42501`.

SQL/RLS validation commands when local Supabase is running:

```bash
supabase db lint
supabase db reset
```

Do not paste JWTs, cookies, Supabase keys, email addresses or full SQL rows into AI tools.

## AI Log Analysis Prompt Templates

Before using these prompts:

- replace real values with placeholders;
- keep only structured fields needed for diagnosis;
- remove email, user ids, tokens, request headers and raw content;
- include expected behavior, actual behavior and recent change context.

### Auth Error Analysis

````markdown
# Role
Ты AI Debugging Specialist и Supabase Auth Engineer.

# Task
Проанализируй sanitized auth logs PetConnect и найди вероятную причину ошибки входа.

# Context
Frontend: Flutter Web.
Auth backend: Supabase Auth.
Logs ниже очищены от email, user id, токенов и персональных данных.

# Logs
```json
[
  {
    "level": "warning",
    "component": "auth",
    "event": "auth_failure",
    "details": {
      "operation": "sign_in",
      "method": "email",
      "error_type": "AuthFailure"
    }
  },
  {
    "level": "error",
    "component": "supabase",
    "event": "supabase_request_error",
    "details": {
      "operation": "auth.signIn",
      "status_code": 401,
      "error_code": "invalid_credentials",
      "error_type": "ApiUnauthorizedException"
    }
  }
]
```

# Requirements
1. Определи наиболее вероятную причину.
2. Раздели frontend, Supabase Auth config и пользовательскую ошибку.
3. Предложи 3 проверки без использования секретов.
4. Не проси реальные токены или email.
````

### RLS Permission Denied Analysis

````markdown
# Role
Ты Supabase RLS Debugging Specialist.

# Task
Проанализируй sanitized logs и объясни, почему операция блокируется RLS.

# Context
PetConnect использует Supabase PostgREST, PostgreSQL RLS и Flutter repositories.

# Logs
```json
[
  {
    "level": "error",
    "component": "supabase",
    "event": "supabase_request_error",
    "details": {
      "operation": "feed.createPost",
      "status_code": 403,
      "error_code": "42501",
      "error_type": "ApiForbiddenException"
    }
  }
]
```

# Requirements
1. Назови вероятную policy или grant проблему.
2. Проверь сценарии: нет session, pet owner mismatch, missing authenticated grant, wrong insert columns.
3. Предложи SQL/RLS checks без service role key.
4. Не проси raw JWT, user id или реальные строки таблиц.
````

### Netlify Deploy Failure Analysis

````markdown
# Role
Ты CI/CD Debugging Specialist для Flutter Web и Netlify.

# Task
Проанализируй sanitized Netlify/GitHub Actions logs и найди причину deploy failure.

# Context
PetConnect деплоит `build/web` на Netlify после `flutter build web --release`.
Secrets очищены и заменены placeholders.

# Logs
```text
<paste sanitized build/deploy log excerpt here>
```

# Requirements
1. Определи, ошибка в Flutter build, env vars, Netlify auth/site id или publish directory.
2. Предложи минимальный fix.
3. Дай команды локальной проверки.
4. Не проси реальные Netlify token, Supabase key или GitHub secrets.
````

### Supabase API Error Analysis

````markdown
# Role
Ты Supabase API Debugging Specialist.

# Task
Проанализируй sanitized Flutter/Supabase API logs для PetConnect.

# Context
Frontend вызывает Supabase через repository layer.
Логи не содержат PII и секретов.

# Logs
```json
[
  {
    "level": "error",
    "component": "supabase",
    "event": "supabase_request_error",
    "details": {
      "operation": "walk.join",
      "status_code": 500,
      "error_code": "PGRST204",
      "error_type": "ApiUnexpectedException"
    }
  }
]
```

# Requirements
1. Классифицируй ошибку: auth, RLS, schema mismatch, PostgREST grant, network, server.
2. Назови вероятные файлы/места проверки в Flutter и Supabase migrations.
3. Предложи безопасные smoke checks.
4. Не проси реальные keys, JWT, emails или database password.
````

### Analytics Event Missing Analysis

````markdown
# Role
Ты Product Analytics QA Engineer.

# Task
Проанализируй, почему analytics event не дошел до Yandex Metrica.

# Context
PetConnect Flutter Web использует `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER`, `ANALYTICS_ID` и JS loader `petconnectTrackAnalytics`.

# Logs
```json
[
  {
    "level": "info",
    "component": "analytics",
    "event": "analytics_disabled",
    "details": {
      "event": "post_created",
      "provider_configured": true,
      "analytics_id_configured": false
    }
  }
]
```

# Requirements
1. Определи, проблема в build-time config, JS loader, provider mismatch или событии приложения.
2. Предложи проверки в Flutter build, `web/index.html` и браузерной console.
3. Укажи, какие поля события безопасны для аналитики.
4. Не проси реальные counter id, email, user id или тексты постов.
````
