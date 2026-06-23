# PetConnect Development Report

Date: 23 June 2026

This report summarizes the final development process for PetConnect as a full-stack Flutter Web + Supabase portfolio project.

## Executive Summary

PetConnect evolved from a Flutter frontend MVP into a full-stack web application with Supabase backend, PostgreSQL database, Row Level Security, Storage, Google OAuth, search/filters, Yandex Metrica analytics, Netlify deployment, GitHub Actions CI/CD, structured logging, health monitoring, security audit and premium dark visual design.

Final stack:

- Flutter Web and Dart;
- Material 3, Riverpod and `go_router`;
- Supabase Auth, PostgreSQL, RLS, Storage and auto REST API;
- Netlify hosting and health function;
- GitHub Actions CI/CD;
- Yandex Metrica analytics;
- OpenAI Codex-assisted development workflow.

## Development Stages

| Stage | Work completed | Result |
|---|---|---|
| Product planning | Defined target audience, problem, user journeys and final portfolio scope | Product documentation and user stories |
| Architecture | Chose Flutter Web + Supabase + Netlify + GitHub Actions | Final technical specification |
| Backend design | Created PostgreSQL schema, constraints, indexes, triggers and seed model | Supabase migrations |
| Security model | Added RLS, Storage policies and grants | Owner/visibility-scoped backend |
| Frontend integration | Added Supabase repositories and Riverpod controllers | Backend-backed auth/feed/pets/walks |
| CRUD completion | Added visible pet, post and walk operations | CRUD audit completed |
| Storage | Added pet image upload through `pet-images` bucket | User-visible file storage |
| Search/filters | Added feed, pet and walk filtering | Demonstrable additional function |
| Integrations | Added Google OAuth, Yandex Metrica, Netlify health endpoint | Production integration set |
| CI/CD | Added GitHub Actions and Netlify deploy config | Automated quality/deploy pipeline |
| Visual redesign | Implemented premium dark responsive UI | Portfolio-ready interface |
| QA/security | Added tests, manual checklist and security/performance audit | Release readiness evidence |
| Documentation | Finalized README, reports, prompt journal, submission package, defense script and release checklist | Portfolio-ready documentation |

## Main Architecture Decisions

### Flutter Web Frontend

Flutter Web remained the final frontend because the app already had a feature-first Flutter MVP and the final project benefits from a single Dart codebase, Material 3 UI and a static deploy target.

### Supabase Backend

Supabase is the final backend. It provides:

- Auth and Google OAuth;
- PostgreSQL schema;
- Row Level Security;
- Storage;
- auto REST API through PostgREST;
- Flutter SDK integration.

### Netlify Hosting

Netlify is the final frontend host because Flutter Web builds to static files and Netlify provides simple static hosting, SPA redirects, environment variables and serverless functions for `/api/health`.

### GitHub Actions CI/CD

GitHub Actions runs security checks, formatting, analysis, tests, release build and Netlify deploy on `main`.

## Firebase To Supabase Pivot

An earlier backend exploration used Firebase because an older specification mentioned Firebase Auth, Firestore, Storage and Cloud Functions. During production planning, Firebase Cloud Functions were identified as a poor fit for a free educational deployment because production deploy can require a paid Blaze/pay-as-you-go plan.

The project pivoted to Supabase because:

- the course requirements allow Supabase;
- Supabase Free Tier fits the final project;
- PostgreSQL migrations and RLS are reviewable;
- auto REST API avoids a custom paid function layer;
- `supabase_flutter` fits the repository architecture.

Firebase remains only as historical exploration in development history, not as the final backend.

## Backend And RLS Work

Implemented migrations:

- `001_initial_schema.sql`;
- `002_rls_policies.sql`;
- `003_api_grants.sql`;
- `004_pet_images_storage.sql`;
- `005_harden_remote_rls_policies.sql`;
- `006_fix_pet_images_storage_policy_path.sql`.

Important RLS fixes:

- posts cannot be created with another user's pet;
- private/deleted post visibility is enforced for comments and likes;
- walk joins require active walks;
- pet image Storage paths must match current user and owned pet.

Production backend verification confirmed migrations `001`-`006`, expected public tables, `pets.photo_url`, hardened policies and `pet-images` bucket.

## Frontend Work

Implemented frontend capabilities:

- Supabase email/password auth;
- Google OAuth button and auth flow integration;
- protected routes;
- feed loading, search, create post, like, comment and delete own post;
- pet list, filters, create/edit/delete and photo upload;
- walk list, filters, create/join/leave;
- basic chat screen;
- async loading/empty/error/success states;
- friendly validation and error messages.

The final UI uses shared theme tokens and widgets:

- `AppCard`;
- `GlassCard`;
- `GradientButton`;
- `AppScreenBackground`;
- shared `AsyncContentView`, `EmptyState` and `ErrorState`.

## Integrations

| Integration | Implementation |
|---|---|
| Google OAuth | Supabase provider flow, no client secret in Flutter |
| Yandex Metrica | Lazy-loaded browser script with sanitized params |
| Supabase Storage | `pet-images` bucket and owner-scoped upload |
| Netlify health | `/api/health` function with sanitized checks/logs |
| GitHub Actions | Security, format, analyze, test, build, deploy |

## Problems And Solutions

| Problem | Root cause | Solution |
|---|---|---|
| Free production backend needed | Firebase Functions can require paid plan | Pivoted to Supabase Free Tier |
| RLS blocked create post | Frontend selected a pet from global feed instead of current user's pet | Create-post flow now uses current user's owned pet |
| Storage policy path ambiguity | SQL policy referenced ambiguous `name` | Corrected policy to use `storage.objects.name` |
| Analytics privacy risk | Sanitizer covered obvious keys but not all raw id/content-style keys | Hardened analytics param filtering |
| Production log noise risk | Debug/info logs can be excessive in browser | Release mode skips `AppLogger.info` |
| External dashboard validation | OAuth and analytics depend on third-party dashboards | Kept these checks in manual QA checklist |

## Netlify Deployment Notes

Netlify config:

- build command uses Flutter Web release build;
- publish directory is `build/web`;
- `/api/health` routes to Netlify Function;
- `/*` routes to `index.html` for SPA fallback;
- public browser config keys are omitted from Netlify secret scanning;
- service role keys and private tokens are never added to the omit list.

Required production values live in Netlify/GitHub settings, not in repository files.

## Testing And Final QA

Latest local validation:

```text
flutter pub get: passed
dart format --set-exit-if-changed .: passed, 99 files checked, 0 changed
flutter analyze: passed, no issues found
flutter test: passed, 110 tests
flutter build web --release --dart-define=USE_SUPABASE_BACKEND=false --dart-define=ANALYTICS_ENABLED=false: passed
```

Manual QA remains for:

- production Netlify browser smoke test;
- Google OAuth redirect confirmation;
- real Supabase Storage upload;
- Yandex Metrica dashboard event arrival;
- production responsive screenshots and safe external dashboard screenshots.

## Security And Performance Review

Final audit found no tracked private credentials. Security boundary:

- Supabase Auth sessions;
- PostgreSQL RLS;
- Storage policies;
- sanitized logs;
- privacy-safe analytics;
- CI secret scanning/hygiene gates.

Performance findings:

- Flutter Web release build succeeds;
- analytics lazy-loads;
- release info logs are disabled;
- image upload is capped at 5 MB;
- UI uses shared widgets/tokens to reduce duplicated complexity.

## AI Contribution

OpenAI Codex contributed to:

- product framing;
- requirements and user stories;
- technical specification;
- schema/RLS design;
- Flutter repositories/controllers/widgets;
- tests;
- deployment and CI/CD;
- debugging;
- security/performance audit;
- final documentation.

Human review controlled final scope, secret handling, production validation and acceptance of changes.

## Lessons Learned

- Architecture decisions should be documented as soon as they change.
- Free-tier production constraints can reshape backend choice.
- RLS must be tested with realistic ownership scenarios.
- UI ownership checks are useful but cannot replace backend authorization.
- Analytics/logging must be privacy-designed from the start.
- Portfolio README tone should be different from internal iteration notes.
- AI is effective for iterative implementation, but final documentation needs a consistency pass.

## Recommendations

- Run a final production browser QA pass after each Netlify redeploy.
- Keep refreshed app screenshots in `docs/screenshots/01`-`09`; refresh external dashboard screenshots manually from safe overview pages.
- Use `docs/submission_package.md`, `docs/defense_script.md` and `final_release_checklist.md` as the final reviewer handoff.
- Keep demo credentials outside the repository.
- Keep Supabase local lint/reset in the release checklist when local services are available.
- Plan future enhancements separately: post image upload, profile editing, full chat send flow and broader E2E automation.
