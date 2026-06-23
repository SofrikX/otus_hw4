# PetConnect Screenshots

This folder stores public, portfolio-safe screenshots for the PetConnect final project README, defense script and submission package.

The app screenshots were refreshed after the final premium dark visual redesign. They were captured from the local Flutter Web app in mock/demo mode at safe viewports, so they do not include production credentials, private dashboard values, personal emails or access tokens. External dashboard screenshots remain manual-only because GitHub, Netlify, Supabase and Yandex Metrica pages can expose private data depending on account state.

## Current App Files

| File | View | Size | Status |
|---|---|---:|---|
| `01_landing_auth_desktop.png` | Landing/auth screen with Google OAuth button | 1440 x 1000 | Refreshed |
| `02_feed_desktop.png` | Feed screen with posts, search and post cards | 1440 x 1000 | Refreshed |
| `03_create_post_desktop.png` | Create post bottom sheet/form | 1440 x 1000 | Refreshed |
| `04_pets_desktop.png` | Pets list with filters and pet cards | 1440 x 1000 | Refreshed |
| `05_pet_image_upload_desktop.png` | Pet profile image upload UI | 1440 x 1000 | Refreshed |
| `06_walks_desktop.png` | Walks list with filters and walk cards | 1440 x 1000 | Refreshed |
| `07_search_filters_desktop.png` | Active walk filter state | 1440 x 1000 | Refreshed |
| `08_mobile_auth.png` | Mobile auth/landing screen | 390 x 844 | Refreshed |
| `09_mobile_app.png` | Mobile Feed screen | 390 x 844 | Refreshed |
| `petconnect_desktop.png` | README compatibility copy of current desktop feed | 1440 x 1000 | Refreshed |
| `petconnect_mobile.png` | README compatibility copy of current mobile feed | 390 x 844 | Refreshed |

Refresh app screenshots again after any visual change or production browser QA pass.

## Required Screenshot Checklist

Use this checklist for the final portfolio package:

- [x] Landing/auth screen after final redesign.
- [x] Google OAuth button.
- [x] Feed with posts.
- [x] Create post form.
- [x] Pets list.
- [x] Pet image upload UI.
- [x] Walks list.
- [x] Filters/search.
- [x] Final dark visual redesign.
- [x] Mobile responsive view.
- [ ] GitHub Actions green run.
- [ ] Netlify production deploy.
- [ ] Supabase database tables.
- [ ] Supabase Storage bucket.
- [ ] Yandex Metrica overview without personal/private data.

## Manual External Screenshot Checklist

Capture these manually only from safe overview pages:

| File | Capture | Safety rule |
|---|---|---|
| `10_github_actions_green.png` | GitHub Actions successful workflow summary | Do not show repository secrets, logs with env values or private tokens. |
| `11_netlify_deploy_green.png` | Netlify production deploy summary | Do not show environment variables or deploy tokens. |
| `12_supabase_tables.png` | Supabase table list/schema overview | Show table names only; avoid row-level user data and settings pages with keys. |
| `13_supabase_storage.png` | Supabase Storage bucket overview | Show bucket names/policies only; avoid object URLs with private data. |
| `14_yandex_metrica_overview.png` | Yandex Metrica aggregate overview | Use aggregate dashboard only; hide personal data and visitor-level details. |

Suggested external screenshot viewport: desktop `1440 x 1000`.

## Privacy Rules

Screenshots must not contain:

- Supabase service role key, secret key, database password, JWT secret or access token;
- Google Client Secret;
- Netlify auth token or GitHub secrets;
- Supabase access token;
- real user email, private profile data, private messages or personal analytics data;
- full request headers, cookies, OAuth callback codes or bearer tokens.

Use demo data or blurred/redacted admin dashboard views for backend, CI/CD and analytics screenshots. Blur email addresses when they appear in admin dashboards, auth screens, browser autocomplete or analytics views.

## Recommended Captures

| Capture | Notes |
|---|---|
| Desktop app | `1440 x 1000`, final dark UI, no browser devtools |
| Mobile app | `390 x 844`, bottom navigation visible |
| Supabase tables | Table names and row counts only, no private row data |
| Supabase Storage | `pet-images` bucket and policy summary, no secret config |
| GitHub Actions | Successful workflow summary, no secrets |
| Netlify deploy | Production deploy status, no environment variable values |
| Yandex Metrica | Overview/events with personal data hidden |

## Recreate App Screenshots Manually

If automation is unavailable, run the app locally in mock mode and capture the same routes/states:

```bash
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 3000 \
  --dart-define=USE_SUPABASE_BACKEND=false \
  --dart-define=ANALYTICS_ENABLED=false
```

Open `http://127.0.0.1:3000` and use these viewports:

- desktop: `1440 x 1000`;
- mobile: `390 x 844`.

Use hash routes when opening a detail route directly, for example:

```text
http://127.0.0.1:3000/#/pets/pet-1
```

Do not open DevTools or browser password manager popups while capturing.
