-- ============================================
-- CAMPAIGN CHAT FEATURE
-- ============================================

-- 1. Create table
CREATE TABLE IF NOT EXISTS campaign_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL = Public, Set = Private
    content TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE campaign_chat_messages ENABLE ROW LEVEL SECURITY;

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_chat_campaign_id ON campaign_chat_messages(campaign_id);
CREATE INDEX IF NOT EXISTS idx_chat_created_at ON campaign_chat_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_recipient_id ON campaign_chat_messages(recipient_id);

-- 4. RLS Policies

-- SELECT: Users can see messages if:
-- A) They are a member of the campaign
-- AND
-- B) (Message is Public OR Message is To Them OR Message is From Them)
CREATE POLICY "Members can view chat messages"
    ON campaign_chat_messages FOR SELECT
    USING (
        -- Must be a member (reusing our secure function if possible, or direct check)
        -- To avoid recursion issues, let's do a direct check with EXISTS on campaign_members
        EXISTS (
            SELECT 1 FROM campaign_members 
            WHERE campaign_members.campaign_id = campaign_chat_messages.campaign_id
            AND campaign_members.user_id = auth.uid()
        )
        OR 
        -- Or be the owner of the campaign (sessions owner)
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_chat_messages.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    )
    -- We can apply the private filter in the USING clause itself OR simply trust the query
    -- BUT RLS *must* enforce it.
    -- Wait, the USING clause above only checks "Can I access this TABLE row".
    -- I need to combine "Am I a member?" WITH "Can I see THIS specific message?"
    -- Let's combine them properly.
;

DROP POLICY IF EXISTS "Members can view chat messages" ON campaign_chat_messages;

CREATE POLICY "Members can view relevant chat messages"
    ON campaign_chat_messages FOR SELECT
    USING (
        -- 1. Must be associated with the campaign (Member or Owner)
        (
            EXISTS (
                SELECT 1 FROM campaign_members 
                WHERE campaign_members.campaign_id = campaign_chat_messages.campaign_id
                AND campaign_members.user_id = auth.uid()
            )
            OR 
            EXISTS (
                SELECT 1 FROM sessions
                WHERE sessions.id = campaign_chat_messages.campaign_id
                AND sessions.owner_id = auth.uid()
            )
        )
        AND
        -- 2. Message Visibility Rule (Public, To Me, or From Me)
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
        -- Must be a member or owner
        (
            EXISTS (
                SELECT 1 FROM campaign_members 
                WHERE campaign_members.campaign_id = campaign_chat_messages.campaign_id
                AND campaign_members.user_id = auth.uid()
            )
            OR 
            EXISTS (
                SELECT 1 FROM sessions
                WHERE sessions.id = campaign_chat_messages.campaign_id
                AND sessions.owner_id = auth.uid()
            )
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

-- UPDATE (Soft Delete logic usually, but user asked for "Excluir" so hard delete is implemented in DELETE policy above. 
-- If we want soft delete via UPDATE, we need this policy)
CREATE POLICY "Users can soft delete (update) messages"
    ON campaign_chat_messages FOR UPDATE
    USING (
        user_id = auth.uid() 
        OR 
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_chat_messages.campaign_id
            AND sessions.owner_id = auth.uid()
        )
    );
