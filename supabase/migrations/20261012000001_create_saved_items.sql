-- 001_create_saved_items.sql
create extension if not exists pgcrypto with schema extensions;

create table public.saved_items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  type text not null check (type in ('note','link','image')),
  title text not null default '' check (char_length(title) <= 200),
  content text check (content is null or char_length(content) <= 20000),
  url text check (url is null or (char_length(url) <= 2048 and url ~* '^https?://')),
  tags text[] not null default '{}' check (cardinality(tags) <= 20),
  archived boolean not null default false,
  remind_at timestamptz,
  attachment_path text,
  attachment_name text,
  attachment_mime text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint attachment_in_owner_folder
    check (attachment_path is null or attachment_path like owner_id::text || '/%')
);

create index saved_items_owner_updated_idx on public.saved_items (owner_id, updated_at desc);
create index saved_items_tags_idx on public.saved_items using gin (tags);

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger saved_items_set_updated_at
  before update on public.saved_items
  for each row execute function public.set_updated_at();

alter table public.saved_items enable row level security;

create policy "select own" on public.saved_items
  for select to authenticated using (owner_id = (select auth.uid()));

create policy "insert own" on public.saved_items
  for insert to authenticated with check (owner_id = (select auth.uid()));

create policy "update own" on public.saved_items
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "delete own" on public.saved_items
  for delete to authenticated using (owner_id = (select auth.uid()));
