-- Setup saved_jobs table and permissions
-- This script combines table creation and permission setup

-- First, create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS saved_jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    helper_id UUID NOT NULL REFERENCES helpers(id) ON DELETE CASCADE,
    job_posting_id UUID NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Ensure a helper can only save a job once
    UNIQUE(helper_id, job_posting_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_saved_jobs_helper_id ON saved_jobs(helper_id);
CREATE INDEX IF NOT EXISTS idx_saved_jobs_job_posting_id ON saved_jobs(job_posting_id);
CREATE INDEX IF NOT EXISTS idx_saved_jobs_saved_at ON saved_jobs(saved_at DESC);
CREATE INDEX IF NOT EXISTS idx_saved_jobs_helper_saved_at ON saved_jobs(helper_id, saved_at DESC);

-- Disable Row Level Security to avoid policy conflicts
ALTER TABLE saved_jobs DISABLE ROW LEVEL SECURITY;

-- Drop any existing policies
DROP POLICY IF EXISTS "saved_jobs_select_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_insert_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_update_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_delete_policy" ON saved_jobs;
DROP POLICY IF EXISTS "saved_jobs_all_policy" ON saved_jobs;

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_jobs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON saved_jobs TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Create a function to cleanup saved jobs for deleted job postings
CREATE OR REPLACE FUNCTION cleanup_saved_jobs_for_deleted_postings()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM saved_jobs 
    WHERE job_posting_id NOT IN (SELECT id FROM job_postings);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION cleanup_saved_jobs_for_deleted_postings() TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_saved_jobs_for_deleted_postings() TO anon;

-- Add comments for documentation
COMMENT ON TABLE saved_jobs IS 'Stores jobs that helpers have saved/bookmarked for later viewing - RLS disabled for app-level authorization';
COMMENT ON COLUMN saved_jobs.helper_id IS 'References the helper who saved the job';
COMMENT ON COLUMN saved_jobs.job_posting_id IS 'References the job posting that was saved';
COMMENT ON COLUMN saved_jobs.saved_at IS 'Timestamp when the job was saved';

-- Log successful setup
SELECT 'saved_jobs table and permissions set up successfully' AS status;
