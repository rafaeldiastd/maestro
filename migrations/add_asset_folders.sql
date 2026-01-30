-- ============================================
-- CAMPAIGN ASSET FOLDERS
-- ============================================

-- 1. Create Folders Table
CREATE TABLE IF NOT EXISTS campaign_folders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    parent_id UUID REFERENCES campaign_folders(id) ON DELETE CASCADE, -- Allow nesting
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Update Assets Table
ALTER TABLE assets ADD COLUMN IF NOT EXISTS folder_id UUID REFERENCES campaign_folders(id) ON DELETE SET NULL;

-- 3. RLS for Folders
ALTER TABLE campaign_folders ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can do everything with folders in their session
CREATE POLICY "Owners can manage folders"
    ON campaign_folders
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_folders.session_id
            AND sessions.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_folders.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- Policy: Players can view folders (if we want players to browse? Usually players just see revealed images. 
-- But if we organise revealed images by folder for players later, they might need read access.
-- For now, let's keep it restricted to owners unless Player View needs it. Player View currently queries 'session_assets' view.
-- Does 'session_assets' include folder info? Not yet. 
-- Let's stick to Owner management for now.

-- 4. Permission for Storage? No changes needed for buckets, this is logical organization.

-- 5. Helper function or Indexes
CREATE INDEX IF NOT EXISTS idx_folders_session_id ON campaign_folders(session_id);
CREATE INDEX IF NOT EXISTS idx_assets_folder_id ON assets(folder_id);
