-- Create helper_service_postings table
CREATE TABLE helper_service_postings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    helper_id UUID NOT NULL REFERENCES helpers(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    skills TEXT[] NOT NULL DEFAULT '{}',
    experience_level VARCHAR(50) NOT NULL CHECK (experience_level IN ('Entry Level', 'Intermediate', 'Experienced', 'Expert')),
    hourly_rate DECIMAL(10,2) NOT NULL CHECK (hourly_rate > 0),
    availability VARCHAR(50) NOT NULL CHECK (availability IN ('Full-time', 'Part-time', 'Weekends', 'Flexible')),
    service_areas TEXT[] NOT NULL DEFAULT '{}',
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'inactive')),
    views_count INTEGER DEFAULT 0,
    contacts_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create service_views table to track unique views per user
CREATE TABLE service_views (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    service_id UUID NOT NULL REFERENCES helper_service_postings(id) ON DELETE CASCADE,
    viewer_id UUID NOT NULL, -- Can be employer_id or helper_id
    viewer_type VARCHAR(20) NOT NULL CHECK (viewer_type IN ('employer', 'helper')),
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(service_id, viewer_id, viewer_type)
);

-- Create indexes for better performance
CREATE INDEX idx_helper_service_postings_helper_id ON helper_service_postings(helper_id);
CREATE INDEX idx_helper_service_postings_status ON helper_service_postings(status);
CREATE INDEX idx_helper_service_postings_created_at ON helper_service_postings(created_at DESC);
CREATE INDEX idx_helper_service_postings_skills ON helper_service_postings USING GIN (skills);
CREATE INDEX idx_helper_service_postings_service_areas ON helper_service_postings USING GIN (service_areas);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_helper_service_postings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_helper_service_postings_updated_at
    BEFORE UPDATE ON helper_service_postings
    FOR EACH ROW
    EXECUTE FUNCTION update_helper_service_postings_updated_at();

-- Create functions for incrementing views and contacts with unique view tracking
CREATE OR REPLACE FUNCTION increment_service_views(service_id UUID, viewer_id UUID, viewer_type VARCHAR(20))
RETURNS boolean AS $$
DECLARE
    view_recorded boolean := false;
BEGIN
    -- Try to insert a new view record (will fail if already exists due to unique constraint)
    BEGIN
        INSERT INTO service_views (service_id, viewer_id, viewer_type)
        VALUES (service_id, viewer_id, viewer_type);
        
        -- If insert succeeds, increment the views count
        UPDATE helper_service_postings 
        SET views_count = views_count + 1 
        WHERE id = service_id;
        
        view_recorded := true;
    EXCEPTION 
        WHEN unique_violation THEN
            -- View already recorded for this user, do nothing
            view_recorded := false;
    END;
    
    RETURN view_recorded;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_service_contacts(service_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE helper_service_postings 
    SET contacts_count = contacts_count + 1 
    WHERE id = service_id;
END;
$$ LANGUAGE plpgsql;
