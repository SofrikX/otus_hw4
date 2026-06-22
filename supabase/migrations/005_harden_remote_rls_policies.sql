-- Harden policies that were strengthened locally after the original 002
-- migration had already been applied to the hosted Supabase project.
-- Safe for production data: no table drops, data deletes, RLS disabling,
-- secrets, service-role usage, or seed/demo writes.

drop policy if exists "posts_read_authenticated" on public.posts;
drop policy if exists "posts_insert_own" on public.posts;
drop policy if exists "posts_update_own" on public.posts;

create policy "posts_read_authenticated"
on public.posts for select to authenticated
using (
  deleted_at is null
  and (
    visibility = 'public'
    or author_id = auth.uid()
  )
);

create policy "posts_insert_own"
on public.posts for insert to authenticated
with check (
  author_id = auth.uid()
  and exists (
    select 1
    from public.pets
    where pets.id = posts.pet_id
      and pets.owner_id = auth.uid()
  )
);

create policy "posts_update_own"
on public.posts for update to authenticated
using (author_id = auth.uid())
with check (
  author_id = auth.uid()
  and exists (
    select 1
    from public.pets
    where pets.id = posts.pet_id
      and pets.owner_id = auth.uid()
  )
);

drop policy if exists "comments_read_authenticated" on public.comments;
drop policy if exists "comments_insert_own" on public.comments;

create policy "comments_read_authenticated"
on public.comments for select to authenticated
using (
  deleted_at is null
  and exists (
    select 1
    from public.posts
    where posts.id = comments.post_id
      and posts.deleted_at is null
      and (
        posts.visibility = 'public'
        or posts.author_id = auth.uid()
      )
  )
);

create policy "comments_insert_own"
on public.comments for insert to authenticated
with check (
  author_id = auth.uid()
  and exists (
    select 1
    from public.posts
    where posts.id = comments.post_id
      and posts.deleted_at is null
      and (
        posts.visibility = 'public'
        or posts.author_id = auth.uid()
      )
  )
);

drop policy if exists "post_likes_read_authenticated" on public.post_likes;
drop policy if exists "post_likes_insert_own" on public.post_likes;

create policy "post_likes_read_authenticated"
on public.post_likes for select to authenticated
using (
  exists (
    select 1
    from public.posts
    where posts.id = post_likes.post_id
      and posts.deleted_at is null
      and (
        posts.visibility = 'public'
        or posts.author_id = auth.uid()
      )
  )
);

create policy "post_likes_insert_own"
on public.post_likes for insert to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.posts
    where posts.id = post_likes.post_id
      and posts.deleted_at is null
      and (
        posts.visibility = 'public'
        or posts.author_id = auth.uid()
      )
  )
);

drop policy if exists "walk_participants_insert_self" on public.walk_participants;

create policy "walk_participants_insert_self"
on public.walk_participants for insert to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.walks
    where walks.id = walk_participants.walk_id
      and walks.status = 'active'
  )
);
