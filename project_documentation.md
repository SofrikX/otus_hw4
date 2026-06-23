# PetConnect Project Documentation

Date: 23 June 2026

PetConnect is a full-stack Flutter Web portfolio project for pet owners. The application combines authentication, pet profiles, a pet social feed, comments, likes, walks, basic chat, image upload, analytics, monitoring and AI-documented engineering workflow.

## Project Overview

PetConnect helps pet owners keep profiles for their pets, publish updates, react to community posts and discover local walks. The final implementation is built as a browser-first Flutter Web application backed by Supabase and deployed on Netlify.

Public project links:

| Resource | URL |
|---|---|
| Production app | https://cool-duckanoo-d28d04.netlify.app |
| Health check | https://cool-duckanoo-d28d04.netlify.app/api/health |
| GitHub repository | https://github.com/SofrikX/otus_hw4/tree/hw5-sb |
| Defense script | docs/defense_script.md |

## Target Audience

| Audience | Need |
|---|---|
| Dog owners | Find company for walks and local pet-friendly activities. |
| Cat and other pet owners | Share stories, photos and pet profiles in a focused social feed. |
| New pet owners | Get a lightweight community space and discover nearby activities. |
| Course reviewers and employers | Evaluate a complete AI-assisted full-stack Flutter Web project. |

## Problem And Solution

Pet owners often split communication between generic messengers, social networks and notes. Pet profiles, posts, local activities and owner interactions are not connected in one product experience.

PetConnect solves this with one web application:

- authenticated user access;
- pet profiles with owner-controlled CRUD;
- feed posts tied to pets;
- likes and comments;
- walk creation and participation;
- pet image upload through Supabase Storage;
- search and filters for feed, pets and walks;
- responsive premium dark UI.

## Main Features

- Email/password authentication through Supabase Auth.
- Google OAuth through Supabase Auth.
- Protected routing with `go_router`.
- Pet profiles: create, read, update, delete and photo upload.
- Feed: read posts, create posts for owned pets, like/unlike, comment and delete own posts.
- Walks: create walks, filter walks, join and leave.
- Search/filter UI for feed, pets and walks.
- Basic chat list scenario and relational chat/message schema.
- Yandex Metrica analytics with privacy-safe event params.
- Netlify `/api/health` endpoint.
- Structured sanitized logging.
- GitHub Actions CI/CD.

## Final Visual Design

The final UI uses a premium dark pet social app direction:

- deep navy/black backgrounds;
- violet/blue gradient accents;
- glassmorphism cards;
- polished auth landing, feed, pets, walks, pet profile and chat screens;
- mobile bottom navigation;
- desktop navigation rail and constrained dashboard content;
- shared loading, empty and error states.

The visual redesign did not change routing, Supabase integration, RLS, analytics, repository boundaries or CRUD flows.

## Frontend Architecture

```text
Flutter Web
  -> Material 3 UI
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase or mock repository implementations
```

Source layout:

```text
lib/
  app/                 # app shell, router, theme, startup fallback
  core/                # analytics, config, logging, network, Supabase, shared widgets
  features/
    auth/
    feed/
    pets/
    walks/
    chat/
    home/
```

Architecture rules:

- widgets do not call Supabase directly;
- business logic stays in controllers/providers and repositories;
- domain models and repository interfaces stay outside widgets;
- mock repositories remain for tests and local no-credential runs;
- Supabase repositories are used when `USE_SUPABASE_BACKEND=true`.

## Frontend Screens

| Screen | Purpose | Status |
|---|---|---|
| Auth landing/login/register | Email auth, Google OAuth entry, protected app access | Done |
| Feed | Posts, likes, comments, search, create/delete own post | Done |
| Pets | Pet list, filters, create/edit/delete pet | Done |
| Pet profile | Pet details and owner photo upload | Done |
| Walks | Walk list, filters, create/join/leave flows | Done |
| Chat | Basic chat list scenario | Done for MVP scope |
| Startup error | Friendly bootstrap failure fallback | Done |

## Database Model

Supabase PostgreSQL stores the application data.

Core tables:

- `profiles`
- `pets`
- `posts`
- `comments`
- `post_likes`
- `walks`
- `walk_participants`
- `chats`
- `chat_participants`
- `messages`

Important relationships:

- `profiles.id` matches Supabase Auth user id;
- `pets.owner_id` references `profiles.id`;
- `posts.author_id` references `profiles.id`;
- `posts.pet_id` references `pets.id`;
- `comments.post_id` references `posts.id`;
- `post_likes` and `walk_participants` enforce uniqueness per user/action;
- chats and messages are participant-scoped.

Storage:

- `pet-images` is the visible pet profile photo bucket;
- `avatars`, `pet-photos` and `post-images` remain prepared or historical buckets.

## Backend And API

PetConnect uses Supabase auto REST API and `supabase_flutter`, not a custom production API server.

Implemented API operations:

| Area | Operations |
|---|---|
| Auth | sign up, sign in, Google OAuth, sign out, profile upsert |
| Pets | list, details, owner pets, create, update, delete, upload photo |
| Feed | list posts, create post, delete own post, like/unlike, add comments |
| Walks | list/filter walks, create walk, join, leave |
| Chat | basic chat list model and schema |

Detailed CRUD evidence is in `docs/crud_audit.md`.

## Authentication

Supabase Auth is the final identity provider.

Supported flows:

- email/password registration;
- email/password sign in;
- Google OAuth through Supabase provider configuration;
- sign out;
- session restore;
- profile row upsert after auth.

Google Client Secret is stored only in Supabase Dashboard and Google Cloud Console. It is not used in Flutter, Netlify, GitHub Actions or repository files.

## Authorization And RLS

PostgreSQL Row Level Security is the backend authorization boundary.

Key RLS rules:

- users create/update/delete only their own pets;
- posts can be created only for pets owned by the current user;
- users delete only their own posts;
- comments and likes require visible target posts;
- users join only active walks and delete only their own walk participation rows;
- chats/messages are visible only to participants;
- `pet-images` writes require authenticated owner/pet-scoped paths.

UI owner checks improve UX, but RLS remains the enforcement layer.

## Integrations

| Integration | Purpose |
|---|---|
| Supabase Auth | Email/password and Google OAuth identity |
| Supabase PostgreSQL | Relational app data |
| Supabase Storage | Pet profile image upload |
| Supabase PostgREST | Auto REST API used through Flutter SDK |
| Netlify | Flutter Web static hosting and health function |
| GitHub Actions | CI/CD and production deploy |
| Yandex Metrica | Privacy-safe product analytics |
| OpenAI Codex | AI-assisted planning, implementation, QA and documentation |

## Deployment

Production split:

| Layer | Target |
|---|---|
| Frontend | Flutter Web release build |
| Hosting | Netlify |
| Backend | Supabase Auth, PostgreSQL, RLS, Storage, auto REST API |
| Health endpoint | Netlify Function `/api/health` |

Netlify publishes `build/web`, routes `/api/health` to `netlify/functions/health.js` and uses SPA fallback for Flutter routing.

## CI/CD

GitHub Actions workflow: `.github/workflows/ci_cd.yml`.

Pipeline:

- security audit job;
- secret marker scan;
- `.env*` and `.DS_Store` hygiene checks;
- dependency checks;
- `dart format --set-exit-if-changed .`;
- `flutter analyze`;
- `flutter test`;
- Flutter Web release build;
- Netlify deploy on `push` to `main`.

Secrets are stored only in GitHub/Netlify settings. Service role keys and database passwords are not part of the frontend workflow.

## Security And Privacy

Security controls:

- no service role key in Flutter Web;
- no real secrets in repository files;
- RLS enabled on application tables;
- Storage writes owner/pet-scoped;
- analytics params are sanitized;
- logs exclude tokens, emails, raw ids and user-generated text;
- health endpoint does not return environment values;
- CI blocks secret markers and real env files.

Full security/performance review: `security_audit.md`.

## Testing

Automated coverage includes:

- auth controller and forms;
- router protection;
- feed state, likes, comments and delete confirmation;
- pet CRUD, filters and photo-related mapping;
- walks create/join/leave/filter flows;
- analytics sanitizer;
- logger sanitizer;
- API/Supabase error mapping;
- startup error fallback.

Latest local validation:

```text
flutter pub get: passed
dart format --set-exit-if-changed .: passed, 99 files checked, 0 changed
flutter analyze: passed, no issues found
flutter test: passed, 110 tests
flutter build web --release --dart-define=USE_SUPABASE_BACKEND=false --dart-define=ANALYTICS_ENABLED=false: passed
```

Manual QA checklist: `docs/manual_qa_checklist.md`.

## Monitoring And Logging

Monitoring:

- production health URL: `https://cool-duckanoo-d28d04.netlify.app/api/health`;
- checks Netlify Function reachability, Supabase URL config, Auth endpoint, REST endpoint and optional limit-1 posts query.

Logging:

- Flutter uses `AppLogger` structured JSON logs;
- Netlify health function logs structured JSON;
- release mode skips Flutter info logs;
- logs are sanitized for AI-assisted analysis.

Detailed logging guide: `docs/logging.md`.

## Final Requirements Coverage

| Requirement | Coverage |
|---|---|
| Full-stack web app | Flutter Web + Supabase + Netlify |
| Minimum 3 screens | Feed, Pets, Walks; plus Auth, Chat and Pet Profile |
| Auth | Supabase email/password and Google OAuth |
| Database | PostgreSQL schema with related domain tables |
| CRUD/API | Pets, posts, comments, likes, walks and participation operations |
| Authorization | RLS and Storage policies |
| File storage | Supabase Storage pet image upload |
| Search/filters | Feed, pets and walks |
| Analytics | Yandex Metrica privacy-safe events |
| Monitoring | Netlify health endpoint and structured logs |
| CI/CD | GitHub Actions + Netlify deploy |
| Testing | Flutter unit/widget tests and manual QA checklist |
| AI process | `ai_development_process.md`, `development_report.md`, `prompts.md` |
| Portfolio documentation | README, project docs, technical spec, screenshots package, submission package, defense script and final release checklist |

## Conclusions And Recommendations

PetConnect is packaged as a final portfolio project rather than a set of intermediate course artifacts. The final architecture is Flutter Web + Supabase + Netlify + GitHub Actions. The final submission entry points are `README.md`, `docs/submission_package.md`, `docs/defense_script.md` and `final_release_checklist.md`. The main remaining work is operational rather than architectural: run final production browser QA after deploys, refresh screenshots and keep secrets out of public artifacts.
