-- Fix script to update applications status when jobs are completed
-- This ensures users can rate each other after completing jobs

-- Update applications to 'completed' status where:
-- 1. The application was accepted
-- 2. The job posting is now completed
-- 3. But the application status wasn't updated
UPDATE applications
SET status = 'completed'
WHERE status = 'accepted'
  AND job_posting_id IN (
    SELECT id 
    FROM job_postings 
    WHERE status = 'completed'
  );

-- Verify the fix
SELECT 
    a.id as application_id,
    a.status as application_status,
    jp.id as job_id,
    jp.title as job_title,
    jp.status as job_status,
    h.first_name || ' ' || h.last_name as helper_name
FROM applications a
JOIN job_postings jp ON a.job_posting_id = jp.id
JOIN helpers h ON a.helper_id = h.id
WHERE jp.status = 'completed'
ORDER BY jp.updated_at DESC;

