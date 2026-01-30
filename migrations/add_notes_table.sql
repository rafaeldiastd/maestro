-- ============================================
-- CAMPAIGN NOTES SYSTEM
-- ============================================

-- 1. Update Folders Table to support types
ALTER TABLE campaign_folders ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'asset';
-- Update existing folders to be assets
UPDATE campaign_folders SET type = 'asset' WHERE type IS NULL;

-- 2. Create Notes Table
CREATE TABLE IF NOT EXISTS campaign_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    folder_id UUID REFERENCES campaign_folders(id) ON DELETE SET NULL,
    title TEXT NOT NULL DEFAULT 'Untitled',
    content TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. RLS for Notes
ALTER TABLE campaign_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners can manage notes"
    ON campaign_notes
    USING (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_notes.session_id
            AND sessions.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM sessions
            WHERE sessions.id = campaign_notes.session_id
            AND sessions.owner_id = auth.uid()
        )
    );

-- 4. Indexes
CREATE INDEX IF NOT EXISTS idx_notes_session_id ON campaign_notes(session_id);
CREATE INDEX IF NOT EXISTS idx_notes_folder_id ON campaign_notes(folder_id);
