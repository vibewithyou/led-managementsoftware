-- Add QueueState persistence and QuickActions configuration tables

-- Queue state: runtime state of the live playback queue per project
create table if not exists public.queue_states (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  active_scene_id text not null references public.scenes(id) on delete cascade,
  current_clip_index int not null default -1,
  next_clip_index int not null default 0,
  is_paused boolean not null default false,
  interrupted_by_scene_id text references public.scenes(id) on delete set null,
  return_clip_index int,
  return_timestamp timestamptz,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- Quick actions: user-configurable action policies and templates
create table if not exists public.quick_actions (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  name text not null,
  type text not null,
  target_side text not null,
  linked_scene_id text references public.scenes(id) on delete set null,
  starts_immediately boolean not null default true,
  can_interrupt_protected_clip boolean not null default false,
  requires_confirmation boolean not null default false,
  is_enabled boolean not null default true,
  archive_status text not null default 'active',
  sync_version bigint not null default 1,
  main_pc_last_editor text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- Create indexes for efficient lookups
create index if not exists idx_queue_states_project_id on public.queue_states(project_id);
create index if not exists idx_queue_states_active_scene_id on public.queue_states(active_scene_id);
create index if not exists idx_quick_actions_project_id on public.quick_actions(project_id);
create index if not exists idx_quick_actions_type on public.quick_actions(type);
create index if not exists idx_quick_actions_target_side on public.quick_actions(target_side);

-- Create triggers for updated_at
create trigger trg_queue_states_updated_at before update on public.queue_states
for each row execute function public.set_updated_at();
create trigger trg_quick_actions_updated_at before update on public.quick_actions
for each row execute function public.set_updated_at();

-- Enable RLS
alter table public.queue_states enable row level security;
alter table public.quick_actions enable row level security;

-- Development baseline RLS policies
do $$
begin
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='queue_states' and policyname='queue_states_dev_all') then
    create policy queue_states_dev_all on public.queue_states for all using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='quick_actions' and policyname='quick_actions_dev_all') then
    create policy quick_actions_dev_all on public.quick_actions for all using (true) with check (true);
  end if;
end $$;
