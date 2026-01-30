-- Create a table to store initiative state for each campaign session
CREATE TABLE IF NOT EXISTS public.campaign_initiatives (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
    participants JSONB DEFAULT '[]'::jsonb,
    round INTEGER DEFAULT 1,
    current_turn_index INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    CONSTRAINT campaign_initiatives_session_id_key UNIQUE (session_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.campaign_initiatives ENABLE ROW LEVEL SECURITY;

-- Create Policy: Allow read access to anyone (or specific logic if needed)
-- Assuming public/authenticated users can read for now based on session access
CREATE POLICY "Enable read access for all users" ON public.campaign_initiatives
    FOR SELECT USING (true);

-- Create Policy: Allow insert/update for authenticated users (or owners)
-- Adjust based on your specific RLS needs (e.g., only owner can update)
CREATE POLICY "Enable insert/update for authenticated users" ON public.campaign_initiatives
    FOR ALL USING (auth.role() = 'authenticated');
