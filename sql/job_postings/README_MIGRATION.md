# Job Postings Migration Guide

## If you're getting trigger errors, it means your table already exists!

### ✅ **You Already Have job_postings Table**
**DO NOT** run `create_job_postings_table.sql` - this will cause errors!

**Instead, run ONLY the migration:**
```sql
-- Run this in Supabase SQL Editor
\i sql/job_postings/add_missing_columns.sql
```

### 🆕 **Fresh Installation (No job_postings table yet)**
Run both scripts in order:
```sql
-- 1. Create the table
\i sql/job_postings/create_job_postings_table.sql

-- 2. Configure security
\i sql/job_postings/disable_rls_and_create_policies.sql
```

## Error Troubleshooting

### `ERROR: 42710: trigger already exists`
- **Cause**: You already have the job_postings table
- **Solution**: Run **ONLY** the migration script: `add_missing_columns.sql`

### `ERROR: relation "job_postings" does not exist`
- **Cause**: Table doesn't exist yet
- **Solution**: Run the full table creation script first

## Verification

After running the migration, verify your table has all columns:
```sql
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'job_postings' 
ORDER BY ordinal_position;
```

Expected columns:
- id (uuid)
- employer_id (uuid) 
- title (character varying)
- description (text)
- salary (numeric)
- payment_frequency (character varying)
- barangay (character varying)
- required_skills (ARRAY)
- status (character varying)
- applications_count (integer) ← **NEW**
- assigned_helper_id (uuid) ← **NEW**
- assigned_helper_name (character varying) ← **NEW**
- created_at (timestamp with time zone)
- updated_at (timestamp with time zone)
