-- PetConnect PostgREST grants for Supabase client access.
-- RLS policies in 002_rls_policies.sql still decide row-level access.

grant usage on schema public to authenticated;

grant select, insert, update, delete
on table
  public.profiles,
  public.pets,
  public.posts,
  public.comments,
  public.post_likes,
  public.walks,
  public.walk_participants,
  public.chats,
  public.chat_participants,
  public.messages
to authenticated;

grant execute on function public.is_chat_participant(uuid) to authenticated;
