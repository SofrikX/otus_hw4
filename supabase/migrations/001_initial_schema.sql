-- PetConnect Supabase initial schema.
-- Safe for git: no project URLs, API keys, passwords, service role keys, or user data.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  email text,
  avatar_url text,
  bio text check (bio is null or char_length(bio) <= 500),
  city text check (city is null or char_length(city) <= 120),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  owner_name text,
  name text not null check (char_length(name) between 1 and 50),
  animal_type text not null check (animal_type in ('dog', 'cat', 'other')),
  breed text check (breed is null or char_length(breed) <= 80),
  age int check (age is null or age between 0 and 30),
  description text check (description is null or char_length(description) <= 500),
  photo_url text,
  photo_emoji text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  author_name text,
  pet_id uuid not null references public.pets(id) on delete restrict,
  pet_name text,
  pet_photo_url text,
  pet_emoji text,
  text text check (text is null or char_length(text) <= 1000),
  image_urls text[] not null default '{}',
  image_emoji text,
  likes_count int not null default 0 check (likes_count >= 0),
  comments_count int not null default 0 check (comments_count >= 0),
  visibility text not null default 'public' check (visibility in ('public', 'private')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  author_name text,
  author_avatar_url text,
  text text not null check (char_length(text) between 1 and 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

create table if not exists public.walks (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  organizer_name text,
  title text not null check (char_length(title) between 1 and 120),
  place text not null check (char_length(place) between 1 and 160),
  latitude double precision,
  longitude double precision,
  scheduled_at timestamptz not null,
  description text check (description is null or char_length(description) <= 500),
  participants_count int not null default 0 check (participants_count >= 0),
  status text not null default 'active' check (status in ('active', 'cancelled', 'completed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.walk_participants (
  id uuid primary key default gen_random_uuid(),
  walk_id uuid not null references public.walks(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (walk_id, user_id)
);

create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  last_message_text text,
  last_message_sender_id uuid references public.profiles(id) on delete set null,
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chat_participants (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  companion_name text,
  pet_name text,
  unread_count int not null default 0 check (unread_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (chat_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  sender_name text,
  text text not null check (char_length(text) between 1 and 1000),
  status text not null default 'sent' check (status in ('sending', 'sent', 'failed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_created_at_desc_idx on public.profiles (created_at desc);
create index if not exists pets_owner_id_idx on public.pets (owner_id);
create index if not exists pets_owner_created_at_desc_idx on public.pets (owner_id, created_at desc);
create index if not exists posts_created_at_desc_idx on public.posts (created_at desc);
create index if not exists posts_feed_idx on public.posts (visibility, created_at desc) where deleted_at is null;
create index if not exists posts_pet_created_at_desc_idx on public.posts (pet_id, created_at desc);
create index if not exists posts_author_created_at_desc_idx on public.posts (author_id, created_at desc);
create index if not exists comments_post_id_idx on public.comments (post_id);
create index if not exists comments_post_created_at_idx on public.comments (post_id, created_at asc) where deleted_at is null;
create index if not exists post_likes_user_id_idx on public.post_likes (user_id);
create index if not exists walks_scheduled_at_idx on public.walks (scheduled_at);
create index if not exists walks_status_scheduled_at_idx on public.walks (status, scheduled_at asc);
create index if not exists walk_participants_user_id_idx on public.walk_participants (user_id);
create index if not exists messages_chat_id_created_at_idx on public.messages (chat_id, created_at);
create index if not exists chat_participants_user_id_idx on public.chat_participants (user_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.recount_post_likes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.posts
  set likes_count = (
    select count(*)::int
    from public.post_likes
    where post_id = coalesce(new.post_id, old.post_id)
  )
  where id = coalesce(new.post_id, old.post_id);

  return null;
end;
$$;

create or replace function public.recount_comments()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.posts
  set comments_count = (
    select count(*)::int
    from public.comments
    where post_id = coalesce(new.post_id, old.post_id)
      and deleted_at is null
  )
  where id = coalesce(new.post_id, old.post_id);

  return null;
end;
$$;

create or replace function public.recount_walk_participants()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.walks
  set participants_count = (
    select count(*)::int
    from public.walk_participants
    where walk_id = coalesce(new.walk_id, old.walk_id)
  )
  where id = coalesce(new.walk_id, old.walk_id);

  return null;
end;
$$;

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

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists pets_set_updated_at on public.pets;
create trigger pets_set_updated_at
before update on public.pets
for each row execute function public.set_updated_at();

drop trigger if exists posts_set_updated_at on public.posts;
create trigger posts_set_updated_at
before update on public.posts
for each row execute function public.set_updated_at();

drop trigger if exists comments_set_updated_at on public.comments;
create trigger comments_set_updated_at
before update on public.comments
for each row execute function public.set_updated_at();

drop trigger if exists walks_set_updated_at on public.walks;
create trigger walks_set_updated_at
before update on public.walks
for each row execute function public.set_updated_at();

drop trigger if exists chats_set_updated_at on public.chats;
create trigger chats_set_updated_at
before update on public.chats
for each row execute function public.set_updated_at();

drop trigger if exists chat_participants_set_updated_at on public.chat_participants;
create trigger chat_participants_set_updated_at
before update on public.chat_participants
for each row execute function public.set_updated_at();

drop trigger if exists messages_set_updated_at on public.messages;
create trigger messages_set_updated_at
before update on public.messages
for each row execute function public.set_updated_at();

drop trigger if exists post_likes_recount_after_insert on public.post_likes;
create trigger post_likes_recount_after_insert
after insert on public.post_likes
for each row execute function public.recount_post_likes();

drop trigger if exists post_likes_recount_after_delete on public.post_likes;
create trigger post_likes_recount_after_delete
after delete on public.post_likes
for each row execute function public.recount_post_likes();

drop trigger if exists comments_recount_after_insert on public.comments;
create trigger comments_recount_after_insert
after insert on public.comments
for each row execute function public.recount_comments();

drop trigger if exists comments_recount_after_update on public.comments;
create trigger comments_recount_after_update
after update of deleted_at on public.comments
for each row execute function public.recount_comments();

drop trigger if exists walk_participants_recount_after_insert on public.walk_participants;
create trigger walk_participants_recount_after_insert
after insert on public.walk_participants
for each row execute function public.recount_walk_participants();

drop trigger if exists walk_participants_recount_after_delete on public.walk_participants;
create trigger walk_participants_recount_after_delete
after delete on public.walk_participants
for each row execute function public.recount_walk_participants();

insert into storage.buckets (id, name, public)
values
  ('avatars', 'avatars', false),
  ('pet-photos', 'pet-photos', false),
  ('post-images', 'post-images', false)
on conflict (id) do nothing;

create policy "storage_read_authenticated_petconnect_images"
on storage.objects for select to authenticated
using (bucket_id in ('avatars', 'pet-photos', 'post-images'));

create policy "storage_insert_own_petconnect_images"
on storage.objects for insert to authenticated
with check (
  bucket_id in ('avatars', 'pet-photos', 'post-images')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "storage_update_own_petconnect_images"
on storage.objects for update to authenticated
using (
  bucket_id in ('avatars', 'pet-photos', 'post-images')
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id in ('avatars', 'pet-photos', 'post-images')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "storage_delete_own_petconnect_images"
on storage.objects for delete to authenticated
using (
  bucket_id in ('avatars', 'pet-photos', 'post-images')
  and (storage.foldername(name))[1] = auth.uid()::text
);
