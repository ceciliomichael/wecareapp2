-- Add age column to employers table
ALTER TABLE employers 
ADD COLUMN IF NOT EXISTS age INTEGER NOT NULL DEFAULT 18 CHECK (age >= 18);

-- Add comment for the new column
COMMENT ON COLUMN employers.age IS 'Age of the employer (must be 18 or older)';

-- Create index for age-based queries (optional)
CREATE INDEX IF NOT EXISTS idx_employers_age ON employers(age);
