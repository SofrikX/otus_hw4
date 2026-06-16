# AGENTS.md - project instructions for OpenAI Codex

This file is the primary instruction file for OpenAI Codex in this repository.

Codex should use this file before making changes. The previous `.cursorrules` content from homework 2 was converted into Codex-compatible rules and into `docs/ai_agent_rules.md`. A root `.cursorrules` file is intentionally not used because the project is developed with OpenAI Codex, not Cursor.

## 1. Project context

Project: PetConnect.

PetConnect is a Flutter application for pet owners. The existing frontend MVP includes a pet social feed, pet profiles, walks, and a simple chat screen.

Current homework: HW5, "Backend deployment and integration with Frontend".

The original homework text offers Supabase or self-hosted PostgreSQL. PetConnect previously explored Firebase because Firebase was selected in the earlier technical specification. During production planning, Firebase Cloud Functions were identified as a poor fit for a free educational deployment because production deploy can require the Blaze/pay-as-you-go plan.

Current HW5 architecture decision: use Supabase Free Tier as the target backend.

The project must demonstrate:

- initialization and development with an AI coding agent;
- backend design based on the existing PetConnect user stories;
- Supabase Auth, PostgreSQL, Row Level Security, Supabase Storage and auto REST API;
- frontend-backend integration through repositories and Riverpod controllers;
- at least 3 backend/API operations;
- automated frontend validation and documented backend validation plan;
- documented AI workflow, prompts, debugging and conclusions.

## 2. Tech stack

Use only this stack unless the developer explicitly approves changes:

- Flutter
- Dart
- Riverpod / flutter_riverpod
- go_router
- Material 3
- feature-first structure with Clean Architecture principles
- Supabase Auth
- PostgreSQL
- Row Level Security
- Supabase Storage
- Supabase auto REST API / PostgREST
- `supabase_flutter`
- flutter_test and mocktail for Flutter tests
- Supabase SQL/RLS validation after migrations are added
- mock repositories only for tests, local fallback and incremental migration

Do not replace Flutter with React/Vue/Next.js. Do not add paid services. Do not reselect Firebase as the production backend unless the developer explicitly asks for that reversal.

## 3. Document routing

Before changing code, read `docs/documents_index.md` first. It explains which documents are active, what each file is for and when to use it.

Use this routing:

### Always read for project-level tasks

- `docs/documents_index.md`
- `docs/current_homework_scope.md`
- `docs/ai_agent_rules.md`

### Read for Supabase/backend tasks

- `backend_documentation.md`
- `docs/technical_specification.md`
- `docs/project_description.md`
- `docs/user_stories.md`
- `docs/error_handling.md`
- `docs/current_homework_scope.md`
- Supabase SQL/migration/policy files when they exist

### Read for frontend integration tasks

- `lib/app`
- `lib/core`
- `lib/features`
- `test`
- relevant feature documents and user stories

### Read for UI tasks

- `docs/ui_concepts/ui_description.md`
- `docs/ui_concepts/concept_2_bright_social.dart`
- `docs/ui_concepts/concept_2_bright_social.png` if image input is available

The selected UI direction remains concept 2: bright social network.

### Read for AI-process and report tasks

- `docs/ai_workflow.md`
- `docs/prompt_engineering_from_dz2.md`
- `prompts.md`
- `development_report.md`
- `submission_checklist.md`

Do not assume that every document must be fully read on every task. Use `docs/documents_index.md` to choose the relevant files and avoid wasting context.

## 4. Architecture rules

- Keep the structure: `lib/app`, `lib/core`, `lib/features`.
- Keep feature folders separated: `auth`, `feed`, `pets`, `walks`, `chat`, `home`.
- Keep domain models and repository interfaces outside widgets.
- Keep Riverpod providers/controllers in `application` folders.
- Keep Supabase and mock repository implementations in `data` folders.
- Keep screens and widgets in `presentation` folders.
- Keep shared UI in `lib/core/widgets`.
- Keep shared backend providers/configuration in `lib/core` or `lib/app`, not in widgets.
- Do not put business logic directly into Flutter widgets when it can be moved to controllers/providers.
- Do not add backend calls to UI components. UI must call application/controller methods, which use repositories.
- Preserve mock repositories where they help tests and local development, but do not keep UI coupled to `lib/core/data/mock_data.dart`.

## 5. Supabase rules

- Use Supabase Auth as the target source of the current user identity.
- Use PostgreSQL tables for profiles, pets, posts, comments, likes, chats, messages and walks.
- Use Supabase Storage for pet, post and profile images.
- Use RLS as a required part of the implementation, not as an afterthought.
- Use Supabase auto REST API / Supabase client for MVP operations.
- Use PostgreSQL RPC/functions only when validation, transactions, counters or protected writes cannot be expressed cleanly through regular client operations and RLS.
- Do not store secrets, service role keys or database passwords in the repository.
- Document any production deployment step separately from local validation.
- Do not claim Supabase is deployed until a project and migrations have actually been created.

## 6. UI and state rules

- Use Material 3 components.
- Use responsive layout through existing shared widgets such as `ResponsiveCenter`.
- Every important screen should handle loading, error, empty and success states when state is asynchronous.
- User-facing error messages must be short, friendly and useful.
- Use `const` constructors where possible.
- Avoid very large widgets; split widgets when readability suffers.
- Do not introduce custom styling systems unless needed.
- For this architecture-documentation step, do not change Flutter UI or business logic.

## 7. Testing and validation rules

When Dart/Flutter code changes are made, run or ask the developer to run:

```bash
dart format .
flutter analyze
flutter test
```

When Supabase SQL migrations or RLS policies are added, run or ask the developer to run when the CLI is configured:

```bash
supabase db lint
supabase db reset
```

For launch validation:

```bash
flutter run -d chrome
```

If Flutter platform files are missing, suggest:

```bash
flutter create . --platforms=web,android,ios
```

Do not delete tests only to make the suite pass. Fix the implementation or improve the test correctly.

## 8. Documentation rules

When a Codex task changes behavior, architecture, backend setup, tests or setup commands, update:

- `prompts.md` with the prompt and result;
- `development_report.md` with the problem, solution and AI-agent contribution;
- `README.md` when setup, commands, project scope, Supabase workflow or features change;
- `backend_documentation.md` when backend architecture changes;
- `docs/current_homework_scope.md` when HW5 scope changes.

Keep `submission_checklist.md` as a human checklist for the student. It is not a rules file for Codex.

## 9. Safety and scope constraints

- Do not add paid services or external APIs.
- Do not store secrets in the repository.
- Do not commit Supabase service role keys, database passwords or JWT secrets.
- Do not deploy production backend unless the developer explicitly asks for it.
- Do not require Firebase Blaze plan for local or production homework validation.
- Do not replace Flutter with React/Vue/Next.js.
- Do not add unnecessary dependencies.
- Do not rewrite the whole app when a targeted integration is enough.

## 10. Expected response format for Codex tasks

When responding to the developer:

1. State what files you inspected.
2. Give a short plan before large changes.
3. Make targeted changes.
4. Summarize changed files.
5. Provide validation commands and results.
6. Mention documentation updates when they were made.
