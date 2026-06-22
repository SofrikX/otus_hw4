-- PetConnect pet photo Storage support.
-- Safe for git: no project URLs, API keys, passwords, service role keys, or user data.

alter table public.pets
add column if not exists photo_url text;

insert into storage.buckets (id, name, public)
values ('pet-images', 'pet-images', true)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "storage_read_public_pet_images" on storage.objects;
drop policy if exists "storage_insert_own_pet_images" on storage.objects;
drop policy if exists "storage_update_own_pet_images" on storage.objects;
drop policy if exists "storage_delete_own_pet_images" on storage.objects;

create policy "storage_read_public_pet_images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'pet-images');

create policy "storage_insert_own_pet_images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(name))[2]
      and pets.owner_id = auth.uid()
  )
);

create policy "storage_update_own_pet_images"
on storage.objects for update to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(name))[2]
      and pets.owner_id = auth.uid()
  )
)
with check (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(name))[2]
      and pets.owner_id = auth.uid()
  )
);

create policy "storage_delete_own_pet_images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(name))[2]
      and pets.owner_id = auth.uid()
  )
);
