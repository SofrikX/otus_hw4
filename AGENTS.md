# AGENTS.md — project instructions for OpenAI Codex

This file is the primary instruction file for OpenAI Codex in this repository.

Codex should use this file before making any changes. The previous `.cursorrules` content from homework 2 was converted into these Codex-compatible rules and into `docs/ai_agent_rules.md`. A root `.cursorrules` file is intentionally not used because the project is developed with OpenAI Codex, not Cursor.

## 1. Project context

Project: PetConnect.

PetConnect is a Flutter frontend MVP for pet owners. The app combines a pet social feed, pet profiles, walks, and a simple chat screen.

Current homework: "Frontend application development with an AI agent".

The project must demonstrate:

- initialization and development with an AI coding agent;
- UI implementation based on the previous design concept;
- at least 3 main user functions;
- adaptive layout;
- at least 3 automated tests;
- documented AI workflow, prompts, debugging, and conclusions.

## 2. Tech stack

Use only this stack unless the developer explicitly approves changes:

- Flutter
- Dart
- Riverpod / flutter_riverpod
- go_router
- Material 3
- feature-first structure with Clean Architecture principles
- flutter_test and mocktail for tests
- mock data for the current MVP

Firebase Auth, Firestore, Storage, and FCM are part of the target architecture from the technical specification, but they must not be connected in this MVP unless the developer explicitly asks for it.

## 3. Document routing

Before changing code, read `docs/documents_index.md` first. It explains which documents are active, what each file is for, and when to use it.

Use this routing:

### Always read for project-level tasks

- `docs/documents_index.md`
- `docs/current_homework_scope.md`
- `docs/ai_agent_rules.md`

### Read for product and requirements tasks

- `docs/technical_specification.md`
- `docs/project_description.md`
- `docs/user_stories.md`
- `docs/error_handling.md`

### Read for UI tasks

- `docs/ui_concepts/ui_description.md`
- `docs/ui_concepts/concept_2_bright_social.dart`
- `docs/ui_concepts/concept_2_bright_social.png` if image input is available

The selected UI direction for the MVP is concept 2: bright social network.

### Read for AI-process and report tasks

- `docs/ai_workflow.md`
- `docs/prompt_engineering_from_dz2.md`
- `prompts.md`
- `development_report.md`
- `submission_checklist.md`

Do not assume that every document must be fully read on every task. Use `docs/documents_index.md` to choose the relevant files and avoid wasting context.

## 4. Architecture rules

- Keep the structure: `lib/app`, `lib/core`, `lib/features`.
- Keep feature folders separated: `feed`, `pets`, `walks`, `chat`, `home`.
- Keep domain models outside widgets.
- Keep Riverpod providers/controllers in `application` folders.
- Keep screens and widgets in `presentation` folders.
- Keep shared UI in `lib/core/widgets`.
- Keep mock data in `lib/core/data/mock_data.dart`.
- Do not put business logic directly into Flutter widgets when it can be moved to controllers/providers.
- Do not add backend calls to UI components.

## 5. UI and state rules

- Use Material 3 components.
- Use responsive layout through existing shared widgets such as `ResponsiveCenter`.
- Every important screen should handle loading, error, empty, and success states when state is asynchronous.
- User-facing error messages must be short, friendly, and useful.
- Use `const` constructors where possible.
- Avoid very large widgets; split widgets when readability suffers.
- Do not introduce custom styling systems unless needed.

## 6. Testing and validation rules

When code changes are made, run or ask the developer to run:

```bash
dart format .
flutter analyze
flutter test
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

## 7. Documentation rules

When a Codex task changes behavior, architecture, tests, or setup, update:

- `prompts.md` with the prompt and result;
- `development_report.md` with the problem, solution, and AI-agent contribution;
- `README.md` only when setup, commands, project scope, or features change.

Keep `submission_checklist.md` as a human checklist for the student. It is not a rules file for Codex.

## 8. Safety and scope constraints

- Do not add paid services or external APIs.
- Do not store secrets in the repository.
- Do not connect Firebase in this homework unless explicitly requested.
- Do not replace Flutter with React/Vue/Next.js.
- Do not add unnecessary dependencies.
- Do not rewrite the whole app when a targeted fix is enough.

## 9. Expected response format for Codex tasks

When responding to the developer:

1. State what files you inspected.
2. Give a short plan before large changes.
3. Make targeted changes.
4. Summarize changed files.
5. Provide validation commands and results.
6. Mention documentation updates when they were made.
