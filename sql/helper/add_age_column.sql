-- Add age column to helpers table
ALTER TABLE helpers 
ADD COLUMN IF NOT EXISTS age INTEGER NOT NULL DEFAULT 18 CHECK (age >= 18);

-- Add comment for the new column
COMMENT ON COLUMN helpers.age IS 'Age of the helper (must be 18 or older)';

-- Create index for age-based queries (optional)
CREATE INDEX IF NOT EXISTS idx_helpers_age ON helpers(age);
