-- ===============================================================
-- SIMPLE SQL QUERY: Add Company Columns to Profiles Table  
-- For: Cangkang Sawit Logistik B2B Application
-- Date: November 25, 2025
-- Version: SIMPLE (No Constraints)
-- ===============================================================

-- 1. Add company_name column (Company name like PT/CV)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);

-- 2. Add job_title column (PIC position/title)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS job_title VARCHAR(100);

-- 3. Add latitude column (Warehouse coordinate - Y axis)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;

-- 4. Add longitude column (Warehouse coordinate - X axis)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- ===============================================================
-- VERIFICATION QUERY: Check if columns were added successfully
-- ===============================================================

-- Run this query to verify the new columns exist:
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
  AND column_name IN ('company_name', 'job_title', 'latitude', 'longitude')
ORDER BY ordinal_position;