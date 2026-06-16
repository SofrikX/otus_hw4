# AGENTS.md — project instructions for OpenAI Codex

This file is the primary instruction file for OpenAI Codex in this repository.

Codex should use this file before making any changes. The previous `.cursorrules` content from homework 2 was converted into Codex-compatible rules and into `docs/ai_agent_rules.md`. A root `.cursorrules` file is intentionally not used because the project is developed with OpenAI Codex, not Cursor.

## 1. Project context

Project: PetConnect.

PetConnect is a Flutter application for pet owners. The existing frontend MVP includes a pet social feed, pet profiles, walks, and a simple chat screen.

Current homework: HW5, "Backend deployment and integration with Frontend".

The original homework text offers Supabase or self-hosted PostgreSQL. PetConnect already selected Firebase in the technical specification, so HW5 adapts the backend part to Firebase while preserving the homework goals: backend schema, API operations, security model, local validation, and frontend integration.

The project must demonstrate:

- initialization and development with an AI coding agent;
- backend design based on the existing PetConnect technical specification;
- Firebase Auth, Cloud Firestore, Firebase Storage, Cloud Functions, Security Rules, and Emulator Suite;
- frontend-backend integration through repositories and Riverpod controllers;
- at least 3 backend/API operations;
- automated frontend and backend validation;
- documented AI workflow, prompts, debugging, and conclusions.

## 2. Tech stack

Use only this stack unless the developer explicitly approves changes:

- Flutter
- Dart
- Riverpod / flutter_riverpod
- go_router
- Material 3
- feature-first structure with Clean Architecture principles
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Cloud Functions
- Firebase Security Rules
- Firebase Emulator Suite
- flutter_test and mocktail for Flutter tests
- npm test / Firebase emulator tests for Cloud Functions and rules
- mock repositories only for tests, local fallback, and incremental migration

Do not replace Flutter with React/Vue/Next.js. Do not replace Firebase with Supabase/PostgreSQL in this project unless the developer explicitly changes the PetConnect technical specification.

## 3. Document routing

Before changing code, read `docs/documents_index.md` first. It explains which documents are active, what each file is for, and when to use it.

Use this routing:

### Always read for project-level tasks

- `docs/documents_index.md`
- `docs/current_homework_scope.md`
- `docs/ai_agent_rules.md`

### Read for Firebase/backend tasks

- `docs/technical_specification.md`
- `docs/project_description.md`
- `docs/user_stories.md`
- `docs/error_handling.md`
- `docs/current_homework_scope.md`
- Firebase config/rules/functions files when they exist

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
- Keep Firebase and mock repository implementations in `data` folders.
- Keep screens and widgets in `presentation` folders.
- Keep shared UI in `lib/core/widgets`.
- Keep shared Firebase providers/configuration in `lib/core` or `lib/app`, not in widgets.
- Do not put business logic directly into Flutter widgets when it can be moved to controllers/providers.
- Do not add backend calls to UI components. UI must call application/controller methods, which use repositories.
- Preserve mock repositories where they help tests and local development, but do not keep UI coupled to `lib/core/data/mock_data.dart`.

## 5. Firebase rules

- Use Firebase Auth as the source of the current user identity.
- Use Cloud Firestore for users, pets, posts, comments, chats, messages, and walks.
- Use Firebase Storage for pet and post images.
- Use Cloud Functions for operations that require validation, transactions, counters, or protected writes.
- Use Firebase Security Rules as a required part of the implementation, not as an afterthought.
- Use Firebase Emulator Suite as the primary local backend scenario.
- Do not store secrets or service account keys in the repository.
- Document any production deployment step separately from emulator-based validation.
- Remember that Cloud Functions production deploy may require Firebase Blaze plan; keep the homework checkable locally through emulators.

## 6. UI and state rules

- Use Material 3 components.
- Use responsive layout through existing shared widgets such as `ResponsiveCenter`.
- Every important screen should handle loading, error, empty, and success states when state is asynchronous.
- User-facing error messages must be short, friendly, and useful.
- Use `const` constructors where possible.
- Avoid very large widgets; split widgets when readability suffers.
- Do not introduce custom styling systems unless needed.

## 7. Testing and validation rules

When Dart/Flutter code changes are made, run or ask the developer to run:

```bash
dart format .
flutter analyze
flutter test
```

When Cloud Functions, Security Rules, or emulator configuration changes are made, run or ask the developer to run:

```bash
npm test --prefix functions
firebase emulators:exec "npm test --prefix functions"
firebase emulators:start
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

When a Codex task changes behavior, architecture, Firebase setup, tests, or setup commands, update:

- `prompts.md` with the prompt and result;
- `development_report.md` with the problem, solution, and AI-agent contribution;
- `README.md` when setup, commands, project scope, Firebase emulator workflow, or features change;
- `docs/current_homework_scope.md` when HW5 scope changes.

Keep `submission_checklist.md` as a human checklist for the student. It is not a rules file for Codex.

## 9. Safety and scope constraints

- Do not add paid services or external APIs.
- Do not store secrets in the repository.
- Do not commit Firebase service account keys.
- Do not deploy Cloud Functions to production unless the developer explicitly asks for it.
- Do not require Firebase Blaze plan for local homework validation.
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
