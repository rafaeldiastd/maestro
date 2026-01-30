-- Maestro Database Schema for Supabase
-- Execute this in your Supabase SQL Editor
-- NOTA: A tabela 'sessions' já existe, então vamos apenas criar 'assets' e políticas

-- ============================================
-- UPDATE SESSIONS TABLE WITH NEW FIELDS
-- ============================================
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS cover_photo TEXT;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS is_open BOOLEAN DEFAULT TRUE;

-- ============================================
-- ASSETS TABLE
-- ============================================
-- Assets Table (criar apenas se não existir)
CREATE TABLE IF NOT EXISTS assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    display_name TEXT,
    is_revealed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Assets (usando owner_id da tabela sessions)
DROP POLICY IF EXISTS "Users can view assets from their sessions" ON assets;
CREATE POLICY "Users can view assets from their sessions"
    ON assets FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = assets.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can create assets in their sessions" ON assets;
CREATE POLICY "Users can create assets in their sessions"
    ON assets FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = assets.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can update assets in their sessions" ON assets;
CREATE POLICY "Users can update assets in their sessions"
    ON assets FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = assets.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can delete assets from their sessions" ON assets;
CREATE POLICY "Users can delete assets from their sessions"
    ON assets FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = assets.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_assets_session_id ON assets(session_id);
CREATE INDEX IF NOT EXISTS idx_assets_created_at ON assets(created_at DESC);

-- ============================================
-- CAMPAIGN INVITATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS campaign_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    invited_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username_or_email TEXT NOT NULL,
    invite_token UUID DEFAULT gen_random_uuid(),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'revoked')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(invite_token)
);

-- Enable RLS
ALTER TABLE campaign_invitations ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Invitations
DROP POLICY IF EXISTS "Campaign owners can view invitations" ON campaign_invitations;
CREATE POLICY "Campaign owners can view invitations"
    ON campaign_invitations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_invitations.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Campaign owners can create invitations" ON campaign_invitations;
CREATE POLICY "Campaign owners can create invitations"
    ON campaign_invitations FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_invitations.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Campaign owners can update invitations" ON campaign_invitations;
CREATE POLICY "Campaign owners can update invitations"
    ON campaign_invitations FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_invitations.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Campaign owners can delete invitations" ON campaign_invitations;
CREATE POLICY "Campaign owners can delete invitations"
    ON campaign_invitations FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_invitations.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_invitations_campaign_id ON campaign_invitations(campaign_id);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON campaign_invitations(status);

-- ============================================
-- CAMPAIGN MEMBERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS campaign_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'player' CHECK (role IN ('master', 'player')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(campaign_id, user_id)
);

-- Enable RLS
ALTER TABLE campaign_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Members
DROP POLICY IF EXISTS "Campaign owners and members can view members" ON campaign_members;
CREATE POLICY "Campaign owners and members can view members"
    ON campaign_members FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_members.campaign_id
            AND (sessions.owner_id = auth.uid() OR campaign_members.user_id = auth.uid())
        )
    );

DROP POLICY IF EXISTS "Campaign owners can add members" ON campaign_members;
CREATE POLICY "Campaign owners can add members"
    ON campaign_members FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_members.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Campaign owners can remove members" ON campaign_members;
CREATE POLICY "Campaign owners can remove members"
    ON campaign_members FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_members.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_members_campaign_id ON campaign_members(campaign_id);
CREATE INDEX IF NOT EXISTS idx_members_user_id ON campaign_members(user_id);
