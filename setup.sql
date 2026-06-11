-- ============================================================
-- Product Grid — database setup
-- Run this once in the Supabase SQL Editor of your new project
-- (Dashboard -> SQL Editor -> New query -> paste -> Run)
-- ============================================================

-- Channels (e.g. Amazon, Flipkart, Retail)
create table if not exists public.channels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

-- Products, each belonging to one channel
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references public.channels(id) on delete cascade,
  name text not null,
  product_range text,
  sku text,
  notes text,
  status text not null default 'red' check (status in ('red', 'yellow', 'green')),
  illustration_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_channel_id_idx on public.products (channel_id);

-- Keep updated_at fresh
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists products_updated_at on public.products;
create trigger products_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

-- ---------- Row Level Security: logged-in users only ----------
alter table public.channels enable row level security;
alter table public.products enable row level security;

drop policy if exists "authenticated full access channels" on public.channels;
create policy "authenticated full access channels"
  on public.channels for all
  to authenticated
  using (true) with check (true);

drop policy if exists "authenticated full access products" on public.products;
create policy "authenticated full access products"
  on public.products for all
  to authenticated
  using (true) with check (true);

-- ---------- Storage bucket for illustrations ----------
insert into storage.buckets (id, name, public)
values ('illustrations', 'illustrations', true)
on conflict (id) do nothing;

drop policy if exists "public read illustrations" on storage.objects;
create policy "public read illustrations"
  on storage.objects for select
  using (bucket_id = 'illustrations');

drop policy if exists "auth insert illustrations" on storage.objects;
create policy "auth insert illustrations"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'illustrations');

drop policy if exists "auth update illustrations" on storage.objects;
create policy "auth update illustrations"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'illustrations');

drop policy if exists "auth delete illustrations" on storage.objects;
create policy "auth delete illustrations"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'illustrations');

-- ---------- Realtime so teammates see live updates ----------
do $$
begin
  alter publication supabase_realtime add table public.channels;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.products;
exception when duplicate_object then null;
end $$;
