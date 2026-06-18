# Frontend Deployment - PetConnect Flutter Web on Netlify

## Purpose

This document describes the planned production deployment for the PetConnect Flutter Web frontend.

Backend deployment remains Supabase. Frontend deployment is a static Flutter Web build hosted on Netlify Free so the reviewer can open PetConnect through a production URL.

The public Supabase Project URL can be documented for the production frontend. No real `SUPABASE_PUBLISHABLE_KEY`, Supabase secret key, service role key, database password or private token should be committed to the repository.

## Recommended Hosting

Recommended target: **Netlify Free**.

Netlify is a good fit for PetConnect because:

- Flutter Web produces static files that do not require a custom server;
- Netlify Free can host static educational projects without paid backend infrastructure;
- GitHub can be connected for automatic production deploys from the HW5 branch;
- deploy settings are simple: one build command and one publish directory;
- environment variables can be stored in Netlify UI instead of the repository;
- `build/web` can be uploaded manually as a fallback if Git-based build is blocked;
- Supabase remains the backend, so Netlify only serves the frontend assets.

Planned GitHub source:

```text
https://github.com/SofrikX/otus_hw4/tree/hw5-sb
```

Planned production Supabase project URL:

```text
https://<project-ref>.supabase.co
```

## Production Architecture

```text
Reviewer browser
  -> Netlify production URL
  -> Flutter Web static files from build/web
  -> supabase_flutter client
  -> Supabase Auth / PostgREST / Storage
  -> PostgreSQL tables protected by RLS
```

Responsibilities:

| Layer | Production service |
|---|---|
| Frontend | Flutter Web static release build |
| Frontend hosting | Netlify Free |
| Backend | Supabase |
| Auth | Supabase Auth |
| Database/API | PostgreSQL + Supabase auto REST API |
| Files | Supabase Storage |
| Security | Row Level Security and Storage policies |

The frontend must use only public client settings:

- `SUPABASE_URL`;
- `SUPABASE_PUBLISHABLE_KEY`;
- `USE_SUPABASE_BACKEND=true`.

The Supabase service role key is never used in Flutter Web.

## Production Build Command

The committed Netlify configuration uses this build command:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY
```

Build output:

```text
build/web
```

Netlify publish directory:

```text
build/web
```

## Netlify Environment Variables

In Netlify UI, configure production environment variables:

```text
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<your-supabase-publishable-key>
```

`USE_SUPABASE_BACKEND=true` is part of the committed build command. Use placeholders in documentation and commits. Store real values only in Netlify UI or local ignored environment files.

Because Flutter reads these values through `String.fromEnvironment` and `bool.fromEnvironment`, the values must be passed to the build command as `--dart-define`.

Recommended Netlify build command:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY
```

## Committed Netlify Configuration

`netlify.toml` contains:

```toml
[build]
  command = "flutter build web --release --dart-define=USE_SUPABASE_BACKEND=true --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

The redirect rule is required for Flutter Web SPA routes. Without it, direct browser navigation to app routes can return 404 from Netlify.

## Manual Deployment Fallback

If Netlify's default build environment does not include Flutter SDK, use this fallback:

1. Build locally with Flutter installed:

```bash
flutter build web --release \
  --dart-define=USE_SUPABASE_BACKEND=true \
  --dart-define=SUPABASE_URL=<production-supabase-project-url> \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<production-supabase-publishable-key>
```

2. Open Netlify Dashboard.
3. Create or open the PetConnect site.
4. Drag and drop the generated `build/web` folder into Netlify deploys.
5. Open the production URL and run the smoke scenario below.

For Git-based deploys where Flutter SDK is missing, another acceptable option is to add a Netlify build setup that installs the required Flutter SDK before the command in `netlify.toml`.

## Netlify Deploy Steps

1. Push the repository branch to GitHub.
2. In Netlify, create a new site from the GitHub repository.
3. Select the branch used for the HW5 submission.
4. Let Netlify read `netlify.toml`, or configure the same build command manually.
5. Set the publish directory to `build/web`.
6. Add `SUPABASE_URL=https://<project-ref>.supabase.co` and the real `SUPABASE_PUBLISHABLE_KEY` in Netlify environment variables.
7. Run the deploy.
8. Open the Netlify production URL and validate the app against the Supabase backend.

## Reviewer Validation

After deploy, the teacher should be able to:

1. Open the Netlify production URL.
2. Register or sign in with a demo Supabase user.
3. See feed, pets, walks and chat screens.
4. Create or inspect backend-backed data according to the prepared Supabase demo setup.
5. Confirm that the frontend talks to Supabase, not to local mock data, when `USE_SUPABASE_BACKEND=true`.

Recommended smoke scenario:

```text
Open production URL -> sign in -> load feed -> create pet/post -> like post -> join walk
```

## Security Notes

- Do not commit real Supabase keys to Git.
- Do not use service role key in Netlify frontend builds.
- `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are public Flutter Web client configuration and are embedded into the generated `build/web` bundle by `--dart-define`.
- `netlify.toml` uses `SECRETS_SCAN_OMIT_KEYS` for those two public keys so Netlify does not fail the deploy after detecting expected public client config in build output.
- Never add Supabase service role keys, database passwords or private access tokens to `SECRETS_SCAN_OMIT_KEYS`.
- Do not pass Supabase secret key or service role key through `--dart-define`; Flutter Web bundles are public.
- The publishable key is public client configuration, but it should still be managed through Netlify environment variables for reproducibility.
- RLS policies and Storage policies remain the security boundary for user data.
- PetConnect uses `SUPABASE_PUBLISHABLE_KEY`; legacy `SUPABASE_ANON_KEY` is not part of the Flutter Web deployment contract.
- If a key is accidentally committed, rotate it in Supabase before final submission.

## Remaining Production Tasks

- Create or select the final Netlify site.
- Add Netlify environment variables with the real Supabase project values.
- Run the production build.
- Deploy `build/web`.
- Record the final Netlify production URL in the submission notes.
- Run the reviewer smoke scenario against the deployed site.
