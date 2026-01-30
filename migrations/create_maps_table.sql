-- Create campaign_maps table
drop table if exists campaign_maps cascade;

create table campaign_maps (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references sessions(id) on delete cascade not null,
  name text not null default 'New Map',
  
  -- Dimensions (Pixel Size)
  width int not null default 800,
  height int not null default 600,
  
  -- Grid Config
  grid_cell_width int not null default 50,
  grid_cell_height int not null default 50,
  grid_color text not null default '#000000',
  grid_opacity float not null default 0.3,
  grid_offset_top int not null default 0,
  grid_offset_bottom int not null default 0,
  grid_offset_left int not null default 0,
  grid_offset_right int not null default 0,
  grid_line_width int not null default 1,
  
  -- Background
  background_url text,
  
  -- State
  is_active boolean default false,
  created_at timestamptz default now()
);

-- RLS
alter table campaign_maps enable row level security;

create policy "Users can view maps of joined sessions"
  on campaign_maps for select
  using (
    exists (
      select 1 from campaign_members
      where session_id = campaign_maps.session_id
      and user_id = auth.uid()
    )
    or
    exists (
      select 1 from sessions
      where id = campaign_maps.session_id
      and owner_id = auth.uid()
    )
  );

create policy "Owners can manage maps"
  on campaign_maps for all
  using (
    exists (
      select 1 from sessions
      where id = campaign_maps.session_id
      and owner_id = auth.uid()
    )
  );

-- Indexes
create index idx_maps_session on campaign_maps(session_id);
