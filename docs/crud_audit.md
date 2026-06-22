# PetConnect CRUD Audit

Date: 22 June 2026

Scope: Supabase auto REST API operations used through Flutter repositories and Riverpod/application controllers. This audit checks user-visible CRUD for `pets`, `posts`, `comments`, `walks`, `walk_participants` and `profiles`.

## Summary

The final required CRUD scenarios are now covered for the main demo entities:

- users can create, read, update and delete their own pet profiles;
- users can create and delete their own posts;
- users can create walks;
- users can join and leave walks;
- Flutter UI exposes minimal forms, owner-only actions, delete confirmations and friendly validation errors;
- Supabase RLS remains enabled and limits writes/deletes to the current authenticated user.

No new SQL migration was required for this pass because the existing RLS policies already cover owner-scoped inserts, updates and deletes. The remaining partial areas are intentionally scoped outside the final minimum: editing posts, editing/deleting comments from the UI, deleting walks from the UI and editing profiles.

## Pets

| CRUD | UI screen/action | Repository/service method | RLS policy | Status |
|---|---|---|---|---|
| Create | `PetsScreen` -> `Питомец` button -> pet form | `PetActions.createPet` -> `PetRepository.createPet` -> `SupabasePetRepository.createPet` | `pets_insert_own` with `owner_id = auth.uid()` | Done |
| Read | `PetsScreen` list, `PetProfileScreen` card/details | `petsProvider`, `petByIdProvider`, `fetchPets`, `getPetById`, `getPetsByOwner` | `pets_read_authenticated` | Done |
| Update | Owner-only card menu -> `Редактировать` -> pet form | `PetActions.updatePet` -> `PetRepository.updatePet` -> `SupabasePetRepository.updatePet` | `pets_update_own` using/checking `owner_id = auth.uid()` | Done |
| Delete | Owner-only card menu -> `Удалить` -> confirmation dialog | `PetActions.deletePet` -> `PetRepository.deletePet` -> `SupabasePetRepository.deletePet` | `pets_delete_own` using `owner_id = auth.uid()` | Done |

Validation:

- name is required and limited to 50 characters;
- animal type must be `dog`, `cat` or `other`;
- breed is limited to 80 characters;
- age must be 0-30;
- description is required and limited to 500 characters.

## Posts

| CRUD | UI screen/action | Repository/service method | RLS policy | Status |
|---|---|---|---|---|
| Create | Home floating action -> create-post bottom sheet | `FeedController.createPost` -> `FeedRepository.createPost` -> `SupabaseFeedRepository.createPost` | `posts_insert_own`; also checks referenced pet belongs to `auth.uid()` | Done |
| Read | `FeedScreen` feed/search result cards | `FeedController.refresh` -> `fetchPosts` | `posts_read_authenticated` for non-deleted public posts and own private posts | Done |
| Update | Not exposed in final UI | Repository method not added | `posts_update_own` exists and checks author plus owned pet | Partial |
| Delete | Owner-only post menu -> `Удалить` -> confirmation dialog | `FeedController.deletePost` -> `FeedRepository.deletePost` -> `SupabaseFeedRepository.deletePost` | `posts_delete_own` using `author_id = auth.uid()` | Done |

Validation:

- create-post text is trimmed and must be non-empty;
- PostgreSQL limits `posts.text` to 1000 characters;
- post deletion is exposed only when `PetPost.authorId` matches current user; RLS is the backend enforcement layer.

## Comments

| CRUD | UI screen/action | Repository/service method | RLS policy | Status |
|---|---|---|---|---|
| Create | `PostCard` comment button -> comment sheet | `FeedController.addComment` -> `FeedRepository.addComment` -> `SupabaseFeedRepository.addComment` | `comments_insert_own`; target post must be visible | Done |
| Read | Recent comments rendered inside feed cards | `SupabaseFeedRepository._fetchCommentsByPostId` | `comments_read_authenticated` for visible non-deleted comments | Done |
| Update | Not required for final demo | Not implemented | No update policy in current RLS file | Missing |
| Delete | Not exposed in final UI | Not implemented in Flutter repository | `comments_delete_own` exists | Partial |

Validation:

- comment text is trimmed and must be non-empty in `FeedController.addComment`;
- PostgreSQL limits comments to 1-500 characters.

## Walks

| CRUD | UI screen/action | Repository/service method | RLS policy | Status |
|---|---|---|---|---|
| Create | `WalksScreen` -> `Прогулка` button -> walk form | `WalksController.createWalk` -> `WalksRepository.createWalk` -> `SupabaseWalkRepository.createWalk` | `walks_insert_own` with `creator_id = auth.uid()` | Done |
| Read | `WalksScreen` list and filters | `WalksController.refresh` -> `fetchWalks` | `walks_read_authenticated` | Done |
| Update | Not exposed in final UI | Not implemented in Flutter repository | `walks_update_own` exists | Partial |
| Delete | Not exposed in final UI | Not implemented in Flutter repository | `walks_delete_own` exists | Partial |

Validation:

- title is required and limited to 120 characters;
- place is required and limited to 160 characters;
- start date/time must be at least 15 minutes in the future and not more than one year ahead;
- description is required and limited to 500 characters;
- PostgreSQL enforces `status in ('active', 'cancelled', 'completed')`.

## Walk Participants

| CRUD | UI screen/action | Repository/service method | RLS policy | Status |
|---|---|---|---|---|
| Create | `WalkCard` -> `Присоединиться` | `WalksController.joinWalk` -> `WalksRepository.joinWalk` -> insert into `walk_participants` | `walk_participants_insert_self`; walk must be active | Done |
| Read | `WalksScreen` joined state and participant count | `fetchWalks` plus joined-id lookup from `walk_participants` | `walk_participants_read_authenticated` | Done |
| Update | Not applicable for join table in MVP | Not applicable | Not applicable | Done |
| Delete | Joined `WalkCard` -> `Выйти` | `WalksController.leaveWalk` -> `WalksRepository.leaveWalk` -> delete own row | `walk_participants_delete_self` using `user_id = auth.uid()` | Done |

Validation:

- duplicate joins are blocked by unique `(walk_id, user_id)`;
- repository maps duplicate join to an already-joined result;
- RLS blocks joining cancelled/completed walks through direct API insert.

## Profiles

| CRUD | UI screen/action | Repository/service method | RLS policy | Status |
|---|---|---|---|---|
| Create | Registration/sign-in profile sync | `SupabaseAuthRepository` profile upsert after auth | `profiles_insert_own` with `id = auth.uid()` | Done |
| Read | Author/owner names shown through related feed/pet/walk rows | Supabase repositories read denormalized display names; direct profile read allowed for authenticated users | `profiles_read_authenticated` | Partial |
| Update | No dedicated profile edit screen in final demo | Auth repository profile sync only | `profiles_update_own` | Partial |
| Delete | Account/profile deletion not in final demo | Not implemented | Auth user cascade would remove profile | Missing |

Profiles are not part of the final required minimum because the current UI does not expose profile editing.

## RLS Validation Notes

Existing policies reviewed in `supabase/migrations/002_rls_policies.sql`:

- `pets_insert_own`, `pets_update_own`, `pets_delete_own`;
- `posts_insert_own`, `posts_update_own`, `posts_delete_own`;
- `comments_insert_own`, `comments_delete_own`;
- `walks_insert_own`, `walks_update_own`, `walks_delete_own`;
- `walk_participants_insert_self`, `walk_participants_delete_self`;
- `profiles_insert_own`, `profiles_update_own`.

The Flutter UI now hides owner-only actions for foreign rows when ownership is known, but the security boundary is still PostgreSQL RLS. Direct API calls from another user remain blocked by the policies above.

## Validation Commands

Frontend validation:

```bash
dart format .
flutter analyze
flutter test test/features/feed test/features/pets test/features/walks
```

Supabase validation plan:

```bash
supabase db lint
supabase db reset
```

Attempted `supabase db lint` during this pass, but local Postgres on `127.0.0.1:54322` was not running, so the command could not connect. Run Supabase validation when local Supabase services are available or repeat hosted authenticated smoke checks against the deployed project.
