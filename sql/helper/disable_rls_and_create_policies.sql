-- Disable Row Level Security (RLS) on helpers table for direct access without authentication
-- This allows the anon key to access the table directly

-- Disable RLS on helpers table
ALTER TABLE helpers DISABLE ROW LEVEL SECURITY;

-- Alternative: If you prefer to keep RLS enabled but allow anonymous access,
-- you can uncomment the following lines instead of disabling RLS:

-- Enable RLS (if you prefer to use policies instead of disabling RLS)
-- ALTER TABLE helpers ENABLE ROW LEVEL SECURITY;

-- Create policy to allow anonymous read access for login/registration checks
-- CREATE POLICY "Allow anonymous read access for auth" ON helpers
--   FOR SELECT USING (true);

-- Create policy to allow anonymous insert for registration
-- CREATE POLICY "Allow anonymous insert for registration" ON helpers
--   FOR INSERT WITH CHECK (true);

-- Create policy to allow anonymous update (for profile updates)
-- CREATE POLICY "Allow anonymous update" ON helpers
--   FOR UPDATE USING (true) WITH CHECK (true);

-- Note: The above policies are very permissive and should only be used 
-- for development. For production, consider more restrictive policies.
