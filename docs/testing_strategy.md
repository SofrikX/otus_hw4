# PetConnect Testing Strategy

Date: 23 June 2026

## Goal

Stabilize PetConnect before final submission with focused automated Flutter tests and a clear manual QA plan for flows that depend on hosted Supabase, OAuth redirects, Storage, analytics dashboards or production Netlify runtime.

## Test Pyramid

| Level | Scope | Tools | Status |
|---|---|---|---|
| Unit tests | Controllers, validation, filters, analytics, logger and API error mapping | `flutter_test`, fake repositories, `mocktail` where useful | Active |
| Widget tests | Auth forms, Feed/Pets/Walks/Chat screens, shared empty/loading/error states, delete confirmation dialogs | `flutter_test`, Riverpod provider overrides | Active |
| Repository mapping tests | Legacy API repositories and Supabase error mapping where architecture allows deterministic fakes | `flutter_test`, mocked HTTP/Supabase clients | Active |
| Manual QA | Google OAuth, hosted Supabase Auth/RLS/Storage, Netlify health endpoint, production responsive UI and analytics dashboard | Browser, Supabase Dashboard, Netlify, Yandex Metrica | Required before final handoff |

## Current Automated Coverage Audit

| Area | Automated evidence |
|---|---|
| Auth validation | Login and register widget tests validate malformed email and short password before repository calls. |
| Auth states | Login tests cover Google OAuth button, email loading, friendly email auth error and Google OAuth error. Router tests cover anonymous redirect in Supabase mode. |
| Pet form validation | `PetActions` tests cover trimming, animal type normalization, invalid age and owner-only update/delete guards. Pets widget tests cover create-form error display and delete confirmation dialog. |
| Post form validation | Feed controller tests cover empty post text, missing reference pet and repository failure without state mutation. Home widget test covers empty create-post bottom sheet inline error. |
| Walk form validation | Walk controller/widget tests cover title/place/time/description validation and create form error display. |
| Search/filter state | Feed search, pet search/type filters and walk date/location/status filters are covered through controller and widget tests. |
| Analytics disabled mode | Analytics service test verifies disabled mode does not dispatch events or log noise. |
| Logger behavior | Logger test verifies structured JSON output and removal of secrets, personal data and user content. |
| Error mapping | API client, API repositories and Supabase repository tests cover validation, unauthorized/forbidden/not found/server/network mapping where fakes are deterministic. |
| Widget async states | Feed and Walks cover loading/empty/error; Pets profile covers success/not found/backend error; Startup error app covers bootstrap failure. |
| Delete confirmation | Feed post deletion and Pet deletion widget tests verify confirmation dialogs before destructive actions. |

## Manual QA Boundary

Do not add brittle end-to-end tests until the project has stable browser automation infrastructure, seeded hosted users and isolated test data cleanup. The following remain manual for final submission:

- Google OAuth redirect through Supabase Dashboard and Netlify URLs;
- real Supabase Auth sign-up/sign-in against the hosted project;
- RLS smoke checks with two real users;
- Supabase Storage pet image upload/download/delete behavior;
- Yandex Metrica event arrival in the external dashboard;
- Netlify `/api/health` endpoint on production;
- desktop/mobile visual QA for responsive UI and browser-specific overflow.

## Validation Commands

Run before final submission:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

When Supabase local services are available:

```bash
supabase db lint
supabase db reset
```

For launch validation:

```bash
flutter run -d chrome
```

## Remaining Test Gaps

- Post image upload remains planned, so it has no automated UI/storage test yet.
- Google OAuth and Yandex Metrica dashboard verification are intentionally manual because they depend on external browser redirects and third-party dashboards.
- Hosted Supabase RLS validation should be repeated manually or with SQL smoke scripts after migrations are applied to the target project.
- Full browser E2E can be added later with seeded test accounts and cleanup, but it is intentionally out of scope for this stabilization pass.
