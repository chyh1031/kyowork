-- MiddlePoint Supabase 스키마 설계안 (S1)
--
-- 아직 실제 Supabase 프로젝트에 연결되지 않은 설계 문서다 (BACKLOG.md S3 참고).
-- 실제 프로젝트 생성 후 이 파일을 그대로 SQL Editor에서 실행하거나
-- `supabase/migrations/`로 옮겨 마이그레이션화한다.
--
-- listings 테이블의 title/description/category/price/price_range_min/price_range_max
-- 필드는 mobile/src/schemas/listing.ts, server/lib/schema.ts의 Listing 타입과 1:1로 대응해야 한다.

-- 1. profiles — auth.users를 확장하는 프로필 테이블 (Supabase 관례)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles are viewable by owner" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles are editable by owner" on public.profiles
  for update using (auth.uid() = id);

-- 2. listings — 사용자가 등록한 판매글 (AI 생성 결과 저장)
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null,
  category text not null,
  price integer not null check (price >= 0),
  price_range_min integer not null check (price_range_min >= 0),
  price_range_max integer not null check (price_range_max >= price_range_min),
  photo_url text,
  status text not null default 'active' check (status in ('active', 'sold', 'archived')),
  created_at timestamptz not null default now()
);

alter table public.listings enable row level security;

create policy "listings are viewable by owner" on public.listings
  for select using (auth.uid() = user_id);

create policy "listings are insertable by owner" on public.listings
  for insert with check (auth.uid() = user_id);

create policy "listings are updatable by owner" on public.listings
  for update using (auth.uid() = user_id);

create index if not exists listings_user_id_idx on public.listings (user_id);

-- 3. listing_feedback — 판매완료 피드백 (실제 판매가). 가격모델 보정의 핵심 데이터.
create table if not exists public.listing_feedback (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings (id) on delete cascade,
  sold_price integer not null check (sold_price >= 0),
  sold_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table public.listing_feedback enable row level security;

create policy "feedback is viewable by listing owner" on public.listing_feedback
  for select using (
    exists (
      select 1 from public.listings
      where public.listings.id = listing_feedback.listing_id
        and public.listings.user_id = auth.uid()
    )
  );

create policy "feedback is insertable by listing owner" on public.listing_feedback
  for insert with check (
    exists (
      select 1 from public.listings
      where public.listings.id = listing_feedback.listing_id
        and public.listings.user_id = auth.uid()
    )
  );

create index if not exists listing_feedback_listing_id_idx on public.listing_feedback (listing_id);

-- ============================================================
-- 추가 마이그레이션 (S7): 신규 유저 profiles 자동 생성
-- 위 스크립트를 이미 실행했다면, 아래 블록만 SQL Editor에서 추가로 실행하면 된다.
-- (없으면 auth.users에는 로그인됐는데 profiles 행이 없어서 listings insert가
--  외래키 위반으로 실패한다.)
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 클라이언트에서 직접 upsert할 수도 있도록 안전장치 정책 추가
drop policy if exists "profiles are insertable by owner" on public.profiles;
create policy "profiles are insertable by owner" on public.profiles
  for insert with check (auth.uid() = id);
