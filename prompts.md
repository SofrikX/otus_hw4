# PetConnect Prompt Journal

Date: 23 June 2026

This file summarizes the main prompts and outcomes used during AI-assisted PetConnect development. Earlier raw prompt history was consolidated so the final project documentation is easier to review and does not read like a sequence of intermediate course-stage artifacts.

## Prompting Method

Most prompts followed this structure:

- **Role**: Codex persona such as Flutter Engineer, Supabase Architect, QA Reviewer or Security Auditor.
- **Task**: concrete deliverable.
- **Context**: project state, stack and constraints.
- **Requirements**: implementation, safety and validation rules.
- **Output**: expected summary, files changed and validation.

Recurring constraints:

- no secrets in repository;
- final frontend is Flutter Web;
- final backend is Supabase;
- final hosting is Netlify;
- final CI/CD is GitHub Actions;
- preserve repository/controller architecture;
- run validation after code changes.

## Prompt Summary Matrix

| Category | Goal | Representative output | Result |
|---|---|---|---|
| Planning | Convert course requirements into a product/release plan | Scope, stack, project artifacts and validation checklist | Final portfolio scope |
| Product and requirements | Define audience, problem, user journeys and acceptance criteria | `project_documentation.md`, `user_stories.md` | Product story established |
| Technical specification | Document architecture, entities, API, security, integrations and testing | `technical_specification.md` | Final technical spec |
| Backend design | Create PostgreSQL schema, constraints, indexes, triggers and seed model | Supabase migration files | Database model implemented |
| RLS/security model | Add owner-scoped policies and Storage rules | `002`, `004`, `005`, `006` migrations | Hardened authorization |
| Frontend integration | Connect Flutter screens through repositories/controllers | Supabase auth/feed/pets/walks implementations | Backend-backed UI |
| CRUD completion | Expose required pet/post/walk operations | CRUD UI/actions/tests and `docs/crud_audit.md` | Final CRUD scope covered |
| Search/filtering | Add visible search and filters | Feed, pets and walks filters | Additional feature complete |
| Storage | Add pet photo upload | `pet-images` bucket and Flutter picker/controller | Visible file upload |
| CI/CD | Configure GitHub Actions and Netlify | `.github/workflows/ci_cd.yml`, `netlify.toml` | Automated checks/deploy |
| Google OAuth | Add OAuth through Supabase Auth | Auth repository/controller/UI/docs | OAuth integration documented |
| Analytics | Add Yandex Metrica safely | Analytics service, lazy loader, tests | Privacy-safe analytics |
| Monitoring/logging | Add health endpoint and structured logs | `netlify/functions/health.js`, `docs/logging.md` | Monitoring and AI log analysis |
| QA | Stabilize tests and manual checklist | `docs/testing_strategy.md`, `docs/manual_qa_checklist.md` | 110 passing Flutter tests |
| Security audit | Review secrets, RLS, Storage, logs, analytics, CI | `security_audit.md`, sanitizer hardening | Final audit complete |
| Visual redesign | Create premium dark portfolio UI | theme tokens, shared widgets, redesigned screens | Final visual style |
| Documentation | Package final project | README, submission package, defense script, release checklist, reports | Portfolio-ready docs |

## Key Prompt Examples

### Planning

**Goal:** Turn the project into a coherent full-stack portfolio application.

**AI output:** final scope, architecture decision, documentation map, validation commands.

**Human review:** confirmed Flutter Web, Supabase, Netlify, GitHub Actions and no paid services.

**Result:** project moved from course-stage framing to portfolio framing.

### Backend

**Goal:** Design Supabase schema and RLS for PetConnect user stories.

**AI output:** SQL migrations for profiles, pets, posts, comments, likes, walks, chats, policies and grants.

**Human review:** checked owner-scoped writes, no service role usage and no destructive migration behavior.

**Result:** Supabase backend with PostgreSQL, RLS and Storage.

### Frontend

**Goal:** Integrate Supabase without calling backend directly from widgets.

**AI output:** repositories, Riverpod controllers, auth flow, feed/pets/walks implementations, tests.

**Human review:** preserved feature-first structure and mock fallback.

**Result:** Flutter Web app backed by Supabase through repository layer.

### CI/CD

**Goal:** Automate validation and deploy.

**AI output:** GitHub Actions workflow with security audit, format, analyze, tests, build and Netlify deploy.

**Human review:** verified secret handling and Netlify environment model.

**Result:** CI/CD pipeline for production frontend.

### Security Audit

**Goal:** Final security and performance review before submission.

**AI output:** findings, OWASP review, performance notes, analytics sanitizer hardening and documentation updates.

**Human review:** accepted only safe small fixes and kept secrets out of files.

**Result:** `security_audit.md` and privacy-safe analytics improvements.

### Visual Redesign

**Goal:** Make the app look like a polished portfolio product.

**AI output:** premium dark theme, design tokens, shared glass components and redesigned screens.

**Human review:** verified no backend/routing/RLS rewrite.

**Result:** final dark responsive UI.

### QA

**Goal:** Stabilize release checks.

**AI output:** Flutter tests, testing strategy, manual QA checklist and validation snapshot.

**Human review:** kept OAuth, hosted RLS, Storage and analytics dashboard as manual checks where automation would be brittle.

**Result:** 110 passing tests and clear manual QA boundary.

### Final Documentation

**Goal:** Make the repository understandable to a reviewer, employer and developer.

**AI output:** portfolio README, project documentation, AI process, development report, screenshot checklist, defense script, submission package and final release checklist.

**Human review:** removed stale temporary notes, demo credentials and course-stage wording.

**Result:** final project documentation set.

## Final Prompts Covered

The final documentation reflects prompts for:

- planning;
- backend/database/RLS;
- frontend implementation;
- CI/CD;
- Google OAuth;
- Yandex Metrica;
- health check and logging;
- security audit;
- performance review;
- visual redesign;
- QA stabilization;
- README and screenshots;
- final documentation consistency.

## Problems Solved Through AI-Assisted Debugging

| Problem | AI-assisted diagnosis | Result |
|---|---|---|
| Backend choice risk | Paid Firebase Functions production constraint | Supabase Free Tier selected |
| RLS create-post failure | Post used another user's pet id | Flow changed to current user's pet |
| Storage policy ambiguity | SQL path check used ambiguous `name` | Policy fixed with `storage.objects.name` |
| Analytics privacy | Broad raw ids/content keys were not blocked | Sanitizer hardened |
| Documentation drift | Course-stage notes conflicted with final project story | Final documentation consolidated |

## Final Validation Snapshot

```text
flutter pub get: passed
dart format --set-exit-if-changed .: passed, 99 files checked, 0 changed
flutter analyze: passed, no issues found
flutter test: passed, 110 tests
flutter build web --release --dart-define=USE_SUPABASE_BACKEND=false --dart-define=ANALYTICS_ENABLED=false: passed
```

## Safety Notes

Prompts and outputs must not include:

- Supabase service role key, database password, JWT secret or access token;
- Google Client Secret;
- Netlify token or GitHub secrets;
- real user private data;
- raw JWTs, cookies, request headers or private analytics data.
