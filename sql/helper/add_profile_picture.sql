-- Add profile picture support to helpers table
ALTER TABLE helpers 
ADD COLUMN IF NOT EXISTS profile_picture_base64 TEXT;

-- Add comment for the new column
COMMENT ON COLUMN helpers.profile_picture_base64 IS 'Base64 encoded profile picture data for the helper';

-- Create index for profile picture lookups (optional - for faster filtering of users with/without pictures)
CREATE INDEX IF NOT EXISTS idx_helpers_has_profile_picture ON helpers(profile_picture_base64) 
WHERE profile_picture_base64 IS NOT NULL;
