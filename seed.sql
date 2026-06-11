-- ============================================================
-- Seed: starting channels and their clients/parts
-- Run AFTER migrate.sql (or setup.sql), in the Supabase SQL Editor.
-- Safe to run multiple times — existing entries are skipped.
-- ============================================================

insert into public.channels (name)
values ('MT'), ('ECom')
on conflict (name) do nothing;

insert into public.clients (channel_id, name)
select c.id, v.client_name
from (values
  ('MT',   'Reliance'),
  ('MT',   'D Mart'),
  ('MT',   'Vishal Mega Mart'),
  ('ECom', 'Ecom OR'),
  ('ECom', 'Ecom-MP')
) as v(channel_name, client_name)
join public.channels c on c.name = v.channel_name
on conflict (channel_id, name) do nothing;
