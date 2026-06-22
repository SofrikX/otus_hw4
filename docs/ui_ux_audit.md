# PetConnect UI/UX And Responsive Audit

Date: 23 June 2026

Role: UI/UX Designer, Flutter Web Developer and Accessibility Reviewer.

## Review inputs

Reviewed files and folders:

- `docs/documents_index.md`, `docs/current_homework_scope.md`, `docs/ai_agent_rules.md`;
- `README.md`;
- `project_documentation.md`;
- `final_project_gap_analysis.md`;
- `user_stories.md`;
- `technical_specification.md`;
- `lib/app/`;
- `lib/core/`;
- `lib/features/`;
- `test/`.

Note: `lib/shared/` does not exist in this repository. Shared UI widgets are located in `lib/core/widgets/`.

## Summary

PetConnect already has a clear MVP UI foundation for the final project: Material 3, protected routes, bottom navigation on mobile, navigation rail on desktop, responsive content constraints, and reusable loading, empty and error state widgets.

The application covers the required minimum of three main screens through Feed, Pets and Walks. Auth and Chat are additional supporting flows. The main UX gaps are not architectural blockers: create pet/walk flows are not fully exposed in UI, Storage images are still represented mostly by emoji placeholders, visible search/filter controls are planned rather than implemented, and final browser QA screenshots should be refreshed after production redeploy.

## Main screens

| Screen | Route / location | UX status |
|---|---|---|
| Login | `/login` | Email/password form, Google OAuth button, loading states and auth error banner are present. |
| Register | `/register` | Registration form, loading state and auth error banner are present. |
| Home shell | `/` | Hosts Feed, Pets, Walks and Chat destinations. |
| Feed | Home destination | Shows header, pet stories, post cards, like/comment actions, refresh, create-post entry point and async states. |
| Pets | Home destination | Shows pet list cards and navigates to profile details. |
| Pet profile | `/pets/:petId` | Shows pet summary, owner and interest action; handles unknown pet id. |
| Walks | Home destination | Shows active walk cards and join action. |
| Chat | Home destination | Shows basic chat thread list or empty state. |
| Startup error | `StartupErrorApp` | Provides a fallback when app initialization fails. |

## Desktop behavior

- At widths from 900 px, `HomeScreen` switches from bottom navigation to `NavigationRail`.
- Feed create-post action moves to the app bar on wide layout.
- Main content is constrained by `ResponsiveCenter`, which keeps lists readable on desktop.
- Cards, chips and text blocks generally avoid horizontal overflow because list items use `Expanded`, `Wrap` and constrained media heights.
- Modal create-post UI is now constrained to a readable max width instead of stretching across the full desktop viewport.

## Mobile behavior

- Mobile layout uses Material 3 `NavigationBar` with four destinations.
- Feed create-post action is exposed through a floating action button.
- Lists have bottom padding so content is not hidden behind bottom navigation.
- Forms use scrollable `ListView` content, which helps small screens and virtual keyboard scenarios.
- Bottom sheets account for keyboard insets.

## Navigation

- `go_router` protects authenticated routes when backend mode requires auth.
- Main navigation is predictable: Feed, Pets, Walks and Chat remain stable across mobile and desktop.
- Pet profile detail route is available from pet cards.
- Routing was not changed during this audit.

## Forms

- Login and register forms have validators, disabled loading states and clear primary actions.
- Create-post bottom sheet has inline empty-text validation, disabled submit during publishing, progress feedback, max length, helper text, keyboard-aware padding and a friendly success snackbar.
- Comment bottom sheet validates empty comments before closing, limits comment length and keeps the user in context.
- Create pet and create walk bottom sheets are centered on desktop, constrained to readable width, keyboard-aware on mobile and disable fields/actions while saving.

## Empty states

- Shared `EmptyState` is used for feed, pets, walks and chat.
- Empty states now support contextual icons and optional actions.
- Feed, Pets and Walks provide refresh actions in their empty states.
- Remaining gap: empty states for not-yet-exposed create pet/create walk flows should become creation CTAs only after those UI flows are complete.

## Loading states

- Async screens use `AsyncContentView` and Riverpod `AsyncValue`.
- Loading state uses `CircularProgressIndicator`.
- Loading indicator now has a semantic label/live-region hint for assistive technologies.
- Submit buttons for post publishing, pet save, walk save, pet photo upload and walk join/leave show compact in-button progress instead of blocking unrelated UI.

## Error states

- Shared `ErrorState` provides title, friendly message and retry action.
- `AsyncContentView` maps `ApiException` to user-facing messages.
- Login/register show auth error banners.
- Create-post failures now render inline in the sheet and normalize `Exception:` prefixes.
- Empty post/comment validation is handled in the form instead of leaking technical controller errors to the user.
- Remaining gap: backend-specific Supabase errors should continue to be checked in production QA to ensure no raw technical messages leak to users.

## Accessibility notes

- Material 3 controls provide baseline keyboard/focus semantics.
- Icon buttons include tooltips for actions such as notifications, logout, like and comment.
- Error states and auth error banners are semantic containers; shared error state now uses a live region.
- Empty states are semantic containers and constrained to a readable width on wide screens.
- Forms use labels and prefix icons.
- Recommended follow-up: run screen-reader and keyboard-only smoke checks in Chrome after final deployment, including tab order across auth forms, navigation rail/bar and bottom sheets.

## Visual consistency

- The app uses one Material 3 theme with a warm bright social-network direction.
- Cards, chips, icons and typography are consistent across Feed, Pets and Walks.
- Shared state components reduce mismatch across loading, empty and error screens.
- Current visual limitation: real pet/post imagery is not yet visible in the core UI; emoji placeholders are acceptable for MVP but Supabase Storage images would make the final demo stronger.

## Safe improvements applied

- Added contextual icons and optional actions to shared empty states.
- Added semantic loading label and live-region semantics to shared loading/error states.
- Constrained shared empty/error states to readable width for tablet and desktop layouts.
- Added refresh actions to Feed, Pets and Walks empty states.
- Improved create-post bottom sheet with inline validation, disabled submit and in-button progress.
- Improved comment bottom sheet with empty-state validation and readable desktop width.
- Improved pet and walk form sheets with centered desktop layout and disabled fields while saving.
- Improved walk join/leave action with disabled state and compact progress during async operations.
- Updated project documentation, development report and prompt journal.

## Remaining recommendations

| Priority | Recommendation | Reason |
|---|---|---|
| P0 | Re-run desktop and mobile browser QA after final Netlify redeploy. | Confirms no overflow, broken auth redirect or blank production startup. |
| P1 | Add visible search/filter UI for Feed or Walks. | Final project gap analysis marks search/filtering as planned; a small filter would improve demo clarity. |
| P1 | Re-check create pet/create walk forms in production browser QA. | Forms are implemented and polished locally; hosted Supabase validation should confirm final behavior. |
| P1 | Display Supabase Storage pet/post images. | Makes Storage visible as a user-facing feature, not only backend configuration. |
| P2 | Add screenshots for desktop and mobile final states. | Helps evaluator quickly verify responsive behavior. |
| P2 | Do keyboard-only and screen-reader smoke checks. | Strengthens accessibility evidence for final handoff. |

## Validation plan

After Flutter UI changes:

```bash
dart format .
flutter analyze
flutter test
```

Latest local validation for the final product polish pass:

```text
dart format .: passed, 88 files checked
flutter analyze: passed, No issues found
flutter test test/features/feed test/features/pets test/features/walks test/features/auth: passed, 80 tests
flutter test: passed, 98 tests
```

For final launch QA:

```bash
flutter run -d chrome
```

Recommended browser viewports:

- mobile: 390 x 844;
- tablet: 768 x 1024;
- desktop: 1440 x 900.
