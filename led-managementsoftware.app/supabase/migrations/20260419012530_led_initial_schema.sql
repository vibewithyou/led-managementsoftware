-- Teil 4 initial schema for LED Management Software

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.projects (
  id text primary key,
  name text not null,
  date timestamptz not null,
  location text not null,
  status text not null,
  home_team text not null,
  away_team text not null,
  notes text not null default '',
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  archived_at timestamptz
);

create table if not exists public.teams (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  name text not null,
  side text not null,
  short_name text,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.players (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  team_id text references public.teams(id) on delete set null,
  team_side text not null,
  name text not null,
  number int not null,
  linked_clip_ids text[] not null default '{}',
  enabled_for_intro boolean not null default false,
  enabled_for_goal boolean not null default false,
  enabled_for_injury boolean not null default false,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.media_categories (
  id text primary key,
  project_id text references public.projects(id) on delete cascade,
  name text not null,
  description text,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.media_items (
  id text primary key,
  category_id text not null references public.media_categories(id) on delete restrict,
  name text not null,
  local_path text not null,
  remote_path text,
  type text not null,
  tags text[] not null default '{}',
  duration_ms int not null default 0,
  is_active boolean not null default true,
  sync_status text not null default 'localOnly',
  checksum text not null,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.scenes (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  name text not null,
  category text not null,
  is_looping boolean not null default false,
  is_active boolean not null default true,
  is_default boolean not null default false,
  fallback_scene_id text references public.scenes(id) on delete set null,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.scene_clips (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  scene_id text not null references public.scenes(id) on delete cascade,
  media_item_id text not null references public.media_items(id) on delete restrict,
  is_protected boolean not null default false,
  is_overridable boolean not null default true,
  priority int not null default 0,
  play_once boolean not null default false,
  repeatable boolean not null default true,
  rotation_group text,
  return_behavior text not null,
  interruption_policy text not null,
  sort_order int not null default 0,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.device_profiles (
  id text primary key,
  name text not null,
  type text not null,
  is_online boolean not null default false,
  is_main_pc boolean not null default false,
  last_sync_at timestamptz not null default timezone('utc', now()),
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.live_log_entries (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  timestamp timestamptz not null,
  device_id text not null references public.device_profiles(id) on delete restrict,
  actor_name text not null,
  action text not null,
  details text not null,
  success boolean not null default true,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_projects_updated_at on public.projects(updated_at desc);
create index if not exists idx_teams_project_id on public.teams(project_id);
create index if not exists idx_players_project_id on public.players(project_id);
create index if not exists idx_players_team_id on public.players(team_id);
create index if not exists idx_media_categories_project_id on public.media_categories(project_id);
create index if not exists idx_media_items_category_id on public.media_items(category_id);
create index if not exists idx_scenes_project_id on public.scenes(project_id);
create index if not exists idx_scene_clips_scene_id on public.scene_clips(scene_id, sort_order);
create index if not exists idx_scene_clips_project_id on public.scene_clips(project_id);
create index if not exists idx_device_profiles_is_main_pc on public.device_profiles(is_main_pc);
create index if not exists idx_live_log_entries_project_id on public.live_log_entries(project_id, timestamp desc);

create trigger trg_projects_updated_at before update on public.projects
for each row execute function public.set_updated_at();
create trigger trg_teams_updated_at before update on public.teams
for each row execute function public.set_updated_at();
create trigger trg_players_updated_at before update on public.players
for each row execute function public.set_updated_at();
create trigger trg_media_categories_updated_at before update on public.media_categories
for each row execute function public.set_updated_at();
create trigger trg_media_items_updated_at before update on public.media_items
for each row execute function public.set_updated_at();
create trigger trg_scenes_updated_at before update on public.scenes
for each row execute function public.set_updated_at();
create trigger trg_scene_clips_updated_at before update on public.scene_clips
for each row execute function public.set_updated_at();
create trigger trg_device_profiles_updated_at before update on public.device_profiles
for each row execute function public.set_updated_at();
create trigger trg_live_log_entries_updated_at before update on public.live_log_entries
for each row execute function public.set_updated_at();

alter table public.projects enable row level security;
alter table public.teams enable row level security;
alter table public.players enable row level security;
alter table public.media_categories enable row level security;
alter table public.media_items enable row level security;
alter table public.scenes enable row level security;
alter table public.scene_clips enable row level security;
alter table public.device_profiles enable row level security;
alter table public.live_log_entries enable row level security;

-- Development policy baseline. Can be tightened with auth/device scopes later.
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='projects' and policyname='projects_dev_all') then
    create policy projects_dev_all on public.projects for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='teams' and policyname='teams_dev_all') then
    create policy teams_dev_all on public.teams for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='players' and policyname='players_dev_all') then
    create policy players_dev_all on public.players for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='media_categories' and policyname='media_categories_dev_all') then
    create policy media_categories_dev_all on public.media_categories for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='media_items' and policyname='media_items_dev_all') then
    create policy media_items_dev_all on public.media_items for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='scenes' and policyname='scenes_dev_all') then
    create policy scenes_dev_all on public.scenes for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='scene_clips' and policyname='scene_clips_dev_all') then
    create policy scene_clips_dev_all on public.scene_clips for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='device_profiles' and policyname='device_profiles_dev_all') then
    create policy device_profiles_dev_all on public.device_profiles for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='live_log_entries' and policyname='live_log_entries_dev_all') then
    create policy live_log_entries_dev_all on public.live_log_entries for all using (true) with check (true);
  end if;
end $$;
