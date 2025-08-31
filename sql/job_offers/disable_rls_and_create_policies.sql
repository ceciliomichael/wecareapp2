-- Disable RLS for development (enable in production)
ALTER TABLE job_offers DISABLE ROW LEVEL SECURITY;

-- Grant permissions for development
GRANT ALL ON job_offers TO anon;
GRANT ALL ON job_offers TO authenticated;

-- Production RLS Policies (commented out for development)
/*
-- Enable RLS
ALTER TABLE job_offers ENABLE ROW LEVEL SECURITY;

-- Allow employers to create job offers
CREATE POLICY "Employers can create job offers" ON job_offers
    FOR INSERT WITH CHECK (auth.uid() = employer_id);

-- Allow helpers to view job offers sent to them
CREATE POLICY "Helpers can view their job offers" ON job_offers
    FOR SELECT USING (auth.uid() = helper_id);

-- Allow employers to view job offers they sent
CREATE POLICY "Employers can view their job offers" ON job_offers
    FOR SELECT USING (auth.uid() = employer_id);

-- Allow helpers to update job offers sent to them (accept/reject)
CREATE POLICY "Helpers can respond to job offers" ON job_offers
    FOR UPDATE USING (auth.uid() = helper_id);

-- Allow employers to update their job offers (if still pending)
CREATE POLICY "Employers can update pending job offers" ON job_offers
    FOR UPDATE USING (auth.uid() = employer_id AND status = 'pending');
*/
