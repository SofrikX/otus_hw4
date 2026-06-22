# PetConnect User Stories

Date: 22 June 2026

Purpose: final project user stories for PetConnect as a portfolio full-stack Flutter Web application built with AI-assisted requirements engineering.

Status values:

- **Done** - implemented in code, migrations, tests or documented production setup.
- **Planned** - part of the final product direction, but not fully exposed or validated in the current UI/backend.
- **Optional** - future enhancement outside the required final demo.

Priority values:

- **Must** - needed for the final demo and core project assessment.
- **Should** - important for portfolio completeness, but can be scoped if time is limited.
- **Could** - useful enhancement.

## Authentication

### AUTH-1. Email/password registration

**User story:** As a guest, I want to create an account with email and password so that I can access PetConnect as an authenticated user.

**Acceptance criteria:**

- Given the user opens the registration screen, when they enter a valid email, password and display name, then Supabase Auth creates an account and the app opens the protected area.
- Given the registration fails, when Supabase returns an auth error, then the app shows a short friendly error message.
- Given the account is created, then a profile row is created or updated for the authenticated user.

**Priority:** Must  
**Status:** Done

### AUTH-2. Email/password sign in

**User story:** As a registered user, I want to sign in with email and password so that I can use my profile, feed, pets and walks.

**Acceptance criteria:**

- Given the user enters valid credentials, when they submit the login form, then the app stores the Supabase session and redirects to the main screen.
- Given the user enters invalid credentials, then the app shows a friendly authentication error.
- Given the session exists after refresh, then the app restores the authenticated state.

**Priority:** Must  
**Status:** Done

### AUTH-3. Google OAuth sign in

**User story:** As a user, I want to sign in with Google so that I can access PetConnect without creating a separate password.

**Acceptance criteria:**

- Given Google provider is configured in Supabase Dashboard, when the user clicks Google sign in, then the browser opens the Supabase OAuth flow.
- Given OAuth succeeds, then the app returns to the configured Netlify or localhost redirect URL and restores the session.
- Google Client Secret is stored only in Supabase/Google consoles and is not committed to the repository.

**Priority:** Should  
**Status:** Done

### AUTH-4. Sign out

**User story:** As an authenticated user, I want to sign out so that other people cannot use my session on the same device.

**Acceptance criteria:**

- Given the user is authenticated, when they sign out, then Supabase clears the session.
- Given sign out succeeds, then protected routes redirect to the login screen.

**Priority:** Must  
**Status:** Done

## Pet Profiles

### PET-1. View pet profiles

**User story:** As a pet owner, I want to view pet profiles so that I can learn about pets in the community.

**Acceptance criteria:**

- Given the user opens the pets screen, then the app shows a list of pets from the active repository.
- Given the user selects a pet, then the app opens the pet profile screen.
- Given the pet id is unknown, then the app shows a friendly error state.

**Priority:** Must  
**Status:** Done

### PET-2. Create pet profile

**User story:** As a pet owner, I want to create a profile for my pet so that I can use the pet in posts and community interactions.

**Acceptance criteria:**

- Given the user is authenticated, when they submit a valid pet name, animal type, age, breed and description, then the backend creates a `pets` row owned by the current user.
- Given required data is missing or invalid, then the operation is rejected by UI validation or PostgreSQL constraints.
- Given another user tries to write a pet for a different owner id, then RLS blocks the request.

**Priority:** Must  
**Status:** Planned

### PET-3. Edit or delete own pet profile

**User story:** As a pet owner, I want to edit or delete my own pet profile so that outdated information can be corrected or removed.

**Acceptance criteria:**

- Given the user owns the pet, when they update allowed fields, then the backend accepts the change.
- Given the user does not own the pet, then RLS blocks update and delete operations.
- Given the pet is deleted, then dependent data is handled according to database constraints.

**Priority:** Should  
**Status:** Planned

## Feed And Posts

### FEED-1. View social feed

**User story:** As an authenticated user, I want to view recent pet posts so that I can follow community activity.

**Acceptance criteria:**

- Given the user opens the feed, then the app loads recent non-deleted posts ordered by creation date.
- Given there are no posts, then the app shows an empty state.
- Given loading or backend failure occurs, then the app shows loading and friendly error states.

**Priority:** Must  
**Status:** Done

### FEED-2. Create text post for a pet

**User story:** As a pet owner, I want to create a post for a pet so that I can share updates with the community.

**Acceptance criteria:**

- Given the user is authenticated and has a reference pet, when they submit non-empty text, then the app creates a `posts` row through the repository layer.
- Given the text is empty, then the controller rejects the operation.
- Given the backend request fails, then analytics records a safe backend error event and the UI can show an error state.

**Priority:** Must  
**Status:** Done

### FEED-3. Edit or delete own post

**User story:** As a post author, I want to edit or delete my own post so that I can manage content I created.

**Acceptance criteria:**

- Given the user owns the post, then RLS allows update/delete operations.
- Given the user does not own the post, then RLS blocks update/delete operations.
- UI actions for edit/delete are visible only where they are supported by the application layer.

**Priority:** Should  
**Status:** Planned

## Comments And Likes

### INT-1. Like and unlike post

**User story:** As an authenticated user, I want to like and unlike posts so that I can react to pet updates.

**Acceptance criteria:**

- Given the user taps like on a post they have not liked, then the app inserts a `post_likes` row and updates the like count.
- Given the user taps like again, then the app deletes their own like row and updates the like count.
- Given the same user tries to create a duplicate like, then database uniqueness prevents duplication.

**Priority:** Must  
**Status:** Done

### INT-2. Add comment to post

**User story:** As an authenticated user, I want to comment on posts so that I can participate in conversations.

**Acceptance criteria:**

- Given the user submits non-empty comment text, then the app creates a `comments` row and updates the comment count.
- Given the comment is empty, then the controller rejects the operation.
- Given the post is deleted or unavailable, then RLS or repository mapping prevents adding the comment.

**Priority:** Must  
**Status:** Done

### INT-3. Delete own comment

**User story:** As a comment author, I want to delete my own comment so that I can remove a message I no longer want visible.

**Acceptance criteria:**

- Given the user owns the comment, then RLS allows delete.
- Given the user does not own the comment, then RLS blocks delete.
- The UI should expose delete only after the application layer supports the operation.

**Priority:** Should  
**Status:** Planned

## Walks

### WALK-1. View active walks

**User story:** As a pet owner, I want to view active walks so that I can find pet activities.

**Acceptance criteria:**

- Given the user opens the walks screen, then the app loads active walks ordered by scheduled time.
- Given a walk is joined by the current user, then the app shows joined state.
- Given no walks exist, then the app shows an empty state.

**Priority:** Must  
**Status:** Done

### WALK-2. Join walk

**User story:** As a pet owner, I want to join a walk so that I can participate in a local activity.

**Acceptance criteria:**

- Given the user taps join on an active walk, then the app creates a `walk_participants` row for the current user.
- Given the user already joined, then the app reports an already joined status rather than creating a duplicate row.
- Given the walk is cancelled or unavailable, then the backend blocks the join.

**Priority:** Must  
**Status:** Done

### WALK-3. Leave walk

**User story:** As a walk participant, I want to leave a walk so that the participant count stays accurate.

**Acceptance criteria:**

- Given the user joined a walk, when they leave, then their own `walk_participants` row is deleted.
- Given another user tries to delete a participant row they do not own, then RLS blocks the operation.

**Priority:** Should  
**Status:** Planned

### WALK-4. Create walk

**User story:** As a pet owner, I want to create a walk so that other users can join my activity.

**Acceptance criteria:**

- Given the user submits a title, place, date/time and description, then the backend creates a `walks` row owned by the current user.
- Given required fields are invalid, then UI validation or PostgreSQL constraints reject the operation.
- Given the creator owns the walk, then RLS allows future update/delete operations.

**Priority:** Should  
**Status:** Planned

## Search And Filters

### SEARCH-1. Filter feed posts

**User story:** As a user, I want to filter feed posts so that I can find relevant pet updates faster.

**Acceptance criteria:**

- Given the user enters a search query or selects a filter, then the feed displays only matching posts.
- Given the query returns no results, then the app shows an empty state.
- Filtering must not bypass RLS or expose private/deleted content.

**Priority:** Should  
**Status:** Planned

### SEARCH-2. Filter walks

**User story:** As a pet owner, I want to filter walks by place, date or status so that I can find a suitable walk.

**Acceptance criteria:**

- Given the user selects active walks or searches by place, then the walks screen shows matching walks.
- Given no matching walks exist, then the app shows an empty state.
- Filters use repository queries or local state without direct backend calls from widgets.

**Priority:** Should  
**Status:** Planned

## Image Upload

### IMG-1. Upload pet photo

**User story:** As a pet owner, I want to upload a pet photo so that my pet profile feels personal and recognizable.

**Acceptance criteria:**

- Given the pet owner selects a JPG, JPEG, PNG or WebP image up to 5 MB, then the file is uploaded to `pet-images/<auth.uid()>/<pet-id>/...`.
- Given upload succeeds, then `public.pets.photo_url` is updated and the pets list/profile show the uploaded image.
- Given the file is too large or not an allowed image type, then the upload is rejected with a friendly message.
- Given another user tries to upload, update or delete an image for a pet they do not own, then Storage policies and `pets` RLS block the request.

**Priority:** Should  
**Status:** Done

### IMG-2. Upload post image

**User story:** As a pet owner, I want to attach an image to a post so that the feed shows real pet moments.

**Acceptance criteria:**

- Given the user attaches an image, then the app uploads it to `post-images` and stores the public or signed URL reference in `posts.image_urls`.
- Given upload fails, then the post is not marked as successfully published with a missing image.
- The app does not store secrets or service role keys for upload.

**Priority:** Should  
**Status:** Planned

## Analytics

### AN-1. Track product events without personal data

**User story:** As a product owner, I want to track key usage events so that I can understand how the demo is used without collecting personal data.

**Acceptance criteria:**

- Given analytics is enabled, then the app sends safe events such as app open, sign-in success, post created, post liked, comment added and walk joined.
- Events do not include email, raw user id, tokens, post text, comment text or private profile data.
- Given analytics is disabled, then events are ignored or logged only in safe debug mode.

**Priority:** Should  
**Status:** Done

## Monitoring

### MON-1. Health check endpoint

**User story:** As a maintainer, I want a health check endpoint so that I can verify that the Netlify frontend integration and Supabase endpoints are reachable.

**Acceptance criteria:**

- Given the `/api/health` endpoint is called, then it returns JSON status for the app function and Supabase checks.
- The endpoint does not expose environment variable values or secrets.
- Optional database checks treat RLS/API blocks as safe skipped checks where documented.

**Priority:** Should  
**Status:** Done

### MON-2. Structured logging

**User story:** As a maintainer, I want structured logs so that production issues can be diagnosed safely.

**Acceptance criteria:**

- Logs include safe event names, operation names, status codes, error types and durations.
- Logs exclude tokens, passwords, service role keys, authorization headers, email addresses and message text.
- AI debugging prompts use sanitized logs only.

**Priority:** Should  
**Status:** Done

## Admin/Maintenance

### ADM-1. Apply database migrations and seed demo data

**User story:** As a maintainer, I want versioned database migrations and demo seed data so that the backend can be reproduced for review.

**Acceptance criteria:**

- PostgreSQL schema, RLS policies and API grants live in `supabase/migrations/`.
- Demo seed data lives in `supabase/seed.sql` and does not contain production user data or secrets.
- Supabase validation is performed with `supabase db lint`, `supabase db reset` or hosted smoke checks before final submission.

**Priority:** Must  
**Status:** Done

### ADM-2. CI/CD validation and deployment

**User story:** As a maintainer, I want CI/CD checks and deployment automation so that the final project can be validated consistently.

**Acceptance criteria:**

- GitHub Actions runs format, analyze, tests, security checks and Flutter Web build.
- Production deploy to Netlify uses repository or Netlify environment variables rather than committed secrets.
- Failed security or test checks block deployment.

**Priority:** Must  
**Status:** Done

### ADM-3. Admin moderation tools

**User story:** As a future moderator, I want admin tools to review abusive content so that the community can remain safe.

**Acceptance criteria:**

- Admin roles are defined separately from regular users.
- Moderation actions are audited and protected by RLS or server-side checks.
- This is not required for the current final demo unless explicitly added.

**Priority:** Could  
**Status:** Optional
