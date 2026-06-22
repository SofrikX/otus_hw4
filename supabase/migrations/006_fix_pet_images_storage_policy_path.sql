-- Fix pet-images Storage policies so folder checks use the object path
-- (`storage.objects.name`) rather than the joined `public.pets.name` column.
-- Safe for production data: no data changes, no bucket deletion, no RLS
-- disabling, no secrets, and no service-role usage.

drop policy if exists "storage_insert_own_pet_images" on storage.objects;
drop policy if exists "storage_update_own_pet_images" on storage.objects;
drop policy if exists "storage_delete_own_pet_images" on storage.objects;

create policy "storage_insert_own_pet_images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'pet-images'
  and (storage.foldername(storage.objects.name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(storage.objects.name))[2]
      and pets.owner_id = auth.uid()
  )
);

create policy "storage_update_own_pet_images"
on storage.objects for update to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(storage.objects.name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(storage.objects.name))[2]
      and pets.owner_id = auth.uid()
  )
)
with check (
  bucket_id = 'pet-images'
  and (storage.foldername(storage.objects.name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(storage.objects.name))[2]
      and pets.owner_id = auth.uid()
  )
);

create policy "storage_delete_own_pet_images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'pet-images'
  and (storage.foldername(storage.objects.name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.pets
    where pets.id::text = (storage.foldername(storage.objects.name))[2]
      and pets.owner_id = auth.uid()
  )
);
