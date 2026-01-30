-- ============================================
-- SECURE MEMBER FUNCTIONS
-- ============================================

-- Function to get all members of a campaign with their details
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
