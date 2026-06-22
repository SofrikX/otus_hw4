# PetConnect Project Documentation

## Название проекта

PetConnect - полнофункциональное веб-приложение для владельцев домашних животных.

## Идея

PetConnect объединяет социальную ленту питомцев, профили животных, прогулки, базовые чаты и активность сообщества в одном Flutter Web приложении. Пользователь может зарегистрироваться, добавить питомца, публиковать посты, реагировать на публикации, находить прогулки и взаимодействовать с другими владельцами.

## Целевая аудитория

| Аудитория | Потребность |
|---|---|
| Владельцы собак | Найти компанию для прогулок и локальное pet-friendly сообщество |
| Владельцы кошек и других питомцев | Публиковать истории и фото питомцев в тематической ленте |
| Новые владельцы животных | Получить поддержку, идеи активностей и контакты владельцев рядом |
| Активные пользователи социальных сервисов | Использовать привычные механики ленты, лайков, комментариев и сообщений |

## Проблема

Владельцы домашних животных часто используют разные сервисы для общения, публикаций, поиска прогулок и хранения информации о питомцах. Из-за этого локальное pet-сообщество распадается на отдельные каналы, а пользователю сложно быстро найти владельцев рядом, договориться о прогулке или показать профиль питомца.

PetConnect решает эту проблему через единое веб-приложение с авторизацией, профилями питомцев, социальной лентой и прогулками.

## Основные сценарии использования

1. Гость регистрируется по email/password или входит через Google OAuth.
2. Пользователь создает или просматривает профиль питомца.
3. Пользователь открывает ленту и видит публикации питомцев.
4. Пользователь создает пост, ставит лайк и добавляет комментарий.
5. Пользователь открывает список прогулок, создает прогулку или присоединяется к существующей.
6. Пользователь просматривает базовый список чатов и сообщений.
7. Проверяющий открывает production Flutter Web build на Netlify и проверяет Supabase-backed сценарии.

## Final project scope

Финальная проектная работа переводит PetConnect из набора домашних заданий в портфолио-проект курса "Разработка полнофункционального веб-приложения с использованием AI-агентов".

Scope финальной работы:

- оформить PetConnect как цельный продуктовый кейс с идеей, аудиторией, user stories и технической спецификацией;
- сохранить Flutter Web frontend на Material 3, Riverpod и `go_router`;
- использовать Supabase как production backend: Auth, Google OAuth, PostgreSQL, RLS, Storage и auto REST API;
- подтвердить минимум 3 основных экрана: feed, pets, walks, а также auth и chat как дополнительные сценарии;
- обеспечить CRUD/API операции для питомцев, постов, комментариев, лайков и прогулок через repository layer;
- оставить mock repositories только для тестов, fallback и локальной разработки;
- использовать Netlify hosting и GitHub Actions CI/CD для production frontend;
- включить analytics через Yandex Metrica без персональных данных;
- поддержать health check endpoint, structured logging, security audit и AI-assisted debugging;
- зафиксировать AI workflow: planning, design, code generation, tests, debugging, CI/CD, security audit и performance optimization.

Финальные документы требований:

- `user_stories.md` - сгруппированные финальные user stories с acceptance criteria, priority и status;
- `technical_specification.md` - актуальное техническое задание для Flutter Web + Supabase project scope;
- `final_project_gap_analysis.md` - честная проверка Done/Planned/Optional перед финальной сдачей.

Исторические документы `docs/user_stories.md` и `docs/technical_specification.md` сохранены как материалы ранних домашних заданий и Firebase/mobile scope. Для финальной проектной работы приоритет имеют корневые `user_stories.md` и `technical_specification.md`.

## Что уже реализовано

| Область | Реализовано |
|---|---|
| Frontend | Flutter Web MVP с Material 3, адаптивной навигацией, feed, pets, walks, auth и chat screens |
| State management | Riverpod providers/controllers, `AsyncValue`, loading/error/empty/success states |
| Routing | `go_router`, protected routes для backend mode |
| Auth | Supabase Auth email/password, Google OAuth через Supabase Auth |
| Backend schema | SQL migrations для `profiles`, `pets`, `posts`, `comments`, `post_likes`, `walks`, `walk_participants`, `chats`, `chat_participants`, `messages` |
| Security | RLS policies для application tables, Storage policies, security audit |
| API integration | Supabase repositories for feed, pets and walks; legacy API repositories preserved as historical Firebase branch support |
| Storage | Supabase buckets `avatars`, `pet-photos`, `post-images` описаны; `pet-images` добавлен для пользовательской загрузки фото питомцев |
| Hosting | Netlify configuration, SPA redirects, health endpoint |
| CI/CD | GitHub Actions: security audit, format, analyze, tests, web build, Netlify deploy on `main` |
| Analytics | Yandex Metrica events with privacy filtering |
| Logging | Structured app logs and Netlify health check logs without secrets or personal data |
| Tests | Flutter tests for auth, feed, pets, walks, chat, analytics, logging, router and network mapping |
| Documentation | README, backend documentation, integration documentation, security audit, AI workflow and prompt journal |

## Что будет доработано в рамках проектной работы

| Направление | Доработка |
|---|---|
| Product packaging | Свести документы ДЗ в единую финальную проектную историю |
| Frontend UX | Проверить финальные production scenarios, mobile/desktop responsive layout и error states |
| Backend validation | Повторить Supabase `db lint`, `db reset` или hosted SQL/RLS smoke checks перед сдачей |
| File storage UX | Фото питомцев загружаются в Supabase Storage и отображаются в pet list/profile; emoji остается fallback |
| Search/filtering | Feed search, walk filters and pet filters exposed in the UI |
| Notifications | Описать как future enhancement, если не будет реализовано в финальном scope |
| Production QA | Повторить Netlify redeploy и E2E проверку после исправлений OAuth/web startup |
| Portfolio readiness | Подготовить демонстрационный сценарий для преподавателя и финальный checklist |

## Final delivery plan

Финальная сдача должна быть сфокусирована не на смене архитектуры, а на доведении уже собранного full-stack проекта до проверяемого demo state.

Минимальный план:

1. Выполнить fresh Netlify redeploy текущей ветки после OAuth/web startup hardening.
2. Проверить production E2E: login, feed load, create post, like, comment, pets screen/profile, walks screen, join walk, logout.
3. Проверить `https://cool-duckanoo-d28d04.netlify.app/api/health` и зафиксировать статус.
4. Запустить `dart format .`, `flutter analyze`, `flutter test`, `flutter build web --release`.
5. Повторить Supabase validation: `supabase db lint`, `supabase db reset` или hosted SQL/RLS smoke checks.
6. Обновить README и `development_report.md` фактическим финальным QA status.
7. Обновить desktop/mobile screenshots в `docs/screenshots/`.

Рекомендуемый план доработок:

| Priority | Доработка | Результат |
|---|---|---|
| P0 | Production redeploy и browser E2E | Преподаватель открывает рабочий Netlify URL и проходит основной сценарий |
| P1 | Supabase Storage для фото питомцев | Storage становится видимой пользовательской функцией, а не только backend bucket/policy |
| P1 | Поиск/фильтрация постов, прогулок и питомцев | Закрыто: feed search, walk filters and pet filters доступны в UI |
| P1 | CRUD completeness для pets/posts/walks | Закрыт минимальный CRUD: pet create/read/update/delete, post create/delete, walk create/join/leave; детальная матрица в `docs/crud_audit.md` |
| P2 | Responsive UI polish | Финальные mobile/desktop screenshots без overflow и визуальных дефектов |
| P2 | Финальная документация и скриншоты | README/project docs содержат demo flow, gaps, validation status и актуальные изображения |

Detailed gap tracking is maintained in `final_project_gap_analysis.md`.

## Стек технологий

| Слой | Технологии |
|---|---|
| Frontend | Flutter Web, Dart, Material 3 |
| State/routing | Riverpod, `flutter_riverpod`, `go_router` |
| Architecture | Feature-first structure, Clean Architecture principles, repository layer |
| Auth | Supabase Auth, Google OAuth through Supabase |
| Database | Supabase PostgreSQL |
| Security | Row Level Security, Storage policies, CI security gates |
| API | Supabase auto REST API / PostgREST, `supabase_flutter` |
| File storage | Supabase Storage |
| Hosting | Netlify |
| CI/CD | GitHub Actions, Netlify CLI |
| Analytics | Yandex Metrica |
| Monitoring | Netlify Function `/api/health`, structured logs |
| Tests | `flutter_test`, `mocktail` |
| AI agent | OpenAI Codex |

## Frontend architecture

```text
lib/
  app/                 # app shell, theme, router, startup fallback
  core/                # config, analytics, logging, network, Supabase, shared widgets
  features/
    auth/              # auth repository, controller, login/register UI
    feed/              # posts, likes, comments, feed controller/UI
    pets/              # pet profiles, pet repositories/providers/UI
    walks/             # walk list, create/join flows, controller/UI
    chat/              # basic chat list and domain model
    home/              # main shell/navigation
```

UI widgets do not call Supabase directly. Screens use Riverpod controllers/providers, controllers call repository interfaces, and data implementations choose Supabase or mock mode through `BackendConfig`.

## UI/UX audit

Финальный UI/UX audit сохранен в `docs/ui_ux_audit.md`.

Итог аудита:

- основные экраны финального демо: Auth, Feed, Pets, Pet profile, Walks и Chat;
- responsive model подтверждена: mobile использует bottom navigation, desktop использует navigation rail и constrained content через `ResponsiveCenter`;
- loading/error/empty states реализованы через `AsyncContentView`, `EmptyState` и `ErrorState`;
- формы входа, регистрации и создания поста имеют validation/loading/error feedback;
- accessibility baseline опирается на Material 3 semantics, labels, tooltips, semantic error containers и live-region loading/error states;
- визуальная консистентность держится на единой Material 3 теме, карточках, чипах, иконках и shared state widgets.

Безопасные улучшения после аудита:

- empty states получили contextual icons и refresh actions для Feed, Pets и Walks;
- shared loading/error states получили semantic live-region hints;
- create-post bottom sheet ограничен по ширине на desktop, учитывает keyboard insets и показывает более дружелюбные ошибки;
- routing, repository layer и бизнес-логика не менялись.

Оставшиеся UX-рекомендации перед финальной сдачей:

- повторить desktop/mobile browser QA после production redeploy;
- повторить visual QA для новых search/filter controls на Feed, Pets и Walks;
- отполировать create pet и create walk UI forms, если они войдут в финальный demo scope;
- вывести реальные Supabase Storage images для питомцев или постов;
- обновить финальные screenshots в `docs/screenshots/`.

## Backend architecture

```text
Flutter Web
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase repository implementations
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Backend source of truth:

- `supabase/migrations/001_initial_schema.sql`;
- `supabase/migrations/002_rls_policies.sql`;
- `supabase/migrations/003_api_grants.sql`;
- `supabase/seed.sql`.

PostgreSQL relations cover more than three connected tables: profiles own pets, profiles and pets own posts, posts have comments and likes, walks have participants, chats have participants and messages.

## Requirements coverage

| Requirement | How PetConnect covers it |
|---|---|
| Frontend: minimum 3 main screens | Feed, Pets, Walks; additionally Auth, Home and Chat |
| Frontend: responsive design | Shared `ResponsiveCenter`, mobile bottom navigation and desktop navigation rail |
| Frontend: interactive elements/forms | Login/register forms, Google OAuth button, create post flow, pet create/edit/delete flow, like/comment/delete-post actions, walk create/join/leave actions |
| Frontend: loading/error states | `AsyncContentView`, `EmptyState`, `ErrorState`, Riverpod `AsyncValue` patterns |
| Backend: PostgreSQL with 3 related tables | Supabase schema has profiles, pets, posts, comments, likes, walks, participants, chats and messages |
| Backend: API with CRUD | Supabase auto REST API and Flutter SDK operations for feed, pets, comments, likes, walks and walk participants; `docs/crud_audit.md` records exact CRUD coverage |
| Backend: authentication | Supabase Auth email/password and Google OAuth |
| Backend: data validation | PostgreSQL constraints, RLS checks, repository-side mapping and friendly error handling |
| Additional: OAuth2 | Google OAuth through Supabase Auth |
| Additional: analytics | Yandex Metrica events with privacy-safe params |
| Additional: file storage | Supabase Storage bucket `pet-images` for pet photo upload/display, plus prepared buckets for avatars and post images |
| Additional: search/filtering | Feed supports debounced search by post text, author or pet name; Walks support date, location and status filters; Pets support name/type filters |
| AI: planning/design | Documented in `docs/ai_workflow.md`, `prompts.md` and `development_report.md` |
| AI: user stories/specification | `user_stories.md`, `technical_specification.md`, `project_documentation.md` |
| AI: frontend/backend development | Codex-assisted repository, UI, Supabase and Netlify work documented in prompt journal |
| AI: testing/debugging/security/performance | Flutter tests, security audit, log analysis prompts, CI/CD and performance optimization documented |

Final requirements package:

| Document | Role |
|---|---|
| `user_stories.md` | Product requirements grouped by Authentication, Pet profiles, Feed, Comments/Likes, Walks, Search, Image upload, Analytics, Monitoring and Admin/Maintenance |
| `technical_specification.md` | Technical requirements, architecture, database entities, API/CRUD matrix, RLS/security, integrations, deployment, CI/CD, monitoring and testing |
| `project_documentation.md` | Product overview and requirement coverage |
| `final_project_gap_analysis.md` | Delivery gap tracking and honest final readiness status |

## Remaining gaps

- Production Netlify frontend must be redeployed after the latest OAuth/web startup hardening and then checked end-to-end.
- Supabase local lint/reset should be repeated when local Supabase services are running; hosted smoke checks already document previous validation.
- Real pet photo upload/display through Supabase Storage is implemented for the final demo; post image upload remains a planned enhancement.
- Final minimum CRUD is implemented for pets, posts and walks; post editing, comment deletion UI, walk edit/delete UI and profile editing remain scoped enhancements.
- Notifications and payments are not part of the committed final scope; analytics, OAuth2, storage and implemented search/filtering cover the required additional-function set.
