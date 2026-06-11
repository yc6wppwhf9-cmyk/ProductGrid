-- ============================================================
-- Migration: flexible per-channel product fields + clients table
-- Run this ONCE in the Supabase SQL Editor (your existing project).
-- Safe to run again — every step skips what already exists.
-- Fresh installs should run setup.sql instead — not this file.
-- ============================================================

-- Core columns
alter table public.products
  add column if not exists client text,
  add column if not exists assigned_to text,
  add column if not exists attrs jsonb not null default '{}'::jsonb;

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

alter table public.products
  add column if not exists description text;

-- Fold any old per-template columns into the attrs JSON, then drop them
do $$
declare col text;
begin
  foreach col in array array['size', 'target_bom', 'price_point', 'sku', 'fabric', 'product_range']
  loop
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'products' and column_name = col)
    then
      execute format(
        'update public.products set attrs = attrs || jsonb_build_object(%L, %I) where %I is not null',
        col, col, col);
      execute format('alter table public.products drop column %I', col);
    end if;
  end loop;
end $$;

-- Clients per channel (e.g. MT -> Reliance, D Mart, Vishal Mega Mart;
-- ECom -> Ecom OR, Ecom-MP)
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
