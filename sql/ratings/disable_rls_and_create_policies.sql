-- Disable Row Level Security (RLS) for ratings table
-- This allows direct access with anon key during development
ALTER TABLE ratings DISABLE ROW LEVEL SECURITY;

-- Grant necessary permissions for anonymous access
GRANT ALL ON TABLE ratings TO anon;
GRANT ALL ON TABLE ratings TO authenticated;

-- Optional: Enable RLS with custom policies (commented out for development)
-- Uncomment and modify these policies for production use

/*
-- Enable RLS
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- Policy: Allow users to create ratings
CREATE POLICY "Users can create ratings" ON ratings
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- Policy: Allow users to view all ratings
CREATE POLICY "Users can view ratings" ON ratings
    FOR SELECT TO anon, authenticated
    USING (true);

-- Policy: Allow users to update their own ratings
CREATE POLICY "Users can update their own ratings" ON ratings
    FOR UPDATE TO anon, authenticated
    USING (rater_id = auth.uid()::text::uuid);

-- Policy: Prevent deletion of ratings (optional, for audit trail)
CREATE POLICY "Prevent rating deletion" ON ratings
    FOR DELETE TO anon, authenticated
    USING (false);
*/
