# PetConnect AI Development Process

Date: 23 June 2026

PetConnect was developed with OpenAI Codex as an AI-assisted product, architecture, implementation, QA, security and documentation partner. Human review remained responsible for accepting changes, protecting secrets, validating production settings and deciding project scope.

## AI Usage Overview

| Stage | AI usage | Result |
|---|---|---|
| Planning | Interpreted course requirements and turned them into a product/release plan | Final Flutter Web + Supabase portfolio scope |
| Idea and product analysis | Clarified target users, problem, solution and demo story | Pet owner social app positioning |
| User stories | Structured features with acceptance criteria and priority | `user_stories.md` |
| Technical specification | Defined stack, architecture, data model, integrations and non-functional requirements | `technical_specification.md` |
| UI/UX concept | Reviewed MVP screens and guided final premium dark redesign | `docs/ui_ux_audit.md`, redesigned Flutter UI |
| Frontend implementation | Generated/refined Riverpod controllers, repository usage, forms, states and tests | Feature-first Flutter Web app |
| Backend/database design | Designed PostgreSQL schema, relationships, constraints, indexes and counters | Supabase migrations |
| RLS and Storage | Created and audited owner/visibility-scoped policies and pet image bucket policies | Hardened Supabase authorization |
| Testing | Added and maintained unit/widget/repository tests | 110 passing Flutter tests |
| Debugging | Diagnosed auth, RLS, deployment and frontend issues from sanitized logs/errors | Targeted fixes without weakening security |
| Security audit | Checked secrets, RLS, Storage, logs, analytics, health endpoint and CI secrets | `security_audit.md` |
| Performance optimization | Reviewed bundle size, production logs, analytics loading, rebuilds and images | Lazy analytics, reduced release logs, shared UI patterns |
| CI/CD | Configured GitHub Actions and Netlify deployment flow | Automated security/build/test/deploy pipeline |
| Log analysis | Created safe logging strategy and AI prompt templates | `docs/logging.md` |
| Documentation | Produced README, project docs, backend/integration docs, reports and prompt journal | Final submission package |

## Planning Stage

AI helped convert a sequence of course tasks into one final product narrative. The final project was framed as a full-stack Flutter Web application with Supabase backend, Netlify deployment, CI/CD, security review, analytics, monitoring and AI-documented workflow.

Human review decisions:

- keep Flutter Web as the final frontend;
- use Supabase as final backend;
- keep Netlify as hosting;
- avoid paid services and committed secrets;
- preserve mock mode for tests and local demo.

## Idea And Product Analysis

The initial pet-owner app idea was shaped into a compact product:

- pet profiles;
- social feed;
- local walks;
- lightweight chat;
- media upload;
- community interactions.

AI output included target audience, problem statement, solution framing and demo flow. Human review kept the MVP focused and scoped notifications/payments as non-final enhancements.

## User Stories And Technical Specification

AI created structured user stories for:

- authentication;
- pet profiles;
- feed/posts;
- comments and likes;
- walks;
- search/filters;
- image upload;
- analytics;
- monitoring.

AI also produced the technical specification covering frontend architecture, backend schema, CRUD/API matrix, RLS, integrations, deployment, CI/CD, security and testing.

## UI/UX Concept And Final Visual Redesign

AI reviewed the existing MVP UI and final requirements, then guided a premium dark redesign:

- dark navy/black design tokens;
- violet/blue gradients;
- glass cards;
- redesigned auth, feed, pets, walks, pet profile and chat surfaces;
- responsive mobile/desktop behavior;
- shared loading/empty/error states.

Human review constrained the redesign: no routing rewrite, no backend schema change, no RLS change and no replacement of Riverpod/repository architecture.

## Frontend Implementation

AI helped implement and refine:

- feature-first folders under `lib/features`;
- shared widgets under `lib/core/widgets`;
- auth controller and protected routes;
- feed controller and post/comment/like flows;
- pet CRUD and photo upload flow;
- walk create/join/leave/filter flow;
- analytics and logging services;
- error/loading/empty states.

Implementation rule: widgets call controllers/providers; controllers use repository interfaces; repositories talk to Supabase or mock data.

## Backend And Database Design

AI designed a relational Supabase model:

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

AI-generated migration work included constraints, indexes, timestamp triggers and counter triggers for likes, comments and participants.

## Supabase Migrations And RLS

AI assisted with:

- initial schema migration;
- RLS policy migration;
- authenticated grants for PostgREST;
- `pet-images` Storage migration;
- production corrective migrations for policy drift and Storage path checks.

Important security decisions:

- no service role key in Flutter Web;
- owner-scoped writes;
- visible-post checks for comments and likes;
- active-walk check for joining;
- participant-scoped chat/message visibility;
- owner/pet-scoped Storage object paths.

## Testing

AI-assisted automated tests cover:

- auth validation and controller state;
- router redirects;
- feed loading/empty/error/success states;
- post create/delete, comments and likes;
- pet CRUD and filters;
- walks create/join/leave/filter flows;
- analytics privacy filtering;
- logger sanitization;
- Supabase/API error mapping.

Manual test boundaries remain for Google OAuth, hosted Supabase/RLS smoke checks, real Storage upload, Yandex Metrica dashboard and production responsive browser QA.

## Debugging

AI debugging examples:

- diagnosed RLS error on create post caused by selecting a pet owned by another user;
- fixed create-post flow to use current user's pet without weakening RLS;
- reviewed OAuth redirect configuration;
- reviewed health endpoint behavior;
- checked analytics/log privacy.

Debugging used sanitized logs and avoided raw tokens, emails, user ids or secrets.

## Security Audit

AI security review covered:

- hardcoded secrets;
- `.env` files;
- service role keys and `sb_secret_` markers;
- Google Client Secret leakage;
- Yandex Metrica privacy;
- unsafe logs;
- OAuth redirect notes;
- Supabase Storage upload risks;
- RLS policies;
- CRUD authorization;
- analytics privacy;
- health endpoint leakage;
- Netlify/GitHub Actions secret usage.

Result: no tracked private credentials were found; final fixes hardened analytics param filtering and documentation.

## Performance Optimization

AI reviewed:

- Flutter Web release build behavior;
- excessive logs;
- analytics overhead;
- unnecessary Riverpod rebuilds;
- image loading and placeholders;
- search/filter cost;
- responsive layout complexity;
- health endpoint cost.

Applied safe optimizations:

- release `info` logs are skipped;
- disabled analytics is silent;
- analytics loads lazily;
- shared UI primitives reduce duplication;
- pet images are constrained.

## CI/CD

AI configured GitHub Actions:

- security audit job;
- secret marker scan;
- `.env*` and `.DS_Store` gate;
- dependency checks;
- Dart formatting;
- Flutter analysis;
- Flutter tests;
- Flutter Web release build;
- Netlify deploy.

Human review keeps real Netlify and Supabase values in provider secret stores, not in the repository.

## Log Analysis

AI produced `docs/logging.md` with:

- structured log format;
- safe/unsafe fields;
- Netlify and Supabase log inspection notes;
- prompt templates for auth errors, RLS denial, deploy failures, API errors and analytics missing events.

## Documentation

AI generated and maintained:

- `README.md`;
- `project_documentation.md`;
- `user_stories.md`;
- `technical_specification.md`;
- `backend_documentation.md`;
- `integration_documentation.md`;
- `security_audit.md`;
- `docs/testing_strategy.md`;
- `docs/manual_qa_checklist.md`;
- `docs/screenshots/README.md`;
- `docs/submission_package.md`;
- `development_report.md`;
- `prompts.md`.

## Prompt Examples

| Prompt category | Goal | AI output | Human review | Result |
|---|---|---|---|---|
| Planning | Turn course requirements into a final project plan | Scope, stack, artifacts and validation plan | Confirmed free-tier and Flutter Web constraints | Supabase + Netlify final architecture |
| Backend | Design schema and RLS | SQL migrations, policies and docs | Reviewed for owner scoping and no secrets | PostgreSQL/RLS backend |
| Frontend | Add feature flows through repositories/controllers | Riverpod controllers, widgets and tests | Checked architecture boundaries | Feed, pets, walks and auth flows |
| CI/CD | Configure automated delivery | GitHub Actions workflow and Netlify config | Verified secret handling | Build/test/deploy pipeline |
| Security | Audit secrets, RLS, logs and analytics | Findings, fixes and remaining risks | Accepted only safe small fixes | Final security audit |
| Visual redesign | Create premium portfolio UI | Theme tokens, shared widgets and redesigned screens | Preserved behavior and tests | Final dark UI |
| QA | Stabilize tests and manual checklist | Automated tests and manual QA matrix | Kept external flows manual | 110 passing tests |
| Documentation | Package final project | README, reports and submission docs | Removed stale course-stage framing | Portfolio-ready docs |

## Lessons Learned

- AI is strongest when prompts include role, context, constraints and validation commands.
- Human review is essential for secrets, production settings and scope control.
- RLS should be treated as the backend security boundary, not UI ownership checks.
- Documentation must be updated as architecture evolves, otherwise historical decisions look like contradictions.
- Final portfolio packaging needs a different tone from internal development logs.
