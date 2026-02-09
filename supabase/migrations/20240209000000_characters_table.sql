-- ============================================
-- CHARACTERS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Nullable for NPCs created by DM later
    name TEXT NOT NULL,
    class TEXT,
    race TEXT,
    level INTEGER DEFAULT 1,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure user can only have one character per campaign for now? 
    -- Or allow multiple? Let's allow multiple but maybe UI restricts.
    -- For this simple version, let's just index user_id/campaign_id
    UNIQUE(campaign_id, user_id) 
);

ALTER TABLE characters ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_characters_campaign_id ON characters(campaign_id);
CREATE INDEX IF NOT EXISTS idx_characters_user_id ON characters(user_id);

-- POLICIES

-- SELECT: 
-- 1. Campaign Owner can see all characters
-- 2. Campaign Members can see all characters (public party)
CREATE POLICY "Campaign members can view characters"
    ON characters FOR SELECT
    USING (
        (campaign_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid()))
        OR
        (is_campaign_member(campaign_id))
    );

-- INSERT:
-- Users can create characters for campaigns they are members of
CREATE POLICY "Members can create characters"
    ON characters FOR INSERT
    WITH CHECK (
        is_campaign_member(campaign_id)
        AND
        user_id = auth.uid()
    );

-- UPDATE:
-- Users can update their own characters
-- DM can update any character in their campaign
CREATE POLICY "Users can update their own characters or DM"
    ON characters FOR UPDATE
    USING (
        user_id = auth.uid()
        OR
        campaign_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid())
    );

-- DELETE:
-- Users can delete their own characters
-- DM can delete any character
CREATE POLICY "Users can delete their own characters or DM"
    ON characters FOR DELETE
    USING (
        user_id = auth.uid()
        OR
        campaign_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid())
    );
