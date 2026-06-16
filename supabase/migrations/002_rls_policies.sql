-- PetConnect Row Level Security policies.
-- Safe for git: policies contain no project URLs, API keys, passwords, or user data.

create or replace function public.is_chat_participant(target_chat_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.chat_participants
    where chat_id = target_chat_id
      and user_id = auth.uid()
  );
$$;

alter table public.profiles enable row level security;
alter table public.pets enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.post_likes enable row level security;
alter table public.walks enable row level security;
alter table public.walk_participants enable row level security;
alter table public.chats enable row level security;
alter table public.chat_participants enable row level security;
alter table public.messages enable row level security;

drop policy if exists "profiles_read_authenticated" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;

create policy "profiles_read_authenticated"
on public.profiles for select to authenticated
using (true);

create policy "profiles_insert_own"
on public.profiles for insert to authenticated
with check (id = auth.uid());

create policy "profiles_update_own"
on public.profiles for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "pets_read_authenticated" on public.pets;
drop policy if exists "pets_insert_own" on public.pets;
drop policy if exists "pets_update_own" on public.pets;
drop policy if exists "pets_delete_own" on public.pets;

create policy "pets_read_authenticated"
on public.pets for select to authenticated
using (true);

create policy "pets_insert_own"
on public.pets for insert to authenticated
with check (owner_id = auth.uid());

create policy "pets_update_own"
on public.pets for update to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "pets_delete_own"
on public.pets for delete to authenticated
using (owner_id = auth.uid());

drop policy if exists "posts_read_authenticated" on public.posts;
drop policy if exists "posts_read_public_authenticated" on public.posts;
drop policy if exists "posts_insert_own" on public.posts;
drop policy if exists "posts_insert_own_pet" on public.posts;
drop policy if exists "posts_update_own" on public.posts;
drop policy if exists "posts_delete_own" on public.posts;

create policy "posts_read_authenticated"
on public.posts for select to authenticated
using (deleted_at is null);

create policy "posts_insert_own"
on public.posts for insert to authenticated
with check (author_id = auth.uid());

create policy "posts_update_own"
on public.posts for update to authenticated
using (author_id = auth.uid())
with check (author_id = auth.uid());

create policy "posts_delete_own"
on public.posts for delete to authenticated
using (author_id = auth.uid());

drop policy if exists "comments_read_authenticated" on public.comments;
drop policy if exists "comments_insert_own" on public.comments;
drop policy if exists "comments_update_own" on public.comments;
drop policy if exists "comments_delete_own" on public.comments;
drop policy if exists "comments_delete_author_or_post_owner" on public.comments;

create policy "comments_read_authenticated"
on public.comments for select to authenticated
using (deleted_at is null);

create policy "comments_insert_own"
on public.comments for insert to authenticated
with check (author_id = auth.uid());

create policy "comments_delete_own"
on public.comments for delete to authenticated
using (author_id = auth.uid());

drop policy if exists "post_likes_read_authenticated" on public.post_likes;
drop policy if exists "post_likes_insert_own" on public.post_likes;
drop policy if exists "post_likes_delete_own" on public.post_likes;

create policy "post_likes_read_authenticated"
on public.post_likes for select to authenticated
using (true);

create policy "post_likes_insert_own"
on public.post_likes for insert to authenticated
with check (user_id = auth.uid());

create policy "post_likes_delete_own"
on public.post_likes for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "walks_read_authenticated" on public.walks;
drop policy if exists "walks_read_active_authenticated" on public.walks;
drop policy if exists "walks_insert_own" on public.walks;
drop policy if exists "walks_update_own" on public.walks;
drop policy if exists "walks_delete_own" on public.walks;

create policy "walks_read_authenticated"
on public.walks for select to authenticated
using (true);

create policy "walks_insert_own"
on public.walks for insert to authenticated
with check (creator_id = auth.uid());

create policy "walks_update_own"
on public.walks for update to authenticated
using (creator_id = auth.uid())
with check (creator_id = auth.uid());

create policy "walks_delete_own"
on public.walks for delete to authenticated
using (creator_id = auth.uid());

drop policy if exists "walk_participants_read_authenticated" on public.walk_participants;
drop policy if exists "walk_participants_insert_self" on public.walk_participants;
drop policy if exists "walk_participants_insert_self_active_walk" on public.walk_participants;
drop policy if exists "walk_participants_delete_self" on public.walk_participants;

create policy "walk_participants_read_authenticated"
on public.walk_participants for select to authenticated
using (true);

create policy "walk_participants_insert_self"
on public.walk_participants for insert to authenticated
with check (user_id = auth.uid());

create policy "walk_participants_delete_self"
on public.walk_participants for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "chats_read_participant" on public.chats;
drop policy if exists "chats_insert_authenticated" on public.chats;
drop policy if exists "chats_update_participant" on public.chats;
drop policy if exists "chats_delete_participant" on public.chats;

create policy "chats_read_participant"
on public.chats for select to authenticated
using (public.is_chat_participant(id));

create policy "chats_update_participant"
on public.chats for update to authenticated
using (public.is_chat_participant(id))
with check (public.is_chat_participant(id));

drop policy if exists "chat_participants_read_own_chats" on public.chat_participants;
drop policy if exists "chat_participants_insert_self_or_existing_participant" on public.chat_participants;
drop policy if exists "chat_participants_update_self" on public.chat_participants;
drop policy if exists "chat_participants_delete_self" on public.chat_participants;

create policy "chat_participants_read_own_chats"
on public.chat_participants for select to authenticated
using (public.is_chat_participant(chat_id));

create policy "chat_participants_update_self"
on public.chat_participants for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "chat_participants_delete_self"
on public.chat_participants for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "messages_read_chat_participant" on public.messages;
drop policy if exists "messages_insert_chat_participant" on public.messages;
drop policy if exists "messages_update_sender" on public.messages;
drop policy if exists "messages_delete_sender" on public.messages;

create policy "messages_read_chat_participant"
on public.messages for select to authenticated
using (public.is_chat_participant(chat_id));

create policy "messages_insert_chat_participant"
on public.messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and public.is_chat_participant(chat_id)
);

create policy "messages_update_sender"
on public.messages for update to authenticated
using (
  sender_id = auth.uid()
  and public.is_chat_participant(chat_id)
)
with check (
  sender_id = auth.uid()
  and public.is_chat_participant(chat_id)
);

create policy "messages_delete_sender"
on public.messages for delete to authenticated
using (
  sender_id = auth.uid()
  and public.is_chat_participant(chat_id)
);
