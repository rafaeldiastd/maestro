-- ============================================
-- CAMPAIGN CHAT FEATURE
-- ============================================

CREATE TABLE IF NOT EXISTS campaign_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL = Public, Set = Private
    content TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE campaign_chat_messages ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_chat_campaign_id ON campaign_chat_messages(campaign_id);
CREATE INDEX IF NOT EXISTS idx_chat_created_at ON campaign_chat_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_recipient_id ON campaign_chat_messages(recipient_id);

-- 4. RLS Policies

-- SELECT: Users can see messages if:
-- 1. Must be associated with the campaign (Member or Owner)
-- 2. Message Visibility Rule (Public, To Me, or From Me)
CREATE POLICY "Members can view relevant chat messages"
    ON campaign_chat_messages FOR SELECT
    USING (
        (
            -- Check Membership/Ownership efficiently
            campaign_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid())
            OR
            is_campaign_member(campaign_id)
        )
        AND
        (
            recipient_id IS NULL 
            OR 
            recipient_id = auth.uid() 
            OR 
            user_id = auth.uid()
        )
    );

-- INSERT: Members can insert messages into their campaign
CREATE POLICY "Members can send chat messages"
    ON campaign_chat_messages FOR INSERT
    WITH CHECK (
        (
            campaign_id IN (SELECT id FROM sessions WHERE owner_id = auth.uid())
            OR
            is_campaign_member(campaign_id)
        )
        AND
        -- Can only send as themselves
        user_id = auth.uid()
    );

-- DELETE: 
-- 1. Author can delete their own message
-- 2. Campaign Owner can delete any message
CREATE POLICY "Users can delete their own messages or owner can delete all"
    ON campaign_chat_messages FOR DELETE
    USING (
        -- Author
        user_id = auth.uid()
        OR
        -- Campaign Owner
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_chat_messages.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );
