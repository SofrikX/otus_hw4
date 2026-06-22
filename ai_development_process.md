# AI Development Process

## AI agent

PetConnect is developed with OpenAI Codex as AI Product Manager, Solution Architect, Flutter/Supabase coding agent, QA Engineer, DevSecOps reviewer and Technical Writer.

The permanent agent rules are stored in `AGENTS.md`. Supporting workflow documents are `docs/ai_agent_rules.md`, `docs/ai_workflow.md`, `docs/documents_index.md`, `prompts.md` and `development_report.md`.

## How AI agents were used

| Area | AI usage in PetConnect |
|---|---|
| Idea generation | Codex helped turn the homework MVP into a product concept: a social web app for pet owners with feed, profiles, walks and chat scenarios |
| Requirements analysis | Codex compared homework requirements, earlier Firebase-oriented specification and current Supabase/Netlify stack |
| User stories | Codex structured roles, must-have scenarios and acceptance criteria in `docs/user_stories.md` |
| Technical specification | Codex prepared and evolved technical documentation, then separated historical Firebase decisions from current Supabase architecture |
| Database design | Codex designed PostgreSQL tables, relationships, constraints, indexes, counters and seed data |
| RLS/security design | Codex created and reviewed RLS policies for profile ownership, pet ownership, posts, comments, likes, walks and chats |
| Code generation | Codex generated Flutter repository implementations, Riverpod controllers/providers, auth flow, analytics, logging and Netlify health endpoint changes |
| Refactoring | Codex kept feature-first structure, moved logic into controllers/repositories and preserved mock repositories for tests/fallback |
| Tests | Codex added and maintained Flutter tests for feed, pets, walks, auth, chat, analytics, logging, router and API/Supabase mapping |
| CI/CD | Codex configured GitHub Actions quality gates, security audit job, Flutter Web build and Netlify deploy command |
| Security audit | Codex checked secrets hygiene, Supabase key exposure, RLS gaps, OAuth redirects, dependency audit and Flutter Web risks |
| Log analysis | Codex introduced structured logs and created prompt templates for AI-assisted analysis of auth, RLS, Netlify, Supabase and analytics issues |
| Performance optimization | Codex reviewed bundle size, logging overhead, analytics loading, rebuilds and image-loading risks; safe optimizations were applied |

## Generation of the idea

The product idea started from homework tasks around a pet owner application. AI-assisted product analysis shaped it into PetConnect: a social network for owners who want to share pet content, maintain pet profiles, find walks and communicate with nearby owners.

Codex helped formulate:

- the target audience;
- the user problem;
- core user journeys;
- MVP boundaries;
- portfolio-ready final project positioning.

## Requirements analysis

Codex read and reconciled:

- `README.md`;
- `AGENTS.md`;
- `docs/documents_index.md`;
- `docs/current_homework_scope.md`;
- `docs/project_description.md`;
- `docs/technical_specification.md`;
- `docs/user_stories.md`;
- `backend_documentation.md`;
- `integration_documentation.md`;
- `security_audit.md`;
- `development_report.md`;
- `prompts.md`;
- `pubspec.yaml`;
- `netlify.toml`;
- `.github/workflows/`;
- `supabase/`;
- `lib/`;
- `test/`;
- `docs/`.

The main architectural clarification was that Firebase remains a historical research branch, while the final project uses Supabase Free Tier for Auth, PostgreSQL, RLS, Storage and auto REST API.

## User stories and product scenarios

AI was used to structure user stories in a consistent format:

- guest registration and login;
- pet profile creation;
- feed viewing and post creation;
- likes and comments;
- chat scenario;
- nearby walk discovery and joining;
- future notifications and search improvements.

These stories drive the frontend screens, PostgreSQL schema, RLS model and test scenarios.

## Database design

Codex designed a relational Supabase schema instead of a document-oriented Firebase schema.

Key AI-supported decisions:

- split users into Supabase Auth users and public `profiles`;
- model pets as rows owned by profiles;
- model posts with pet and author references;
- separate comments and likes for queryability and RLS;
- model walks and participants as many-to-many relation;
- model chats through chat metadata, participants and messages;
- use constraints for string length, enums, non-negative counters and uniqueness;
- use triggers for likes, comments and participant counters where atomicity matters.

## Code generation

Codex generated or evolved code in small slices:

- repository interfaces in domain layers;
- Supabase repository implementations in data layers;
- mock repositories for local/test modes;
- Riverpod controllers/providers;
- auth controllers and protected routing;
- typed backend error mapping;
- analytics service and dispatcher;
- structured app logger;
- Netlify health function.

The implementation rule was constant: UI calls controllers/providers, controllers call repositories, repositories talk to Supabase or mock data.

## Refactoring

Refactoring focused on preserving architecture rather than rewriting the app:

- feature-first folders stayed under `lib/features`;
- shared widgets stayed under `lib/core/widgets`;
- backend configuration stayed in `lib/core/config`;
- Supabase initialization stayed in `lib/core/supabase`;
- mock repositories stayed available for tests and no-credential local runs;
- business logic stayed out of widgets where controller/provider methods existed.

## Testing

AI-assisted tests cover:

- auth controller and login screen behavior;
- Google OAuth button and error state;
- feed loading, post cards, likes, comments and controller logic;
- pets list/profile states and Supabase mapping;
- walks list, join flow and Supabase mapping;
- chat screen rendering;
- router protected redirect behavior;
- analytics service filtering;
- structured logging sanitization;
- API client/error mapping.

Validation commands used across the project:

```bash
dart format .
flutter analyze
flutter test
flutter build web --release --dart-define=USE_SUPABASE_BACKEND=false --dart-define=ANALYTICS_ENABLED=false
```

Supabase validation commands for local backend checks:

```bash
supabase db lint
supabase db reset
```

## CI/CD

Codex configured GitHub Actions as the automated quality gate:

- security audit job before build/deploy;
- secret marker scanning for runtime/configuration files;
- `.env*` and `.DS_Store` blocking;
- Flutter dependency check;
- npm audit for the historical Firebase Functions package;
- Dart formatting check;
- Flutter analysis and tests;
- Flutter Web release build;
- Netlify production deploy from `build/web` on `main`.

Secrets are stored in GitHub/Netlify settings, not in repository files.

## Security audit

AI-assisted security work included:

- checking tracked files for service role keys, secret markers and real env files;
- documenting that Supabase publishable key is public client configuration, not the security boundary;
- tightening RLS policies for post ownership, private post visibility, comment/like access and active walk joining;
- reviewing OAuth redirect URLs;
- reviewing Flutter Web DOM/XSS risk;
- auditing dependency vulnerabilities;
- adding CI security gates.

The main security boundary is Supabase Auth plus PostgreSQL RLS and Storage policies.

## Log analysis

Codex introduced structured logs with:

- levels `info`, `warning`, `error`;
- component/event fields;
- no secrets, tokens, emails, raw user ids or user-generated text;
- Netlify health check JSON logs;
- AI prompt templates for auth errors, RLS permission denied, Netlify deploy failures, Supabase API errors and missing analytics events.

This lets the developer paste sanitized logs into Codex and ask for root-cause analysis without exposing sensitive data.

## Performance optimization

Codex reviewed:

- Flutter Web release bundle size;
- unnecessary Riverpod rebuilds;
- verbose production logs;
- analytics loading overhead;
- future image loading from Supabase Storage.

Applied safe changes documented in `development_report.md`:

- `AppLogger.info` is skipped in Flutter release mode;
- disabled analytics no longer logs every dropped event;
- static stories strip no longer subscribes to Riverpod;
- release build remains tree-shaken.

## How AI will be used next

For the final project handoff, Codex should be used to:

- run a final documentation consistency pass;
- verify Netlify production after redeploy;
- repeat Supabase smoke checks;
- inspect CI failures if any;
- analyze sanitized health check logs;
- prepare a concise demo script for the reviewer;
- update `prompts.md` and `development_report.md` after each final validation task.

## Safety rules for future AI work

- Do not add secrets, service role keys, database passwords or private tokens to repository files.
- Do not replace Flutter/Supabase/Netlify with another stack unless explicitly requested.
- Do not reselect Firebase as production backend; keep it as historical exploration.
- Do not bypass repository/controller architecture by calling Supabase directly from widgets.
- Do not remove tests to make validation pass.
- Do not include personal data or production user content in prompts, logs or screenshots.
