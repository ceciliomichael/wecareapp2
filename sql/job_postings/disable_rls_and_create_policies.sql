-- Disable Row Level Security for job_postings table
-- This allows direct access with the anon key without Supabase Auth
ALTER TABLE job_postings DISABLE ROW LEVEL SECURITY;

-- Optional: If you want to enable RLS in the future with custom policies,
-- uncomment the following lines and modify them according to your needs:

-- Enable RLS
-- ALTER TABLE job_postings ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access to all job postings
-- CREATE POLICY "Allow anonymous read access" ON job_postings FOR SELECT USING (true);

-- Allow anonymous insert access to job_postings
-- CREATE POLICY "Allow anonymous insert access" ON job_postings FOR INSERT WITH CHECK (true);

-- Allow anonymous update access to job_postings
-- CREATE POLICY "Allow anonymous update access" ON job_postings FOR UPDATE USING (true);

-- Allow anonymous delete access to job_postings
-- CREATE POLICY "Allow anonymous delete access" ON job_postings FOR DELETE USING (true);
