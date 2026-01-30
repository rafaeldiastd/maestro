-- ============================================
-- SYSTEM SELECTION UPDATE
-- ============================================
-- Add 'system' column to sessions table
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS system TEXT DEFAULT 'generic';

-- ============================================
-- BESTIARY (NPCs/Monsters) TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS campaign_npcs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    hp TEXT,
    ac TEXT,
    speed TEXT,
    challenge_rating TEXT,
    stats JSONB DEFAULT '{}'::jsonb,
    abilities JSONB DEFAULT '[]'::jsonb, -- Array of {name, desc, effect}
    note_id UUID, -- Link to campaign_notes
    system TEXT DEFAULT 'generic',
    type TEXT DEFAULT 'npc', -- npc/monster
    is_public BOOLEAN DEFAULT FALSE, -- for players to see?
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Force add columns if they don't exist (in case table was created before)
ALTER TABLE campaign_npcs ADD COLUMN IF NOT EXISTS abilities JSONB DEFAULT '[]'::jsonb;
ALTER TABLE campaign_npcs ADD COLUMN IF NOT EXISTS note_id UUID;
ALTER TABLE campaign_npcs ADD COLUMN IF NOT EXISTS system TEXT DEFAULT 'generic';

-- Add tags to notes
ALTER TABLE campaign_notes ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT ARRAY[]::TEXT[];

-- Add resources to npcs
ALTER TABLE campaign_npcs ADD COLUMN IF NOT EXISTS resources JSONB DEFAULT '[]'::jsonb;

-- Enable Row Level Security (RLS)
ALTER TABLE campaign_npcs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for NPCs
-- 1. View: Owners can view all. Players can view if is_public (optional, for now just owner)
DROP POLICY IF EXISTS "Users can view npcs from their sessions" ON campaign_npcs;
CREATE POLICY "Users can view npcs from their sessions"
    ON campaign_npcs FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_npcs.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- 2. Create: Only owners
DROP POLICY IF EXISTS "Users can create npcs in their sessions" ON campaign_npcs;
CREATE POLICY "Users can create npcs in their sessions"
    ON campaign_npcs FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_npcs.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- 3. Update: Only owners
DROP POLICY IF EXISTS "Users can update npcs in their sessions" ON campaign_npcs;
CREATE POLICY "Users can update npcs in their sessions"
    ON campaign_npcs FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_npcs.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- 4. Delete: Only owners
DROP POLICY IF EXISTS "Users can delete npcs from their sessions" ON campaign_npcs;
CREATE POLICY "Users can delete npcs from their sessions"
    ON campaign_npcs FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_npcs.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_npcs_session_id ON campaign_npcs(session_id);
CREATE INDEX IF NOT EXISTS idx_npcs_name ON campaign_npcs(name);

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
