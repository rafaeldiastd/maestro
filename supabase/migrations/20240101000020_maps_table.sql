-- Create campaign_maps table
CREATE TABLE IF NOT EXISTS campaign_maps (
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
ALTER TABLE campaign_maps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view maps of joined sessions"
  ON campaign_maps FOR SELECT
  USING (
    session_id IN (
        SELECT id FROM sessions WHERE owner_id = auth.uid()
    )
    OR
    is_campaign_member(session_id)
  );

CREATE POLICY "Owners can manage maps"
  ON campaign_maps FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM sessions
      WHERE id = campaign_maps.session_id
      AND owner_id = auth.uid()
    )
  );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_maps_session_id ON campaign_maps(session_id);
