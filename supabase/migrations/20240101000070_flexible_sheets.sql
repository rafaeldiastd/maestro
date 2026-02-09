-- ============================================
-- FLEXIBLE CHARACTER SHEET SYSTEM
-- ============================================

-- 1. sheet_templates
-- Stores the structure/schema for different game systems (D&D 5e, Pathfinder, etc.)

-- [FIX] Drop tables if they exist to ensure schema update
DROP TABLE IF EXISTS characters;
-- DROP TABLE IF EXISTS sheet_templates; -- Optional, but might break references if other tables existed. kept for safety.

CREATE TABLE IF NOT EXISTS sheet_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    system_key TEXT NOT NULL UNIQUE, -- 'dnd5e', 'pf2e', 'daggerheart', etc.
    schema JSONB NOT NULL DEFAULT '{}'::jsonb, -- Defines tabs, fields, formulas, layout
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE sheet_templates ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read templates
CREATE POLICY "Everyone can read sheet templates"
    ON sheet_templates FOR SELECT
    USING (true);

-- Policy: Only service role/admin can manage templates (for now)
-- You can add an admin check here later if needed

-- 2. Add template reference to sessions
ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS sheet_template_id UUID REFERENCES sheet_templates(id);

-- 3. characters
-- Stores the actual character data linked to a player and a session
CREATE TABLE IF NOT EXISTS characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Nullable for unclaimed/NPCs
    name TEXT NOT NULL,
    avatar_url TEXT,
    data JSONB NOT NULL DEFAULT '{}'::jsonb, -- dynamic values matching the template schema
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE characters ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_characters_session_id ON characters(session_id);
CREATE INDEX IF NOT EXISTS idx_characters_user_id ON characters(user_id);

-- RLS Policies for characters

-- View: Public (within session) or Private? Usually public for party members
-- For now, let's say if you are a member of the campaign (session), you can view characters involved.
-- We can reuse the "exists in session" logic.

CREATE POLICY "Members can view characters in their campaign"
    ON characters FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM campaign_members cm
            WHERE cm.campaign_id = characters.session_id
            AND cm.user_id = auth.uid()
        )
        OR 
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.id = characters.session_id
            AND s.owner_id = auth.uid()
        )
    );

-- Manage: Users can update their own characters AND Masters can update any character in their session
CREATE POLICY "Users and Masters can update characters"
    ON characters FOR UPDATE
    USING (
        -- Is Owner of Character
        (auth.uid() = user_id)
        OR
        -- Is Master of Session
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.id = characters.session_id
            AND s.owner_id = auth.uid()
        )
    );

-- Create: Masters can assign/create characters. Players can create if allowed (let's allow for now if member)
CREATE POLICY "Members can create characters"
    ON characters FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM campaign_members cm
            WHERE cm.campaign_id = session_id
            AND cm.user_id = auth.uid()
        )
        OR
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.id = session_id
            AND s.owner_id = auth.uid()
        )
    );

-- Delete: Only Owner or Master
CREATE POLICY "Owners and Masters can delete characters"
    ON characters FOR DELETE
    USING (
        (auth.uid() = user_id)
        OR
        EXISTS (
            SELECT 1 FROM sessions s
            WHERE s.id = characters.session_id
            AND s.owner_id = auth.uid()
        )
    );

-- 4. Initial Seed Data: D&D 5e Template
-- This is a simplified schema structure we will expand on in the frontend code
INSERT INTO sheet_templates (name, system_key, schema) 
VALUES (
    'Dumb & Dragons 5e', 
    'dnd5e', 
    '{
        "tabs": [
            { "id": "main", "label": "Principal" },
            { "id": "combat", "label": "Combate" },
            { "id": "spells", "label": "Magias" },
            { "id": "inventory", "label": "Inventário" },
            { "id": "bio", "label": "Biografia" }
        ],
        "attributes": [
            { "key": "str", "label": "Força", "type": "number", "default": 10 },
            { "key": "dex", "label": "Destreza", "type": "number", "default": 10 },
            { "key": "con", "label": "Constituição", "type": "number", "default": 10 },
            { "key": "int", "label": "Inteligência", "type": "number", "default": 10 },
            { "key": "wis", "label": "Sabedoria", "type": "number", "default": 10 },
            { "key": "cha", "label": "Carisma", "type": "number", "default": 10 }
        ],
        "skills": [
            { "key": "acrobatics", "label": "Acrobacia", "attr": "dex" },
            { "key": "athletics", "label": "Atletismo", "attr": "str" },
            { "key": "stealth", "label": "Furtividade", "attr": "dex" },
            { "key": "perception", "label": "Percepção", "attr": "wis" }
        ],
        "stats": [
            { "key": "hp", "label": "Pontos de Vida", "type": "current_max", "default": { "current": 10, "max": 10 } },
            { "key": "ac", "label": "Classe de Armadura", "type": "number", "default": 10 },
            { "key": "speed", "label": "Deslocamento", "type": "number", "default": 9 },
            { "key": "initiative", "label": "Iniciativa", "type": "bonus", "default": 0 }
        ]
    }'::jsonb
) ON CONFLICT (system_key) DO NOTHING;
