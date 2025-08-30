-- Disable Row Level Security for applications table
-- This allows direct access with the anon key without Supabase Auth
ALTER TABLE applications DISABLE ROW LEVEL SECURITY;

-- Optional: If you want to enable RLS in the future with custom policies,
-- uncomment the following lines and modify them according to your needs:

-- Enable RLS
-- ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access to all applications
-- CREATE POLICY "Allow anonymous read access" ON applications FOR SELECT USING (true);

-- Allow anonymous insert access to applications
-- CREATE POLICY "Allow anonymous insert access" ON applications FOR INSERT WITH CHECK (true);

-- Allow anonymous update access to applications
-- CREATE POLICY "Allow anonymous update access" ON applications FOR UPDATE USING (true);

-- Allow anonymous delete access to applications
-- CREATE POLICY "Allow anonymous delete access" ON applications FOR DELETE USING (true);
