-- Create job_offers table for managing job offers sent through messaging
CREATE TABLE IF NOT EXISTS job_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id TEXT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    employer_id UUID NOT NULL REFERENCES employers(id) ON DELETE CASCADE,
    helper_id UUID NOT NULL REFERENCES helpers(id) ON DELETE CASCADE,
    service_posting_id UUID NOT NULL REFERENCES helper_service_postings(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    payment_frequency TEXT NOT NULL CHECK (payment_frequency IN ('hourly', 'daily', 'weekly', 'monthly', 'one-time')),
    location TEXT NOT NULL,
    required_skills TEXT[] DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_job_offers_conversation_id ON job_offers(conversation_id);
CREATE INDEX IF NOT EXISTS idx_job_offers_employer_id ON job_offers(employer_id);
CREATE INDEX IF NOT EXISTS idx_job_offers_helper_id ON job_offers(helper_id);
CREATE INDEX IF NOT EXISTS idx_job_offers_status ON job_offers(status);
CREATE INDEX IF NOT EXISTS idx_job_offers_created_at ON job_offers(created_at);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_job_offers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_job_offers_updated_at
    BEFORE UPDATE ON job_offers
    FOR EACH ROW
    EXECUTE FUNCTION update_job_offers_updated_at();

-- Function to automatically expire old pending job offers (optional)
CREATE OR REPLACE FUNCTION expire_old_job_offers()
RETURNS void AS $$
BEGIN
    UPDATE job_offers 
    SET status = 'expired', updated_at = NOW()
    WHERE status = 'pending' 
    AND created_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- You can set up a cron job or call this function periodically to expire old offers
