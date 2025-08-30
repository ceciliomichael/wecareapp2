-- Create employer table for storing employer credentials and information
CREATE TABLE IF NOT EXISTS employers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    barangay VARCHAR(100) NOT NULL,
    barangay_clearance_base64 TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_employers_email ON employers(email);

-- Create index on phone for faster lookups  
CREATE INDEX IF NOT EXISTS idx_employers_phone ON employers(phone);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_employers_updated_at 
    BEFORE UPDATE ON employers 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
