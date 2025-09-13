-- Disable Row Level Security for saved_jobs table to avoid policy conflicts
ALTER TABLE saved_jobs DISABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "saved_jobs_select_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_insert_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_update_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_delete_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_all_policy" ON saved_jobs;

-- Grant necessary permissions to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_jobs TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Grant permissions to anon users as well (if needed for your app)
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_jobs TO anon;

-- Add comments for documentation
COMMENT ON TABLE saved_jobs IS 'Stores jobs that helpers have saved/bookmarked for later viewing - RLS disabled for app-level authorization';

-- Note: RLS is disabled for this table. Authorization is handled at the application level.
-- If you need to re-enable RLS later, uncomment the following section:

-- ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "saved_jobs_all_policy" ON saved_jobs FOR ALL USING (true) WITH CHECK (true);
