# PetConnect Integration Documentation

## Purpose

This document describes service integrations added for HW6, "CI/CD and service integration". It is safe for git: it contains no real Netlify tokens, Supabase publishable keys, service role keys, database passwords or private access tokens.

Current production stack:

| Layer | Service |
|---|---|
| Frontend | Flutter Web |
| Backend | Supabase Auth, PostgreSQL, RLS, Storage and auto REST API |
| Hosting | Netlify |
| CI/CD | GitHub Actions |
| AI development agent | OpenAI Codex |

## CI/CD

Workflow file:

```text
.github/workflows/ci_cd.yml
```

Triggers:

- `pull_request`: validates code quality, tests and release build before merge;
- `push` to `main`: validates code quality, tests, release build and deploys to Netlify production.

Pipeline stages:

1. Checkout repository with `actions/checkout`.
2. Install Flutter stable with `subosito/flutter-action`.
3. Restore Flutter cache through the setup action.
4. Run `flutter pub get`.
5. Run `dart format --set-exit-if-changed .`.
6. Run `flutter analyze`.
7. Run `flutter test`.
8. Build Flutter Web release with Supabase dart-defines.
9. Deploy `build/web` to Netlify only on `push` to `main`.

Build command:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=${{ secrets.SUPABASE_PUBLISHABLE_KEY }}
```

Deploy command:

```bash
npx --yes netlify-cli@latest deploy \
  --prod \
  --dir=build/web \
  --site="$NETLIFY_SITE_ID" \
  --auth="$NETLIFY_AUTH_TOKEN"
```

## GitHub Secrets

Add these values in GitHub repository settings under Actions secrets:

| Secret | Required for | Notes |
|---|---|---|
| `NETLIFY_AUTH_TOKEN` | Netlify production deploy | Private token, never commit |
| `NETLIFY_SITE_ID` | Netlify production deploy | Site identifier, keep in CI settings |
| `SUPABASE_URL` | Flutter Web release build | Public client config, managed as CI env |
| `SUPABASE_PUBLISHABLE_KEY` | Flutter Web release build | Public client config, managed as CI env |

Do not add Supabase service role key, database password, JWT secret or private access tokens to the frontend CI/CD workflow.

## Netlify Integration

Netlify remains the production frontend host:

```text
https://cool-duckanoo-d28d04.netlify.app/
```

The GitHub Actions workflow deploys the already built Flutter Web artifact from:

```text
build/web
```

The repository also keeps `netlify.toml` for Netlify-compatible build settings and SPA redirect behavior. `build/web` remains ignored by git and must not be committed.

## Security Notes

- Pull requests run validation and build but do not deploy.
- Production deployment runs only for `push` to `main`.
- Secrets are referenced through GitHub Actions `${{ secrets.* }}` and are not written into repository files.
- `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are embedded into Flutter Web output by design; Supabase RLS and Storage policies remain the user-data security boundary.
- Netlify deploy uses `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` only inside the deploy step.

## Local Validation

Before pushing, run:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<production-supabase-project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

Use real Supabase values only through local ignored env files or shell environment. Do not paste them into documentation.
