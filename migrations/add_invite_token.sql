-- ============================================
-- ADD INVITE_TOKEN TO EXISTING TABLE
-- ============================================
-- This migration adds the invite_token field to campaign_invitations
-- and generates tokens for existing invitations

-- Step 1: Add the invite_token column
ALTER TABLE campaign_invitations 
ADD COLUMN IF NOT EXISTS invite_token UUID DEFAULT gen_random_uuid();

-- Step 2: Add unique constraint
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_invite_token'
    ) THEN
        ALTER TABLE campaign_invitations 
        ADD CONSTRAINT unique_invite_token UNIQUE (invite_token);
    END IF;
END $$;

-- Step 3: Generate tokens for existing invitations that don't have one
UPDATE campaign_invitations 
SET invite_token = gen_random_uuid() 
WHERE invite_token IS NULL;

-- Step 4: Verify the update
SELECT 
    id, 
    username_or_email, 
    status,
    invite_token,
    created_at
FROM campaign_invitations
ORDER BY created_at DESC
LIMIT 10;
