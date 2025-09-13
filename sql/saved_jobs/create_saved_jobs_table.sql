-- Create saved_jobs table
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

-- Add a comment to the table
COMMENT ON TABLE saved_jobs IS 'Stores jobs that helpers have saved/bookmarked for later viewing';
COMMENT ON COLUMN saved_jobs.helper_id IS 'References the helper who saved the job';
COMMENT ON COLUMN saved_jobs.job_posting_id IS 'References the job posting that was saved';
COMMENT ON COLUMN saved_jobs.saved_at IS 'Timestamp when the job was saved';
