-- Disable RLS for helper_service_postings table (for development)
ALTER TABLE helper_service_postings DISABLE ROW LEVEL SECURITY;

-- Note: In production, you should enable RLS and create appropriate policies
-- ALTER TABLE helper_service_postings ENABLE ROW LEVEL SECURITY;

-- Example policies for production use (commented out for development):

-- Policy for helpers to manage their own service postings
-- CREATE POLICY "Helpers can manage their own service postings" ON helper_service_postings
--     FOR ALL USING (helper_id = auth.uid());

-- Policy for public to view active service postings
-- CREATE POLICY "Public can view active service postings" ON helper_service_postings
--     FOR SELECT USING (status = 'active');

-- Policy for employers to view active service postings
-- CREATE POLICY "Employers can view active service postings" ON helper_service_postings
--     FOR SELECT USING (status = 'active');

-- Note: Remember to enable RLS and adjust policies based on your authentication setup
-- when deploying to production
