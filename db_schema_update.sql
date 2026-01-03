-- Run this SQL in your Supabase SQL Editor to support dynamic storage providers

ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS storage_provider text DEFAULT 'supabase',
ADD COLUMN IF NOT EXISTS storage_config jsonb DEFAULT '{}'::jsonb;
