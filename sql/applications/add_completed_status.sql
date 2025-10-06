-- Migration to add 'completed' status to applications table
-- This is needed so applications can be marked as completed when jobs finish
-- allowing users to rate each other

-- Drop the old constraint
ALTER TABLE applications 
DROP CONSTRAINT IF EXISTS applications_status_check;

-- Add new constraint with 'completed' status included
ALTER TABLE applications 
ADD CONSTRAINT applications_status_check 
CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn', 'completed'));

-- Verify the constraint was updated
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'applications'::regclass 
  AND conname = 'applications_status_check';

-- Show current status distribution
SELECT status, COUNT(*) as count
FROM applications
GROUP BY status
ORDER BY count DESC;

