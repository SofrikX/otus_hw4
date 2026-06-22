# PetConnect Technical Specification

Date: 22 June 2026

Purpose: final technical specification for PetConnect as a portfolio project. Historical Firebase/mobile specifications remain in `docs/` for context; this document describes the current Flutter Web + Supabase implementation target.

## 1. Project Overview

PetConnect is a full-stack Flutter Web application for pet owners. It combines a pet social feed, pet profiles, walks, comments, likes, authentication, basic chat data, analytics, monitoring and AI-documented engineering workflow.

The project demonstrates how AI was used during planning, requirements engineering, architecture design, implementation support, validation and documentation. OpenAI Codex is the active AI coding agent.

### Product goals

- Give pet owners a single place for pet profiles, posts and local walk activities.
- Demonstrate a real backend-backed Flutter Web portfolio project.
- Show repository-based frontend/backend integration with Supabase.
- Keep the final demo reproducible without paid services or committed secrets.

### Current production architecture decision

Supabase Free Tier is the selected backend. Firebase remains a researched historical branch because the earlier specification used Firebase, but it is not the current production backend choice.

Reasoning:

- the coursework allows Supabase;
- Supabase Free Tier fits educational deployment;
- PostgreSQL migrations and RLS are reviewable;
- Supabase auto REST API removes the need for paid Cloud Functions;
- `supabase_flutter` fits the existing repository architecture.

## 2. Functional Requirements

### Authentication

- Users can register with email/password through Supabase Auth.
- Users can sign in with email/password.
- Users can sign in with Google OAuth through Supabase Auth.
- Users can sign out.
- Protected routes redirect unauthenticated users to auth screens.
- A user profile row is created or updated after successful auth.

### Pet profiles

- Users can view pet lists and pet profile details.
- Users can create pets owned by the current user.
- Users can edit and delete their own pet profiles through owner-only UI actions.

### Feed and posts

- Authenticated users can view recent non-deleted public posts.
- Users can create a text post linked to a pet through the repository layer.
- Post image upload is planned through Supabase Storage.
- Users can delete their own posts through an owner-only action and confirmation dialog.
- Editing own posts remains a planned UI/application enhancement; RLS policies support owner-scoped writes.

### Comments and likes

- Authenticated users can like and unlike posts.
- Authenticated users can add non-empty comments.
- Database triggers maintain like and comment counters.
- Deleting own comments is planned for UI/application completeness.

### Walks

- Users can view active walks.
- Users can join walks.
- Users can create walks through the Walks screen form.
- Users can leave walks they joined.
- Editing/deleting walks remains a planned enhancement.

### Chat

- The data model includes chats, chat participants and messages.
- The UI includes a basic chat list scenario.
- Full message sending and moderation flows are outside the required final demo.

### Search and filters

- Feed screen exposes a debounced search input.
- Feed search matches post text, author name and pet name on the RLS-visible feed result set.
- Walks screen exposes filters by date, location/place text and status: upcoming, completed or all.
- Pets screen exposes search by pet name and animal type chips.
- Filters are implemented through Riverpod controllers/providers and repository query objects, not direct backend calls from widgets.
- Analytics tracks `search_performed`, `feed_filter_changed` and `walk_filter_changed` without raw query text or personal data.

### Image upload

- Pet owners can upload a pet photo from Flutter Web.
- Allowed pet photo types are JPG, JPEG, PNG and WebP.
- Pet photo uploads are limited to 5 MB.
- The app uploads pet photos to Supabase Storage bucket `pet-images` and stores the resulting public URL in `pets.photo_url`.
- Post image upload is planned through Supabase Storage.

### Analytics

- Product analytics tracks safe events: app open, sign-up started, sign-in success, feed opened, post created, post liked, comment added, walk joined and backend/auth errors.
- Analytics payloads must not contain personal data, raw ids, secrets, tokens, post text or comment text.

### Monitoring and logging

- Netlify Function `/api/health` checks app reachability and Supabase endpoint availability.
- App and health logs are structured and sanitized.
- AI log analysis uses sanitized logs only.

## 3. Non-Functional Requirements

| Area | Requirement |
|---|---|
| Security | No service role keys, database passwords, JWT secrets or private tokens in repository or frontend bundle |
| Authorization | PostgreSQL RLS is enabled for all application tables |
| Privacy | Analytics and logs exclude personal data and content text |
| Reliability | UI handles loading, empty, error and success states |
| Maintainability | Feature-first structure with repository interfaces and Riverpod controllers |
| Testability | Flutter tests cover auth, routing, feed, pets, walks, chat, analytics, logging and API mapping |
| Performance | Flutter Web release build is served statically through Netlify; feed/walk queries use indexes and limits |
| Accessibility | Material 3 controls and responsive layout are used; final visual QA should verify mobile and desktop |
| Cost | Free-tier services only for project validation |

## 4. Frontend Architecture

Technology stack:

- Flutter Web;
- Dart;
- Material 3;
- Riverpod / `flutter_riverpod`;
- `go_router`;
- `supabase_flutter`;
- `flutter_test` and `mocktail`.

Source layout:

```text
lib/
  app/
    app.dart
    router.dart
    startup_error_app.dart
    theme.dart
  core/
    analytics/
    config/
    logging/
    network/
    supabase/
    widgets/
  features/
    auth/
    feed/
    pets/
    walks/
    chat/
    home/
```

Architecture rules:

- Widgets call controllers/providers, not Supabase directly.
- Domain models and repository interfaces stay outside widgets.
- Supabase, mock and legacy API implementations stay in `data` folders.
- Riverpod providers/controllers stay in `application` or feature presentation controller files.
- Shared UI states use `AsyncContentView`, `EmptyState`, `ErrorState` and `ResponsiveCenter`.

Runtime backend selection:

- `USE_SUPABASE_BACKEND=true` uses Supabase repositories.
- Mock repositories remain for tests, local fallback and incremental development.
- Legacy API/Firebase-related classes are historical support, not the current production backend decision.

## 5. Backend Architecture

```text
Flutter Web
  -> Riverpod controllers/providers
  -> repository interfaces
  -> Supabase repository implementations
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Supabase components:

- Supabase Auth for email/password and Google OAuth;
- PostgreSQL for relational data;
- Row Level Security for authorization;
- Supabase Storage for images;
- PostgREST/auto REST API through Supabase Flutter client;
- SQL migrations and seed data in the repository.

Backend source of truth:

```text
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_rls_policies.sql
supabase/migrations/003_api_grants.sql
supabase/seed.sql
```

## 6. Database Entities

| Entity | Table | Purpose |
|---|---|---|
| Profile | `profiles` | User profile linked to `auth.users` |
| Pet | `pets` | Pet profiles owned by users |
| Post | `posts` | Feed posts linked to authors and pets |
| Comment | `comments` | Comments on posts |
| Like | `post_likes` | User reactions to posts |
| Walk | `walks` | Pet walk events |
| Walk participant | `walk_participants` | Join table for users and walks |
| Chat | `chats` | Chat metadata |
| Chat participant | `chat_participants` | Join table for chat visibility |
| Message | `messages` | Chat messages |

Important constraints:

- `profiles.id` references `auth.users(id)`.
- `pets.owner_id` references `profiles(id)`.
- `posts.author_id` references `profiles(id)`.
- `posts.pet_id` references `pets(id)`.
- `post_likes` has unique `(post_id, user_id)`.
- `walk_participants` has unique `(walk_id, user_id)`.
- Text lengths, enum-like status fields and non-negative counters are constrained in SQL.

Storage buckets:

| Bucket | Purpose | Status |
|---|---|---|
| `avatars` | User avatars | Backend configured, UI upload planned |
| `pet-photos` | Historical/prepared pet photo bucket | Backend configured |
| `pet-images` | Pet profile photos shown in UI | Public read, owner-scoped authenticated upload/update/delete implemented |
| `post-images` | Post images | Backend configured, UI upload planned |

## 7. API/CRUD Operations

PetConnect uses Supabase client operations and auto REST API rather than a custom backend server.

| Area | Operation | Current status |
|---|---|---|
| Auth | Sign up, sign in, sign out, Google OAuth | Done |
| Profiles | Upsert profile after auth | Done |
| Pets | Read list/details/owner pets | Done |
| Pets | Create pet | Done |
| Pets | Update own pet photo | Done |
| Pets | Update/delete own pet profile fields | Done |
| Feed | Read recent non-deleted posts and search visible feed data | Done |
| Feed | Create post | Done |
| Feed | Delete own post | Done |
| Feed | Update own post | Planned |
| Likes | Toggle own like | Done |
| Comments | Add comment | Done |
| Comments | Delete own comment | Planned |
| Walks | Read active walks with date/location/status filters | Done |
| Walks | Create walk | Done |
| Walks | Join walk | Done |
| Walks | Leave walk | Done |
| Walks | Update/delete own walk | Planned |
| Pets | Filter visible pets by name and animal type | Done |
| Chats | Read basic chat list from mock/domain scenario | Done for MVP UI |
| Messages | Full send/update/delete message flow | Optional |

Minimum required backend/API operations are covered by post creation, like toggle, comment creation, pet reads, walk reads and walk join.

## 8. Authentication And Authorization

Authentication provider:

- Supabase Auth.

Supported flows:

- email/password registration;
- email/password login;
- Google OAuth login;
- logout;
- session restore.

Authorization:

- Client uses the current Supabase session and access token.
- Database authorization is enforced by RLS using `auth.uid()`.
- Flutter Web never uses service role keys.
- Protected routes are enforced in `go_router` based on auth state.

OAuth setup:

- Google Client ID and Client Secret are configured in Supabase Dashboard.
- Production Site URL and Redirect URLs point to the Netlify URL.
- Local development redirect URLs point to localhost.

## 9. RLS/Security Model

RLS is enabled for:

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

Policy summary:

| Table | Read | Write |
|---|---|---|
| `profiles` | authenticated users | own profile only |
| `pets` | authenticated users | owner only |
| `posts` | authenticated users, non-deleted posts | author only |
| `comments` | authenticated users, non-deleted comments on visible posts | author only |
| `post_likes` | authenticated users for visible posts | own likes only |
| `walks` | authenticated users | creator only |
| `walk_participants` | authenticated users | own participant row only |
| `chats` | chat participants | participant-scoped update |
| `chat_participants` | own chats | own participant row only |
| `messages` | chat participants | sender/participant scoped |

Storage security:

- Buckets are configured by migrations.
- `pet-images` uses public read for simple image rendering in Flutter Web.
- `pet-images` writes use paths `<auth.uid()>/<pet-id>/<file-name>` and policies verify that `<pet-id>` belongs to the current user.
- The app validates JPG/JPEG/PNG/WebP and 5 MB max size before upload.
- Service role key is never used in the Flutter app.

Repository security:

- Widgets do not build SQL or call backend SDKs directly.
- Error mapping converts backend errors into safe user-facing messages.
- Analytics and logs are sanitized.

## 10. Integrations

| Integration | Purpose |
|---|---|
| Supabase Auth | Email/password and Google OAuth |
| Supabase PostgreSQL | Application data |
| Supabase Storage | Image buckets for avatars, pet photos and post images |
| Supabase auto REST/PostgREST | Backend CRUD through Flutter SDK |
| Netlify | Production Flutter Web hosting |
| GitHub Actions | CI/CD validation and deploy |
| Yandex Metrica | Privacy-safe product analytics |
| Netlify Functions | `/api/health` monitoring endpoint |
| OpenAI Codex | AI-assisted planning, implementation, debugging and documentation |

## 11. Deployment

Production split:

| Layer | Target |
|---|---|
| Backend | Hosted Supabase project |
| Frontend | Flutter Web static release build |
| Hosting | Netlify Free |

Flutter Web build:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY \
  --dart-define=SUPABASE_AUTH_REDIRECT_URL=https://cool-duckanoo-d28d04.netlify.app/ \
  --dart-define=ANALYTICS_ENABLED=$ANALYTICS_ENABLED \
  --dart-define=ANALYTICS_PROVIDER=$ANALYTICS_PROVIDER \
  --dart-define=ANALYTICS_ID=$ANALYTICS_ID
```

Environment values are configured in Netlify/GitHub settings, not committed to git. Supabase publishable key is public client configuration, but service role key, database password and private tokens are secrets and must never be added to frontend env or docs.

## 12. CI/CD

GitHub Actions workflow:

- runs security audit;
- installs Flutter;
- runs `flutter pub get`;
- checks formatting;
- runs `flutter analyze`;
- runs `flutter test`;
- builds Flutter Web release;
- deploys `build/web` to Netlify on `main`.

Security gates:

- no real `.env` files in tracked code;
- no service role keys or database passwords;
- dependency audit where applicable;
- deployment only after validation jobs pass.

## 13. Monitoring And Logging

Monitoring:

- `/api/health` Netlify Function returns app and Supabase check status.
- Optional external uptime monitor can call the endpoint every few minutes.
- Health response never returns secret values.

Logging:

- Flutter app uses `AppLogger` for structured logs.
- Netlify health function logs JSON lines.
- Logs include safe diagnostics such as operation, status code, error type and duration.
- Logs exclude secrets, auth headers, emails, raw user ids, post text, comment text and chat messages.

AI-assisted debugging:

- Sanitized logs can be passed to Codex with prompts from `docs/logging.md`.
- AI should analyze symptoms, likely causes and safe next checks without exposing private values.

## 14. Testing Strategy

Automated Flutter validation:

```bash
dart format .
flutter analyze
flutter test
flutter build web --release
```

Supabase validation:

```bash
supabase db lint
supabase db reset
```

If local Supabase services are unavailable, hosted SQL/RLS smoke checks are acceptable and must be documented.

Test coverage areas:

- auth controller and login UI;
- router/protected route behavior;
- feed controller, feed UI, post card, API mapping;
- pets screen/profile and repository mapping;
- walks controller/UI and Supabase repository behavior;
- chat list UI;
- analytics sanitizer;
- structured logging sanitizer;
- API client error mapping;
- startup error fallback.

Manual final QA:

1. Open Netlify production URL.
2. Sign up or sign in.
3. Load feed.
4. Create post.
5. Like and comment on a post.
6. Open pets and pet profile.
7. Open walks and join a walk.
8. Sign out.
9. Call `/api/health`.
10. Verify no secrets appear in logs, docs or build config.

## 15. AI-Assisted Requirements Engineering

AI was used as a requirements engineering partner, not only as a code generator.

AI contributions:

- analyzed earlier homework documents, current implementation and final project gaps;
- converted broad course requirements into product-level user story groups;
- separated implemented features from planned and optional features;
- reconciled historical Firebase specification with the current Supabase architecture decision;
- produced acceptance criteria tied to code, migrations, RLS policies, tests and deployment documentation;
- helped define the technical specification structure: functional requirements, non-functional requirements, frontend/backend architecture, database entities, API operations, security model, integrations, deployment, CI/CD, monitoring and testing;
- maintained prompt history and development report updates so the project demonstrates AI usage during planning and requirements formation.

Important constraint: AI-generated requirements were checked against repository evidence in `lib/`, `supabase/`, tests and documentation. Features not fully exposed or validated in the current implementation are marked **Planned** or **Optional**, not **Done**.
