-- ============================================
-- 1. SESSIONS (Campaigns)
-- ============================================
-- Assuming 'sessions' table might already exist in some setups, but defining fully here for completeness.
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    cover_photo TEXT,
    start_date DATE,
    is_open BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. ASSETS
-- ============================================
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

ALTER TABLE assets ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_assets_session_id ON assets(session_id);
CREATE INDEX IF NOT EXISTS idx_assets_created_at ON assets(created_at DESC);

-- ============================================
-- 3. CAMPAIGN MEMBERS
-- ============================================
CREATE TABLE IF NOT EXISTS campaign_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'player' CHECK (role IN ('master', 'player')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(campaign_id, user_id)
);

ALTER TABLE campaign_members ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_members_campaign_id ON campaign_members(campaign_id);
CREATE INDEX IF NOT EXISTS idx_members_user_id ON campaign_members(user_id);

-- ============================================
-- 4. CAMPAIGN INVITATIONS
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

ALTER TABLE campaign_invitations ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_invitations_campaign_id ON campaign_invitations(campaign_id);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON campaign_invitations(status);

-- ============================================
-- RLS POLICIES (Initial Owners Only)
-- ============================================

-- Sessions
CREATE POLICY "Owners can manage sessions"
    ON sessions FOR ALL
    USING (owner_id = auth.uid());

-- Assets
CREATE POLICY "Users can view assets from their sessions"
    ON assets FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = assets.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage assets in their sessions"
    ON assets FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = assets.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Members
CREATE POLICY "Campaign owners can manage members"
    ON campaign_members FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_members.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Invitations
CREATE POLICY "Campaign owners can manage invitations"
    ON campaign_invitations FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_invitations.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );
