-- ============================================
-- SECURE INVITATION FUNCTIONS
-- ============================================
-- These functions allow players to interact with invitations safely
-- bypassing standard RLS policies via SECURITY DEFINER

-- 1. Function to get invitation details by token
-- Returns invitation + campaign info without exposing other invites
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
SECURITY DEFINER -- Runs with admin privileges
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

-- 2. Function to accept an invitation
-- Handles validation, member insertion, and status update atomically
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
    -- Get current authenticated user
    current_user_id := auth.uid();
    
    -- Check if user is logged in
    IF current_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'User not authenticated');
    END IF;

    -- Get invitation
    SELECT * INTO invite_record 
    FROM campaign_invitations 
    WHERE invite_token = token_input;

    -- Validate invitation exists
    IF invite_record IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Invitation not found');
    END IF;

    -- Validate status
    IF invite_record.status != 'pending' THEN
        RETURN json_build_object('success', false, 'error', 'Invitation is no longer pending');
    END IF;

    -- Check if already a member
    SELECT * INTO existing_member 
    FROM campaign_members 
    WHERE campaign_id = invite_record.campaign_id 
    AND user_id = current_user_id;

    IF existing_member IS NOT NULL THEN
        RETURN json_build_object('success', false, 'error', 'You are already a member of this campaign');
    END IF;

    -- Everything OK, proceed with updates
    
    -- 1. Add to members
    INSERT INTO campaign_members (campaign_id, user_id, role)
    VALUES (invite_record.campaign_id, current_user_id, 'player');

    -- 2. Update invitation status
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
