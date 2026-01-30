-- ============================================
-- FIX RLS INFINITE RECURSION
-- ============================================

-- 1. Create a helper function to check membership without recursion
-- SECURITY DEFINER allows this to run without triggering RLS policies on the tables it queries
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

-- 2. Drop the problematic recursive policies
DROP POLICY IF EXISTS "Members can view campaigns they belong to" ON sessions;
DROP POLICY IF EXISTS "Users with valid invite token can view campaign details" ON sessions;
-- Also drop the existing one that might be part of the loop if it exists
DROP POLICY IF EXISTS "Campaign owners and members can view members" ON campaign_members;


-- 3. Re-create efficient policies using the secure function

-- SESSIONS POLICY:
-- Owners can view (standard) OR Members can view (using secure function)
CREATE POLICY "Users can view sessions they own or belong to"
    ON sessions FOR SELECT
    USING (
        owner_id = auth.uid() 
        OR 
        is_campaign_member(id)
    );

-- 4. Clean up campaign_members policies to be safer
-- Allow users to see their own membership
CREATE POLICY "Users can view own memberships"
    ON campaign_members FOR SELECT
    USING (user_id = auth.uid());

-- Allow owners to see members of their campaigns
-- (This still checks sessions, but since sessions policy uses is_campaign_member (Security Definer), 
-- it shouldn't loop back to this policy unpredictably, but just to be safe, we rely on step 1 function for sessions)
CREATE POLICY "Owners can view project members"
    ON campaign_members FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM sessions 
            WHERE sessions.id = campaign_members.campaign_id 
            AND sessions.owner_id = auth.uid()
        )
    );
