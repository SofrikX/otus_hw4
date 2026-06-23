# PetConnect Submission Package

Date: 23 June 2026

## Project Title

PetConnect - full-stack Flutter Web application for pet owners.

## Short Description

PetConnect helps pet owners create pet profiles, publish posts, react with likes and comments, discover walks, upload pet photos and use a responsive web interface backed by Supabase. The project is packaged as a final portfolio project with documented AI-assisted planning, implementation, QA, security review and release preparation.

## Public Links

| Resource | URL |
|---|---|
| GitHub repository | https://github.com/SofrikX/otus_hw4/tree/hw5-sb |
| Production app | https://cool-duckanoo-d28d04.netlify.app |
| Health check | https://cool-duckanoo-d28d04.netlify.app/api/health |
| Defense script | [docs/defense_script.md](defense_script.md) |

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter Web, Dart, Material 3 |
| State management | Riverpod / `flutter_riverpod` |
| Routing | `go_router` |
| Backend | Supabase Auth, PostgreSQL, Row Level Security, Storage, auto REST API |
| API client | `supabase_flutter` |
| Hosting | Netlify |
| CI/CD | GitHub Actions, Netlify CLI |
| Analytics | Yandex Metrica |
| Monitoring | Netlify Function `/api/health`, structured logs |
| Tests | `flutter_test`, `mocktail` |
| AI assistant | OpenAI Codex |

## Main Features

- Supabase email/password authentication.
- Google OAuth through Supabase Auth.
- Protected Flutter Web routes.
- Pet profiles with create, read, update, delete and photo upload.
- Social feed with post creation, likes, comments, search and owner-only delete.
- Walks with create, filters, join and leave flows.
- Search/filter UI for feed, pets and walks.
- Basic chat screen and chat/message database schema.
- Premium dark responsive visual redesign.
- Loading, empty, error and success states for async flows.
- Yandex Metrica analytics with privacy-safe event params.
- Netlify health endpoint and structured sanitized logging.

## Integrations

| Integration | Evidence |
|---|---|
| Supabase Auth | `lib/features/auth/`, `integration_documentation.md` |
| Google OAuth | `integration_documentation.md`, auth UI/button |
| Supabase PostgreSQL/RLS | `supabase/migrations/`, `backend_documentation.md`, `security_audit.md` |
| Supabase Storage | `004_pet_images_storage.sql`, pet photo upload flow |
| Netlify | `netlify.toml`, `netlify/functions/health.js` |
| GitHub Actions | `.github/workflows/ci_cd.yml` |
| Yandex Metrica | `lib/core/analytics/`, `integration_documentation.md` |

## CI/CD

GitHub Actions validates the project before production deployment:

- secret scan and repository hygiene gates;
- `flutter pub get`;
- `dart format --set-exit-if-changed .`;
- `flutter analyze`;
- `flutter test`;
- Flutter Web release build;
- Netlify production deploy on `main`.

## Backend And Database

Supabase is the final backend. PostgreSQL migrations define:

- `profiles`;
- `pets`;
- `posts`;
- `comments`;
- `post_likes`;
- `walks`;
- `walk_participants`;
- `chats`;
- `chat_participants`;
- `messages`;
- Storage buckets and policies for pet images.

Row Level Security is the authorization boundary. UI owner checks are UX helpers only.

## Documentation List

| Document | Purpose |
|---|---|
| [README.md](../README.md) | Main project overview, setup, demo flow and links. |
| [project_documentation.md](../project_documentation.md) | Product, architecture, deployment and final requirements coverage. |
| [ai_development_process.md](../ai_development_process.md) | AI-assisted development process and examples. |
| [technical_specification.md](../technical_specification.md) | Final technical specification. |
| [user_stories.md](../user_stories.md) | User stories and acceptance criteria. |
| [backend_documentation.md](../backend_documentation.md) | Supabase backend, schema, RLS and Storage documentation. |
| [integration_documentation.md](../integration_documentation.md) | Google OAuth, CI/CD, Netlify, analytics and health integrations. |
| [security_audit.md](../security_audit.md) | Final security and performance audit. |
| [final_release_checklist.md](../final_release_checklist.md) | Final release/submission checklist. |
| [docs/manual_qa_checklist.md](manual_qa_checklist.md) | Manual production QA checklist. |
| [docs/testing_strategy.md](testing_strategy.md) | Automated and manual testing strategy. |
| [docs/defense_script.md](defense_script.md) | Defense script, demo flow and possible Q&A. |
| [docs/screenshots/README.md](screenshots/README.md) | Screenshot checklist and privacy rules. |

## Demo Checklist

Use this flow for a reviewer demonstration:

- [ ] Open the production app.
- [ ] Sign in or register with reviewer-safe credentials provided outside git.
- [ ] Confirm Google OAuth button is visible.
- [ ] Open Feed and verify posts load.
- [ ] Create a post for an owned pet.
- [ ] Like and comment on a post.
- [ ] Use feed search.
- [ ] Open Pets, create/edit a pet and upload a photo.
- [ ] Use pet filters.
- [ ] Open Walks, create a walk and join/leave a walk.
- [ ] Use walk filters.
- [ ] Open Chat to show the basic chat screen.
- [ ] Open `/api/health`.
- [ ] Show GitHub Actions green run.
- [ ] Show Netlify production deploy status.
- [ ] Show Supabase tables/RLS/Storage without exposing credentials.
- [ ] Show Yandex Metrica overview without personal/private data.

## Screenshots Checklist

See [docs/screenshots/README.md](screenshots/README.md). The final screenshot set should include:

- refreshed app screenshots after the final dark visual redesign;
- landing/auth screen;
- Google OAuth button;
- feed with posts;
- create post form;
- pets list;
- pet image upload UI;
- walks list;
- filters/search;
- mobile layout;
- GitHub Actions green run;
- Netlify production deploy;
- Supabase database tables;
- Supabase Storage bucket;
- Yandex Metrica overview without personal/private data.

## How To Verify Project

Local no-secret run:

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=USE_SUPABASE_BACKEND=false \
  --dart-define=ANALYTICS_ENABLED=false
```

Automated validation:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=false \
  --dart-define=ANALYTICS_ENABLED=false
```

Production verification:

- open the production app URL;
- run the demo checklist above;
- open `/api/health`;
- verify GitHub Actions and Netlify deploy status;
- verify Supabase dashboard settings without exposing secrets;
- verify Yandex Metrica overview only at aggregate level.

## Known Limitations

- Google OAuth redirect settings live in Supabase Dashboard and Google Cloud Console, so they must be manually verified.
- Supabase dashboard screenshots must avoid row-level private data and secrets.
- Yandex Metrica screenshots must use aggregate overview only.
- App screenshots in `docs/screenshots/01`-`09` use demo/mock-safe UI data and do not show production credentials.
- Post image upload, avatar upload and full chat message sending are future enhancements.
- No penetration test was performed; the project includes code/configuration security audit and manual QA.

## Privacy And Safety

Do not include in screenshots, prompts, docs or submission messages:

- Supabase service role key;
- Supabase secret key, database password, JWT secret or access token;
- Google Client Secret;
- Netlify auth token;
- GitHub secrets;
- real user private data;
- raw cookies, JWTs, OAuth callback codes or authorization headers.

Blur or crop emails if they appear in Supabase, GitHub, Netlify, Yandex Metrica or browser UI screenshots.

## Contacts / Author

Author and repository owner: GitHub user `SofrikX`.

Course/reviewer contact details should be provided through the official repository submission form or learning platform, not committed to the repository.
