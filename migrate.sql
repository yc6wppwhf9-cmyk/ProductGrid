-- ============================================================
-- Migration: new product columns + clients-per-channel table
-- Run this ONCE in the Supabase SQL Editor (your existing project).
-- Fresh installs should run setup.sql instead — not this file.
-- ============================================================

-- New product fields from the planning sheet
alter table public.products
  add column if not exists client text,
  add column if not exists size text,
  add column if not exists target_bom text,
  add column if not exists price_point text,
  add column if not exists fabric text,
  add column if not exists assigned_to text;

-- notes -> description (keeps any text already entered)
do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'products' and column_name = 'notes')
     and not exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'products' and column_name = 'description')
  then
    alter table public.products rename column notes to description;
  end if;
end $$;

alter table public.products drop column if exists product_range;

-- Clients per channel (e.g. MT -> Reliance, D Mart, Vishal Mega Mart)
create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references public.channels(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  unique (channel_id, name)
);

alter table public.clients enable row level security;

drop policy if exists "authenticated full access clients" on public.clients;
create policy "authenticated full access clients"
  on public.clients for all
  to authenticated
  using (true) with check (true);

do $$
begin
  alter publication supabase_realtime add table public.clients;
exception when duplicate_object then null;
end $$;
