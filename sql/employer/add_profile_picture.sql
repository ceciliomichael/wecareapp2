-- Add profile picture support to employers table
ALTER TABLE employers 
ADD COLUMN IF NOT EXISTS profile_picture_base64 TEXT;

-- Add comment for the new column
COMMENT ON COLUMN employers.profile_picture_base64 IS 'Base64 encoded profile picture data for the employer';

-- Create index for profile picture lookups (optional - for faster filtering of users with/without pictures)
CREATE INDEX IF NOT EXISTS idx_employers_has_profile_picture ON employers(profile_picture_base64) 
WHERE profile_picture_base64 IS NOT NULL;
