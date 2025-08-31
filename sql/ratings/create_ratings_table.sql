-- Create ratings table for storing ratings between helpers and employers
CREATE TABLE IF NOT EXISTS ratings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    rater_id UUID NOT NULL, -- ID of the person giving the rating
    rater_type VARCHAR(20) NOT NULL CHECK (rater_type IN ('helper', 'employer')), -- Type of rater
    rated_id UUID NOT NULL, -- ID of the person being rated
    rated_type VARCHAR(20) NOT NULL CHECK (rated_type IN ('helper', 'employer')), -- Type of person being rated
    job_posting_id UUID, -- Optional reference to job posting (if applicable)
    service_posting_id UUID, -- Optional reference to service posting (if applicable)
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Rating from 1 to 5 stars
    review_text TEXT, -- Optional review comment
    is_anonymous BOOLEAN DEFAULT FALSE, -- Whether the rating is anonymous
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one rating per rater-rated pair per engagement
    UNIQUE(rater_id, rated_id, job_posting_id, service_posting_id)
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_ratings_rater_id ON ratings(rater_id);
CREATE INDEX IF NOT EXISTS idx_ratings_rated_id ON ratings(rated_id);
CREATE INDEX IF NOT EXISTS idx_ratings_rater_type ON ratings(rater_type);
CREATE INDEX IF NOT EXISTS idx_ratings_rated_type ON ratings(rated_type);
CREATE INDEX IF NOT EXISTS idx_ratings_job_posting_id ON ratings(job_posting_id);
CREATE INDEX IF NOT EXISTS idx_ratings_service_posting_id ON ratings(service_posting_id);
CREATE INDEX IF NOT EXISTS idx_ratings_rating ON ratings(rating);
CREATE INDEX IF NOT EXISTS idx_ratings_created_at ON ratings(created_at);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_ratings_rated_type_rated_id ON ratings(rated_type, rated_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_ratings_updated_at 
    BEFORE UPDATE ON ratings 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create helper functions for calculating average ratings
CREATE OR REPLACE FUNCTION get_average_rating(user_id UUID, user_type VARCHAR(20))
RETURNS DECIMAL(3,2) AS $$
BEGIN
    RETURN (
        SELECT COALESCE(AVG(rating::DECIMAL), 0.0)
        FROM ratings 
        WHERE rated_id = user_id AND rated_type = user_type
    );
END;
$$ LANGUAGE plpgsql;

-- Create function to get total rating count
CREATE OR REPLACE FUNCTION get_rating_count(user_id UUID, user_type VARCHAR(20))
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM ratings 
        WHERE rated_id = user_id AND rated_type = user_type
    );
END;
$$ LANGUAGE plpgsql;
