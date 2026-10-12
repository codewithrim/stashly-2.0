-- 003_create_share_links.sql
create table public.share_links (
  token text primary key default encode(extensions.gen_random_bytes(24), 'hex'),
  item_id uuid not null references public.saved_items(id) on delete cascade,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);

create unique index share_links_one_active_per_item
  on public.share_links (item_id) where revoked_at is null;

alter table public.share_links enable row level security;

create policy "links select own" on public.share_links
  for select to authenticated using (owner_id = (select auth.uid()));

create policy "links insert own item" on public.share_links
  for insert to authenticated with check (
    owner_id = (select auth.uid())
    and exists (select 1 from public.saved_items i
                where i.id = item_id and i.owner_id = (select auth.uid()))
  );

create policy "links update own" on public.share_links
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "links delete own" on public.share_links
  for delete to authenticated using (owner_id = (select auth.uid()));

create or replace function public.get_shared_item(p_token text)
returns table (type text, title text, content text, url text, tags text[], updated_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select i.type, i.title, i.content, i.url, i.tags, i.updated_at
  from public.share_links s
  join public.saved_items i on i.id = s.item_id
  where s.token = p_token
    and s.revoked_at is null
    and length(p_token) = 48
  limit 1;
$$;

revoke all on function public.get_shared_item(text) from public;
grant execute on function public.get_shared_item(text) to anon, authenticated;
