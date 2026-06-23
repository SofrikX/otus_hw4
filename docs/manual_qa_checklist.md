# PetConnect Manual QA Checklist

Date: 23 June 2026

Use this checklist after `flutter test` passes and before final submission. Record exact dates, browser, build URL and any blockers in `development_report.md`.

## Environment

- [x] Production Supabase backend project `fivtpxsjcjirddogngtl` has migrations `001`-`006` applied and verified.
- [ ] Production Netlify URL opens without a blank screen after the next frontend redeploy.
- [ ] Local debug run opens with `flutter run -d chrome`.
- [ ] Supabase project URL and publishable key are configured through environment variables, not committed files.
- [ ] Netlify env vars are configured: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER`, `YANDEX_METRICA_COUNTER_ID`.
- [ ] GitHub Actions has secrets `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`.
- [ ] GitHub Actions has variables `ANALYTICS_ENABLED`, `ANALYTICS_PROVIDER`, `YANDEX_METRICA_COUNTER_ID`.
- [ ] Test user credentials are stored outside the repository.

## Registration

- [ ] Open registration screen.
- [ ] Submit invalid email and short password; friendly validation is shown.
- [ ] Register with valid email/password and display name.
- [ ] Confirm the app redirects to the protected area.
- [ ] Confirm a `profiles` row exists or is updated for the new user.
- [ ] Sign out and sign back in with the same credentials.

## Google OAuth

- [ ] Confirm Supabase Dashboard contains exact localhost and Netlify redirect URLs.
- [ ] Click `Войти через Google`.
- [ ] Complete Google OAuth in the browser.
- [ ] Confirm the app returns to PetConnect and restores the session.
- [ ] Confirm no Google client secret appears in repository, frontend bundle logs or screenshots.

## Feed

- [ ] Feed loads recent posts.
- [ ] Empty feed state is friendly when no posts are visible.
- [ ] Backend error state is friendly when Supabase/API is unavailable.
- [ ] Create a valid text post.
- [ ] Submit an empty post and confirm inline validation.
- [ ] Like and unlike a post.
- [ ] Add a non-empty comment.
- [ ] Attempt an empty comment and confirm validation.
- [ ] Delete own post and confirm the dialog appears before deletion.

## Pets CRUD

- [ ] Pets list loads.
- [ ] Create pet with valid name, type, breed, age and description.
- [ ] Submit missing/invalid pet fields and confirm friendly validation.
- [ ] Open pet profile from the list.
- [ ] Edit own pet profile.
- [ ] Delete own pet profile and confirm the dialog appears first.
- [ ] Confirm another user's pet does not expose owner-only edit/delete actions.

## Image Upload

- [x] Backend bucket `pet-images` exists and is public-read.
- [x] Backend Storage write/update/delete policies are authenticated and owner/pet-scoped.
- [ ] Upload JPG, PNG or WebP pet image under 5 MB.
- [ ] Confirm image appears in pet list/profile.
- [ ] Confirm file path follows `pet-images/<auth.uid()>/<pet-id>/...`.
- [ ] Try unsupported file type and confirm friendly rejection.
- [ ] Try oversized file and confirm friendly rejection.
- [ ] Confirm no image bytes, tokens or private URLs are logged.

## Walks

- [ ] Walks list loads.
- [ ] Empty walks state is friendly.
- [ ] Create walk with valid title, place, future date/time and description.
- [ ] Submit invalid title/place/time/description and confirm validation.
- [ ] Join an active walk and confirm participant count changes.
- [ ] Leave a joined walk and confirm participant count changes.
- [ ] Confirm duplicate join is handled as already joined, not as a crash.

## Search And Filters

- [ ] Feed search matches post text, author and pet name.
- [ ] Feed no-result state appears for unmatched query and search can be cleared.
- [ ] Pet search matches pet name.
- [ ] Pet animal type chips filter by dog/cat/other and can be cleared.
- [ ] Walk filters work by location, date and status.
- [ ] Walk no-result state appears for unmatched filters and filters can be cleared.
- [ ] Verify filters do not expose private/deleted data.

## Analytics

- [ ] Local disabled run with `ANALYTICS_ENABLED=false` sends no analytics events.
- [ ] Production build has analytics env values configured only in Netlify/GitHub settings.
- [ ] Production build uses `YANDEX_METRICA_COUNTER_ID` for the Yandex Metrica counter.
- [ ] Trigger safe events: app open, sign in, feed open, search, create post, like, comment, join walk.
- [ ] Confirm Yandex Metrica receives event names and coarse params only.
- [ ] Confirm no email, raw user id, token, post text or comment text is sent.

## Health Endpoint

- [ ] Open `/api/health` on the Netlify production URL.
- [ ] Confirm JSON response does not expose environment variable values or secrets.
- [ ] Confirm Supabase reachability checks are green or documented as skipped.
- [ ] If the endpoint fails, capture sanitized status/error type only.

## Responsive UI

- [ ] Mobile viewport around `390 x 844`: bottom navigation works, forms fit, no horizontal overflow.
- [ ] Tablet viewport around `768 x 1024`: cards and filters remain readable.
- [ ] Desktop viewport around `1440 x 900`: navigation rail works, content width is constrained.
- [ ] Bottom sheets handle keyboard insets.
- [ ] Loading, empty and error states are readable on all viewports.
- [ ] Refresh final screenshots after production QA.

## Final Security And Performance QA

- [ ] Run tracked-source secret scan and confirm matches are documentation examples or sanitizer code only.
- [ ] Confirm local `.env.deploy` or other real env files are not tracked by Git and are not included in screenshots/prompts.
- [ ] Confirm Netlify secret scan omit list does not include service role keys, database passwords, JWT secrets or private tokens.
- [ ] Confirm `/api/health` response does not include Supabase URL, publishable key, service key, tokens, cookies, email or raw user ids.
- [ ] Confirm production browser console has no excessive info logs during normal feed/pets/walks usage.
- [ ] Confirm analytics events contain no email, raw ids, names, post/comment text, search text or location text.
- [ ] Confirm pet image placeholders and uploaded images do not shift layout or overflow on mobile/tablet/desktop.
- [ ] Confirm feed search, pet filters and walk filters remain responsive on the production dataset.
- [ ] Confirm final premium dark UI screenshots are refreshed after successful production redeploy.
