-- PetConnect Supabase seed data.
--
-- Safety notes:
-- - No real personal data, production emails, API keys, tokens, passwords, or
--   service role secrets are stored here.
-- - public.profiles.id references auth.users(id), so this file creates two
--   minimal demo Auth users for local Supabase validation.
-- - For a hosted Supabase project, the safer flow is to create demo users
--   through Supabase Auth UI or through the application sign-up flow first, then
--   replace DEMO_USER_A_ID and DEMO_USER_B_ID below with those real auth.users
--   UUIDs. The auth.users inserts below use on conflict do nothing and must not
--   be used to create real people or production users.
--
-- Demo Auth IDs to replace in hosted projects:
-- DEMO_USER_A_ID = 11111111-1111-1111-1111-111111111111
-- DEMO_USER_B_ID = 22222222-2222-2222-2222-222222222222

begin;

-- Remove only rows owned by this demo seed. Re-running the file is safe for the
-- fixed demo UUIDs and keeps counters deterministic.
delete from public.messages
where id in (
  '93000000-0000-0000-0000-000000000001',
  '93000000-0000-0000-0000-000000000002',
  '93000000-0000-0000-0000-000000000003'
);

delete from public.chat_participants
where id in (
  '92000000-0000-0000-0000-000000000001',
  '92000000-0000-0000-0000-000000000002'
);

delete from public.chats
where id = '91000000-0000-0000-0000-000000000001';

delete from public.walk_participants
where id in (
  '81000000-0000-0000-0000-000000000001',
  '81000000-0000-0000-0000-000000000002',
  '81000000-0000-0000-0000-000000000003',
  '81000000-0000-0000-0000-000000000004'
);

delete from public.walks
where id in (
  '71000000-0000-0000-0000-000000000001',
  '71000000-0000-0000-0000-000000000002',
  '71000000-0000-0000-0000-000000000003'
);

delete from public.post_likes
where id in (
  '61000000-0000-0000-0000-000000000001',
  '61000000-0000-0000-0000-000000000002',
  '61000000-0000-0000-0000-000000000003',
  '61000000-0000-0000-0000-000000000004'
);

delete from public.comments
where id in (
  '51000000-0000-0000-0000-000000000001',
  '51000000-0000-0000-0000-000000000002',
  '51000000-0000-0000-0000-000000000003',
  '51000000-0000-0000-0000-000000000004',
  '51000000-0000-0000-0000-000000000005'
);

delete from public.posts
where id in (
  '41000000-0000-0000-0000-000000000001',
  '41000000-0000-0000-0000-000000000002',
  '41000000-0000-0000-0000-000000000003',
  '41000000-0000-0000-0000-000000000004'
);

delete from public.pets
where id in (
  '31000000-0000-0000-0000-000000000001',
  '31000000-0000-0000-0000-000000000002',
  '31000000-0000-0000-0000-000000000003'
);

delete from public.profiles
where id in (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222'
);

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) values
  (
    '11111111-1111-1111-1111-111111111111',
    'authenticated',
    'authenticated',
    'demo.alina@example.test',
    crypt('DemoPass123!', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"display_name": "Demo Alina"}'::jsonb,
    now() - interval '14 days',
    now() - interval '14 days'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'authenticated',
    'authenticated',
    'demo.mark@example.test',
    crypt('DemoPass123!', gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"display_name": "Demo Mark"}'::jsonb,
    now() - interval '12 days',
    now() - interval '12 days'
  )
on conflict (id) do nothing;

insert into public.profiles (
  id,
  display_name,
  email,
  avatar_url,
  bio,
  city,
  created_at,
  updated_at
) values
  (
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    'demo.alina@example.test',
    null,
    'Loves calm morning walks and training games.',
    'Demo City',
    now() - interval '14 days',
    now() - interval '14 days'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    'demo.mark@example.test',
    null,
    'Keeps notes about friendly pet places.',
    'Demo City',
    now() - interval '12 days',
    now() - interval '12 days'
  );

insert into public.pets (
  id,
  owner_id,
  owner_name,
  name,
  animal_type,
  breed,
  age,
  description,
  photo_url,
  photo_emoji,
  created_at,
  updated_at
) values
  (
    '31000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    'Bruno',
    'dog',
    'Corgi mix',
    3,
    'Friendly dog who enjoys fetch and short routes.',
    null,
    'dog',
    now() - interval '13 days',
    now() - interval '13 days'
  ),
  (
    '31000000-0000-0000-0000-000000000002',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    'Mia',
    'cat',
    'Domestic shorthair',
    2,
    'Curious cat who likes sunny windows.',
    null,
    'cat',
    now() - interval '11 days',
    now() - interval '11 days'
  ),
  (
    '31000000-0000-0000-0000-000000000003',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    'Rocky',
    'dog',
    'Beagle',
    5,
    'Active dog ready for weekend park walks.',
    null,
    'dog',
    now() - interval '10 days',
    now() - interval '10 days'
  );

insert into public.posts (
  id,
  author_id,
  author_name,
  pet_id,
  pet_name,
  pet_photo_url,
  pet_emoji,
  text,
  image_urls,
  image_emoji,
  visibility,
  created_at,
  updated_at
) values
  (
    '41000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    '31000000-0000-0000-0000-000000000001',
    'Bruno',
    null,
    'dog',
    'Bruno tested a new walking route today and approved every bench on the way.',
    '{}',
    'park',
    'public',
    now() - interval '4 days',
    now() - interval '4 days'
  ),
  (
    '41000000-0000-0000-0000-000000000002',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    '31000000-0000-0000-0000-000000000003',
    'Rocky',
    null,
    'dog',
    'Rocky met two new friends near the fountain. Social walk success.',
    '{}',
    'friends',
    'public',
    now() - interval '3 days',
    now() - interval '3 days'
  ),
  (
    '41000000-0000-0000-0000-000000000003',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    '31000000-0000-0000-0000-000000000002',
    'Mia',
    null,
    'cat',
    'Mia found the quietest spot at home and now treats it as official territory.',
    '{}',
    'home',
    'public',
    now() - interval '2 days',
    now() - interval '2 days'
  ),
  (
    '41000000-0000-0000-0000-000000000004',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    '31000000-0000-0000-0000-000000000003',
    'Rocky',
    null,
    'dog',
    'Planning a weekend route with water stops and shaded paths.',
    '{}',
    'route',
    'public',
    now() - interval '18 hours',
    now() - interval '18 hours'
  );

insert into public.comments (
  id,
  post_id,
  author_id,
  author_name,
  author_avatar_url,
  text,
  created_at,
  updated_at
) values
  (
    '51000000-0000-0000-0000-000000000001',
    '41000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    null,
    'That route sounds perfect for a calm evening walk.',
    now() - interval '3 days 22 hours',
    now() - interval '3 days 22 hours'
  ),
  (
    '51000000-0000-0000-0000-000000000002',
    '41000000-0000-0000-0000-000000000002',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    null,
    'Bruno would love to join next time.',
    now() - interval '2 days 20 hours',
    now() - interval '2 days 20 hours'
  ),
  (
    '51000000-0000-0000-0000-000000000003',
    '41000000-0000-0000-0000-000000000003',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    null,
    'Mia clearly has excellent taste in quiet corners.',
    now() - interval '1 day 21 hours',
    now() - interval '1 day 21 hours'
  ),
  (
    '51000000-0000-0000-0000-000000000004',
    '41000000-0000-0000-0000-000000000004',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    null,
    'Please add a short stop near the meadow.',
    now() - interval '15 hours',
    now() - interval '15 hours'
  ),
  (
    '51000000-0000-0000-0000-000000000005',
    '41000000-0000-0000-0000-000000000004',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    null,
    'Good idea, I will update the plan.',
    now() - interval '14 hours',
    now() - interval '14 hours'
  );

insert into public.post_likes (
  id,
  post_id,
  user_id,
  created_at
) values
  (
    '61000000-0000-0000-0000-000000000001',
    '41000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    now() - interval '3 days 21 hours'
  ),
  (
    '61000000-0000-0000-0000-000000000002',
    '41000000-0000-0000-0000-000000000002',
    '11111111-1111-1111-1111-111111111111',
    now() - interval '2 days 19 hours'
  ),
  (
    '61000000-0000-0000-0000-000000000003',
    '41000000-0000-0000-0000-000000000003',
    '22222222-2222-2222-2222-222222222222',
    now() - interval '1 day 20 hours'
  ),
  (
    '61000000-0000-0000-0000-000000000004',
    '41000000-0000-0000-0000-000000000004',
    '11111111-1111-1111-1111-111111111111',
    now() - interval '13 hours'
  );

insert into public.walks (
  id,
  creator_id,
  organizer_name,
  title,
  place,
  latitude,
  longitude,
  scheduled_at,
  description,
  status,
  created_at,
  updated_at
) values
  (
    '71000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    'Morning social walk',
    'Demo Central Park entrance',
    55.7522,
    37.6156,
    now() + interval '2 days',
    'Easy route for friendly dogs and first-time participants.',
    'active',
    now() - interval '5 days',
    now() - interval '5 days'
  ),
  (
    '71000000-0000-0000-0000-000000000002',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    'Weekend shade route',
    'Demo Riverside trail',
    55.7617,
    37.6288,
    now() + interval '5 days',
    'Route with water breaks and shaded paths.',
    'active',
    now() - interval '4 days',
    now() - interval '4 days'
  ),
  (
    '71000000-0000-0000-0000-000000000003',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    'Quiet pet meetup',
    'Demo Neighborhood garden',
    55.7441,
    37.5946,
    now() + interval '8 days',
    'Small meetup for pets who prefer a slower pace.',
    'active',
    now() - interval '2 days',
    now() - interval '2 days'
  );

insert into public.walk_participants (
  id,
  walk_id,
  user_id,
  created_at
) values
  (
    '81000000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    now() - interval '4 days 20 hours'
  ),
  (
    '81000000-0000-0000-0000-000000000002',
    '71000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    now() - interval '4 days 18 hours'
  ),
  (
    '81000000-0000-0000-0000-000000000003',
    '71000000-0000-0000-0000-000000000002',
    '22222222-2222-2222-2222-222222222222',
    now() - interval '3 days 18 hours'
  ),
  (
    '81000000-0000-0000-0000-000000000004',
    '71000000-0000-0000-0000-000000000003',
    '11111111-1111-1111-1111-111111111111',
    now() - interval '1 day 12 hours'
  );

insert into public.chats (
  id,
  last_message_text,
  last_message_sender_id,
  last_message_at,
  created_at,
  updated_at
) values (
  '91000000-0000-0000-0000-000000000001',
  'Great, see you near the entrance.',
  '22222222-2222-2222-2222-222222222222',
  now() - interval '10 hours',
  now() - interval '2 days',
  now() - interval '10 hours'
);

insert into public.chat_participants (
  id,
  chat_id,
  user_id,
  companion_name,
  pet_name,
  unread_count,
  created_at,
  updated_at
) values
  (
    '92000000-0000-0000-0000-000000000001',
    '91000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    'Demo Mark',
    'Rocky',
    1,
    now() - interval '2 days',
    now() - interval '10 hours'
  ),
  (
    '92000000-0000-0000-0000-000000000002',
    '91000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    'Demo Alina',
    'Bruno',
    0,
    now() - interval '2 days',
    now() - interval '10 hours'
  );

insert into public.messages (
  id,
  chat_id,
  sender_id,
  sender_name,
  text,
  status,
  created_at,
  updated_at
) values
  (
    '93000000-0000-0000-0000-000000000001',
    '91000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111',
    'Demo Alina',
    'Hi, is Rocky joining the morning social walk?',
    'sent',
    now() - interval '12 hours',
    now() - interval '12 hours'
  ),
  (
    '93000000-0000-0000-0000-000000000002',
    '91000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    'Yes, he will be happy to join Bruno.',
    'sent',
    now() - interval '11 hours',
    now() - interval '11 hours'
  ),
  (
    '93000000-0000-0000-0000-000000000003',
    '91000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    'Demo Mark',
    'Great, see you near the entrance.',
    'sent',
    now() - interval '10 hours',
    now() - interval '10 hours'
  );

commit;
