-- ============================================
-- SECURITY FUNCTIONS
-- ============================================

-- Function to check membership efficiently (Avoiding recursion in RLS)
CREATE OR REPLACE FUNCTION is_campaign_member(session_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM campaign_members 
        WHERE campaign_id = session_id 
        AND user_id = auth.uid()
    );
END;
$$;

-- Function to get invitation details securely
CREATE OR REPLACE FUNCTION get_invitation_details(token_input UUID)
RETURNS TABLE (
    id UUID,
    status TEXT,
    username_or_email TEXT,
    campaign_id UUID,
    campaign_name TEXT,
    campaign_description TEXT,
    campaign_cover_photo TEXT,
    invited_by_email TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ci.id,
        ci.status,
        ci.username_or_email,
        ci.campaign_id,
        s.name as campaign_name,
        s.description as campaign_description,
        s.cover_photo as campaign_cover_photo,
        u.email::TEXT as invited_by_email
    FROM campaign_invitations ci
    JOIN sessions s ON ci.campaign_id = s.id
    JOIN auth.users u ON ci.invited_by = u.id
    WHERE ci.invite_token = token_input;
END;
$$;

-- Function to accept invitation securely
CREATE OR REPLACE FUNCTION accept_invitation(token_input UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    invite_record RECORD;
    current_user_id UUID;
    existing_member RECORD;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'User not authenticated');
    END IF;

    SELECT * INTO invite_record 
    FROM campaign_invitations 
    WHERE invite_token = token_input;

    IF invite_record IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Invitation not found');
    END IF;

    IF invite_record.status != 'pending' THEN
        RETURN json_build_object('success', false, 'error', 'Invitation is no longer pending');
    END IF;

    SELECT * INTO existing_member 
    FROM campaign_members 
    WHERE campaign_id = invite_record.campaign_id 
    AND user_id = current_user_id;

    IF existing_member IS NOT NULL THEN
        RETURN json_build_object('success', false, 'error', 'You are already a member of this campaign');
    END IF;

    INSERT INTO campaign_members (campaign_id, user_id, role)
    VALUES (invite_record.campaign_id, current_user_id, 'player');

    UPDATE campaign_invitations 
    SET status = 'accepted', updated_at = NOW()
    WHERE id = invite_record.id;

    RETURN json_build_object(
        'success', true, 
        'campaignId', invite_record.campaign_id
    );

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

-- Function to get campaign members details securely
CREATE OR REPLACE FUNCTION get_campaign_members_details(campaign_id_input UUID)
RETURNS TABLE (
    user_id UUID,
    role TEXT,
    joined_at TIMESTAMPTZ,
    email TEXT,
    last_sign_in_at TIMESTAMPTZ
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check if requester is a member or owner
    IF NOT is_campaign_member(campaign_id_input) AND NOT EXISTS (SELECT 1 FROM sessions WHERE id = campaign_id_input AND owner_id = auth.uid()) THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT 
        cm.user_id,
        cm.role,
        cm.joined_at,
        u.email::TEXT,
        u.last_sign_in_at
    FROM campaign_members cm
    JOIN auth.users u ON cm.user_id = u.id
    WHERE cm.campaign_id = campaign_id_input
    ORDER BY cm.joined_at ASC;
END;
$$;

-- ============================================
-- UPDATED RLS POLICIES (Using Helper Functions)
-- ============================================

-- Sessions: Allow Members to View
CREATE POLICY "Members can view campaigns they belong to"
    ON sessions FOR SELECT
    USING (
        owner_id = auth.uid() 
        OR 
        is_campaign_member(id)
    );

-- Members: Allow Users to View Own Membership
CREATE POLICY "Users can view own memberships"
    ON campaign_members FOR SELECT
    USING (user_id = auth.uid());

-- Members: Allow Owners/Members to view project members
-- (Optimized to avoid deep recursion loop via is_campaign_member on sessions)
CREATE POLICY "Campaign participants can view members"
    ON campaign_members FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_members.campaign_id
            AND (sessions.owner_id = auth.uid() OR is_campaign_member(sessions.id))
        )
    );
