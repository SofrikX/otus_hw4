# PetConnect Defense Script

Date: 23 June 2026

Документ помогает провести защиту финального проекта PetConnect: кратко объяснить идею, показать приложение, раскрыть архитектуру, AI-assisted workflow, безопасность, CI/CD и production readiness.

## Pitch На 30 Секунд

PetConnect - это полнофункциональное Flutter Web приложение для владельцев домашних животных. Пользователь может войти через Supabase Auth, создать профили питомцев, публиковать посты, ставить лайки, комментировать, искать контент, находить прогулки и загружать фото питомца. Backend построен на Supabase: PostgreSQL, Row Level Security, Storage и auto REST API. Frontend развернут на Netlify, CI/CD работает через GitHub Actions, есть health endpoint, аналитика Yandex Metrica и финальный security/performance audit. AI-агенты использовались на всех этапах: от планирования и архитектуры до QA, security review и документации.

## Основной Рассказ На 5 Минут

1. **Идея и пользовательская ценность.**  
   PetConnect решает простую проблему: у владельцев питомцев часто нет единого места, где можно хранить профиль питомца, делиться обновлениями, искать прогулки и взаимодействовать с другими владельцами. Поэтому проект объединяет pet profiles, feed, comments/likes, walks и базовый chat scenario.

2. **Frontend.**  
   Frontend сделан на Flutter Web, потому что проект уже развивался как Flutter-приложение, а Web-версия хорошо подходит для финальной публичной демонстрации. Архитектура feature-first: `auth`, `feed`, `pets`, `walks`, `chat`, `home`. UI не обращается к backend напрямую: экраны используют Riverpod controllers/providers, а те работают с repository interfaces.

3. **Backend.**  
   Backend выбран Supabase: Auth, PostgreSQL, RLS, Storage и auto REST API. Это позволило сделать полноценный backend без отдельного собственного сервера и без платной serverless-инфраструктуры. PostgreSQL хранит профили, питомцев, посты, комментарии, лайки, прогулки, участников прогулок, чаты и сообщения.

4. **Auth, OAuth и безопасность данных.**  
   Пользователи входят через email/password или Google OAuth через Supabase Auth. Все ключевые таблицы защищены Row Level Security. Например, пользователь может редактировать только своих питомцев, создавать пост только для своего питомца, удалять только свои посты и участвовать в прогулках по owner/user-scoped правилам. UI-проверки помогают UX, но реальная граница безопасности находится в RLS и Storage policies.

5. **Функциональность.**  
   В demo стоит показать: auth screen, feed, создание/открытие поста, лайк/комментарий, Pets, фото питомца, Walks, search/filter, mobile layout. Это покрывает основные CRUD и дополнительные интеграции.

6. **CI/CD и production.**  
   GitHub Actions запускает security gate, форматирование, анализ, тесты, Flutter Web build и deploy на Netlify. Netlify отдаёт Flutter Web build из `build/web`, а `/api/health` работает как Netlify Function и проверяет состояние приложения без раскрытия приватных значений.

7. **AI usage.**  
   OpenAI Codex использовался как product analyst, Flutter/Supabase engineer, QA reviewer, security auditor и technical writer. AI помогал формировать user stories, technical specification, SQL/RLS, Flutter integration, tests, visual redesign, CI/CD, security audit и финальную документацию. Важный момент: human review принимал решения по scope, безопасности и финальным изменениям.

8. **Готовность.**  
   Проект сопровождается README, project documentation, AI development process, prompt journal, security audit, manual QA checklist, testing strategy, submission package и release checklist. Это не только приложение, но и полный пакет финальной сдачи.

## Расширенный Рассказ На 10 Минут

### 1. Контекст И Цель

PetConnect начинался как Flutter MVP с pet social feed, pet profiles, walks и chat screen. Финальная цель была довести его до production-style web application: настоящий backend, authentication, database, authorization, storage, deploy, CI/CD, monitoring, security review и AI-documented development process.

### 2. Почему Flutter Web

Flutter Web выбран по нескольким причинам:

- уже существовала Flutter codebase и feature-first структура;
- Material 3 и responsive widgets позволяют быстро сделать web/mobile-like интерфейс;
- один Dart codebase покрывает UI, state и tests;
- Flutter Web build является static output, поэтому хорошо подходит для Netlify;
- mock repositories позволяют запускать приложение локально без backend credentials.

### 3. Почему Supabase

Supabase выбран как финальный backend, потому что он даёт:

- Supabase Auth и Google OAuth;
- PostgreSQL с миграциями;
- Row Level Security как backend authorization boundary;
- Supabase Storage для фото питомцев;
- auto REST API через PostgREST и удобный `supabase_flutter` client;
- бесплатный и проверяемый hosted backend для учебного проекта.

Firebase рассматривался раньше как историческая ветка, но для финального проекта Supabase оказался лучше из-за SQL/RLS, reviewable migrations и free-tier production constraints.

### 4. Архитектура

Короткая схема:

```text
Flutter UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase or mock repository implementations
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Главный принцип: UI не содержит business logic и не вызывает Supabase напрямую. Это упрощает тестирование и снижает связность.

### 5. Backend И Database

Основные таблицы:

- `profiles`;
- `pets`;
- `posts`;
- `comments`;
- `post_likes`;
- `walks`;
- `walk_participants`;
- `chats`;
- `chat_participants`;
- `messages`.

Основные связи:

- user id из Supabase Auth связан с `profiles.id`;
- питомец принадлежит владельцу через `pets.owner_id`;
- пост связан с автором и питомцем;
- comments и likes связаны с post;
- walk participants связывают пользователя и прогулку;
- chat/message scope ограничен участниками.

### 6. Auth И OAuth

Email/password auth работает через Supabase Auth. Google OAuth тоже идёт через Supabase provider: Flutter вызывает OAuth flow, Supabase обрабатывает provider configuration, браузер возвращается на production или local redirect URL, после чего Flutter восстанавливает session и `go_router` пропускает пользователя в защищённую часть приложения.

На защите можно подчеркнуть: provider secret хранится только во внешних dashboard settings, не в Flutter и не в repository files.

### 7. RLS Policies

RLS - основная защита данных:

- пользователь управляет только своими питомцами;
- пост можно создать только для питомца текущего пользователя;
- удаление поста owner-only;
- comments/likes проверяют видимость target post;
- join прогулки разрешён только для active walk;
- storage upload path должен соответствовать current user и owned pet.

Это важно: даже если кто-то обойдёт UI и попробует вызвать API напрямую, Supabase RLS должен заблокировать чужие данные.

### 8. Storage

Supabase Storage используется для фото питомцев. В UI пользователь выбирает JPG/PNG/WebP до 5 MB. Файл загружается в owner/pet-scoped path, затем `pets.photo_url` обновляется через RLS-protected update. Public read для `pet-images` принят как продуктовая модель: фото питомца может отображаться в профиле.

### 9. Что Улучшено После QA

После QA были усилены:

- CRUD coverage для pets/posts/walks;
- create-post flow, чтобы пост создавался только для питомца текущего пользователя;
- Storage path policy;
- search/filter UI для Feed, Pets и Walks;
- validation и friendly errors;
- analytics sanitizer;
- release-mode logging;
- manual QA checklist и testing strategy.

### 10. Final Visual Redesign

Финальный redesign перевёл приложение в premium dark pet social app style:

- navy/black surfaces;
- violet/blue gradient accents;
- glass cards;
- polished auth, feed, pets, walks, profile и chat screens;
- responsive mobile bottom navigation и desktop navigation rail;
- shared loading/empty/error states.

Важно: redesign не переписал architecture, routing, backend или RLS. Он улучшил presentation layer и portfolio impression.

### 11. CI/CD, Monitoring И Production

GitHub Actions:

- secret scanning/hygiene gate;
- dependency checks;
- format;
- analyze;
- tests;
- Flutter Web release build;
- Netlify deploy.

Netlify:

- publishes `build/web`;
- uses SPA fallback for Flutter routes;
- exposes `/api/health` as Netlify Function.

Monitoring/logging:

- `/api/health` returns status/check metadata, not environment values;
- Flutter and Netlify logs are structured and sanitized;
- release mode suppresses verbose info logs.

### 12. Security Audit

Final security audit covered:

- hardcoded secrets;
- `.env` hygiene;
- service role key leakage risk;
- Google OAuth private data leakage;
- Yandex Metrica privacy;
- RLS and CRUD authorization;
- Storage upload risks;
- health endpoint leakage;
- logs;
- CI/CD secret usage;
- OWASP areas such as injection, broken auth/access control, sensitive data exposure and vulnerable components.

Результат: blocking tracked secret finding не был найден; оставшиеся риски задокументированы как operational/manual checks.

## Demo Flow

1. Открыть production app: `https://cool-duckanoo-d28d04.netlify.app`.
2. Показать landing/auth screen.
3. Войти через email/password или Google OAuth.
4. Показать Feed.
5. Создать новый post или открыть существующий post.
6. Показать like/comment interaction.
7. Показать Pets.
8. Загрузить или показать фото питомца.
9. Показать Walks.
10. Применить search/filter в Feed, Pets или Walks.
11. Показать responsive mobile layout через browser responsive mode или подготовленный screenshot.
12. Показать GitHub Actions workflow и зелёный run.
13. Показать Netlify production deployment status.
14. Показать Supabase tables и Storage bucket без row-level private data и без secrets.
15. Открыть `/api/health`.
16. Показать документацию: `README.md`, `docs/submission_package.md`, `docs/screenshots/README.md`, `ai_development_process.md`, `security_audit.md`, `docs/manual_qa_checklist.md`.

## Экраны Для Показа

| Экран | Что сказать |
|---|---|
| Landing/Auth | Здесь вход через email/password и Google OAuth; protected routes не пускают неавторизованного пользователя в app shell. |
| Feed | Социальная лента, посты, likes/comments, search, create post. |
| Create post form | Форма создаёт пост для питомца текущего пользователя; backend RLS дополнительно проверяет ownership. |
| Pets | CRUD для питомцев, фильтры, переход в профиль. |
| Pet image upload | Supabase Storage flow: validation, upload, public display URL. |
| Walks | Прогулки, фильтры, create/join/leave. |
| Chat | Базовый чат-сценарий и подготовленная relational schema. |
| Mobile layout | Bottom navigation и responsive constraints. |
| GitHub Actions | CI/CD gates перед deploy. |
| Netlify | Production hosting и deploy status. |
| Supabase | Tables, RLS policies, Storage bucket без приватных значений. |
| Health endpoint | Production readiness signal без leakage. |
| Documentation | Пакет сдачи и AI evidence. |

Если live browser demo нестабилен из-за внешних сервисов или OAuth dashboard settings, использовать refreshed screenshots `docs/screenshots/01`-`09` как безопасный visual fallback. Они показывают финальный dark UI без приватных данных.

## Технические Решения

- **Flutter Web**: сохранение существующей Flutter codebase, static web deploy, Material 3, responsive UI.
- **Riverpod + repository layer**: разделение UI, state и data access.
- **Supabase**: hosted Auth/PostgreSQL/RLS/Storage/auto REST API без собственного backend server.
- **RLS**: backend enforcement вместо доверия к UI.
- **Storage**: owner/pet-scoped upload path для фото питомцев.
- **Netlify**: static hosting, SPA fallback, serverless health endpoint.
- **GitHub Actions**: repeatable validation and deploy pipeline.
- **Yandex Metrica**: coarse product analytics with sanitized params.
- **Mock mode**: локальный запуск и тесты без production credentials.

## AI Usage

AI использовался не как автогенератор “вслепую”, а как инженерный помощник:

- planning: превратил требования курса в final project roadmap;
- product: помог сформулировать target audience, problem/solution и demo story;
- specification: структурировал user stories и technical specification;
- backend: помог спроектировать schema, migrations, RLS и Storage policies;
- frontend: помог развивать controllers, repositories, forms, states и tests;
- debugging: помогал разбирать RLS/OAuth/deployment issues по sanitized logs;
- QA: помог составить testing strategy и manual checklist;
- security/performance: провёл финальный audit и предложил безопасные небольшие fixes;
- documentation: помог собрать README, development report, prompt journal, submission package и release checklist.

Human review оставался обязательным: решения по scope, security, production settings и acceptance принимались человеком.

## Security Block

Что важно сказать:

- frontend не использует service role privileges;
- backend authorization обеспечивается Supabase Auth + RLS;
- Storage upload owner/pet-scoped;
- analytics params sanitized;
- logs sanitized;
- health endpoint не возвращает environment values;
- CI блокирует явные secret markers и real env files;
- penetration test не заявлялся, это code/configuration security audit плюс manual QA.

## CI/CD Block

GitHub Actions pipeline:

1. Security audit job.
2. Repository hygiene checks.
3. Dependency checks.
4. `dart format --set-exit-if-changed .`.
5. `flutter analyze`.
6. `flutter test`.
7. Flutter Web release build.
8. Netlify deploy on `main`.

На защите показать `.github/workflows/ci_cd.yml` и последний successful run.

## Monitoring And Logging Block

- `/api/health` - production health endpoint на Netlify Function.
- Проверяет reachability и backend-facing endpoints в bounded way.
- Возвращает только status/check metadata.
- Structured logs помогают анализировать сбои.
- Release mode уменьшает production info-log noise.
- Для AI log analysis используются только sanitized logs.

## Visual Redesign Block

Коротко:

Финальный redesign нужен, чтобы проект выглядел как законченный продукт, а не технический прототип. Были добавлены dark design tokens, gradient accents, glass cards, polished forms, responsive layouts и shared state widgets. При этом не менялись маршрутизация, backend contracts, RLS или core business logic.

## Возможные Вопросы И Ответы

### Почему не делали новый проект с нуля?

Потому что цель была довести существующий Flutter MVP до полноценного production-style web project. Это ближе к реальной разработке: не выбрасывать рабочую codebase, а улучшать архитектуру, подключать backend, добавлять security, QA, deploy и документацию.

### Почему Supabase вместо собственного backend?

Для финального проекта нужен был бесплатный, воспроизводимый и проверяемый backend. Supabase даёт Auth, PostgreSQL, RLS, Storage и auto REST API без отдельного сервера. Собственный backend увеличил бы объём инфраструктуры, но не дал бы пропорционально больше ценности для MVP.

### Почему Supabase вместо Firebase?

Firebase был исторически рассмотрен, но финальная архитектура выбрала Supabase. Причины: SQL migrations, PostgreSQL constraints, RLS, reviewable security model и отсутствие необходимости в платном Cloud Functions layer для MVP.

### Как защищены данные?

Через Supabase Auth и Row Level Security. Пользовательские операции owner-scoped: свои питомцы, свои посты, свои walk participation rows. Storage policies проверяют user/pet path. UI делает проверки для удобства, но настоящая защита находится на backend level.

### Где CRUD?

CRUD покрыт в основных final flows:

- Pets: create/read/update/delete и photo upload;
- Posts: read/create/delete own post, comments and likes;
- Walks: read/create/join/leave;
- Search/filter работает для Feed, Pets и Walks.

Некоторые расширения, например full post edit UI или full chat sending flow, вынесены в future enhancements.

### Как проверяли безопасность?

Проводился финальный security audit: secrets scan, `.env` hygiene, RLS review, CRUD authorization review, Storage upload risks, OAuth redirect notes, analytics privacy, logs, health endpoint, CI/CD secrets usage и OWASP review. Также есть CI security gates и manual QA checklist.

### Как использовался AI?

AI помогал на всех этапах: planning, user stories, technical specification, backend schema/RLS, frontend implementation, tests, debugging, CI/CD, security audit, visual redesign и documentation. Но AI-output проверялся человеком, а sensitive settings и final acceptance не отдавались AI автоматически.

### Как работает деплой?

GitHub Actions запускает проверки и собирает Flutter Web release build. После успешных checks build deploy-ится на Netlify. Netlify отдаёт static Flutter files из `build/web`, а backend запросы идут из браузера в Supabase через `supabase_flutter`.

### Как работает Google OAuth?

Flutter запускает OAuth через Supabase Auth provider. Supabase обрабатывает provider configuration, затем возвращает пользователя на настроенный redirect URL. Flutter восстанавливает session и router открывает защищённые экраны.

### Как работает Storage?

Фото питомца выбирается в Flutter Web, проходит client-side validation по типу и размеру, загружается в Supabase Storage в owner/pet-scoped path, а URL сохраняется в `pets.photo_url`. RLS и Storage policies проверяют ownership.

### Как проверяли стабильность?

Есть automated checks: format, analyze, tests, release build. Есть manual QA checklist для production flows: auth, feed, pets, image upload, walks, filters, mobile layout, `/api/health`, GitHub Actions, Netlify, Supabase dashboard и analytics overview.

### Какие ограничения остались?

Ограничения честно задокументированы:

- Google OAuth dashboard settings требуют manual verification;
- screenshots не должны раскрывать private data;
- post image upload и avatar upload не входят в final core scope;
- full chat sending flow остаётся future enhancement;
- penetration test не проводился.

### Что бы улучшил дальше?

Следующие шаги:

- добавить полноценный chat sending flow;
- добавить post image upload;
- улучшить profile editing;
- добавить automated browser E2E для production-like flows;
- расширить monitoring и alerting;
- добавить CSP после отдельной проверки Flutter Web runtime requirements.

## Финальная Фраза

PetConnect показывает полный цикл разработки web-приложения с AI-агентами: от идеи и user stories до Flutter Web frontend, Supabase backend, RLS security, Storage, CI/CD, Netlify deploy, monitoring, QA, visual redesign и финального submission package. Это не только демо интерфейса, но и проверяемая инженерная работа с документацией, тестами и release readiness.
