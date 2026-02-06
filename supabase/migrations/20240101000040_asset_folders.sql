-- ============================================
-- CAMPAIGN ASSET FOLDERS
-- ============================================

CREATE TABLE IF NOT EXISTS campaign_folders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    parent_id UUID REFERENCES campaign_folders(id) ON DELETE CASCADE, -- Allow nesting
    type TEXT DEFAULT 'asset',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Update Assets Table
ALTER TABLE assets ADD COLUMN IF NOT EXISTS folder_id UUID REFERENCES campaign_folders(id) ON DELETE SET NULL;

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
    );

CREATE INDEX IF NOT EXISTS idx_folders_session_id ON campaign_folders(session_id);
CREATE INDEX IF NOT EXISTS idx_assets_folder_id ON assets(folder_id);
