-- Create a table to store initiative state for each campaign session
CREATE TABLE IF NOT EXISTS campaign_initiatives (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    participants JSONB DEFAULT '[]'::jsonb,
    round INTEGER DEFAULT 1,
    current_turn_index INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT campaign_initiatives_session_id_key UNIQUE (session_id)
);

ALTER TABLE campaign_initiatives ENABLE ROW LEVEL SECURITY;

-- Policy: Members and Owners can VIEW (Read)
CREATE POLICY "Campaign participants can view initiative"
    ON campaign_initiatives FOR SELECT
    USING (
        -- Check Ownership
        session_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid())
        OR 
        -- Check Membership (using helper function if available, or direct check)
        is_campaign_member(session_id)
    );

-- Policy: Owners can MANAGE (Update/Insert)
-- Can Players update? Usually initiative is managed by DM, but players might add themselves via RPC or specialized function.
-- For now, let's allow Owners full control.
CREATE POLICY "Owners can manage initiative"
    ON campaign_initiatives FOR ALL
    USING (
         session_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid())
    );

CREATE INDEX IF NOT EXISTS idx_initiative_session_id ON campaign_initiatives(session_id);
