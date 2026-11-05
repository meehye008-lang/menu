-- Supabase Dashboard → SQL Editor → New query에서 전체를 실행하세요.
-- 기존 즐겨찾기 데이터는 삭제하지 않으며, 다시 실행해도 안전합니다.
begin;

create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  recipe_id integer not null check (recipe_id > 0),
  created_at timestamptz not null default now(),
  constraint favorites_user_recipe_unique unique (user_id, recipe_id)
);

alter table public.favorites enable row level security;
revoke all on table public.favorites from anon, authenticated;
grant select, insert, delete on table public.favorites to authenticated;

drop policy if exists favorites_owner_guard on public.favorites;
create policy favorites_owner_guard on public.favorites
  as restrictive for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists favorites_select_own on public.favorites;
create policy favorites_select_own on public.favorites
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists favorites_insert_own on public.favorites;
create policy favorites_insert_own on public.favorites
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists favorites_delete_own on public.favorites;
create policy favorites_delete_own on public.favorites
  for delete to authenticated using ((select auth.uid()) = user_id);

commit;
