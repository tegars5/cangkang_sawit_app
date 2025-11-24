-- ===============================================================
-- SQL QUERY: Add Company Columns to Profiles Table
-- For: Cangkang Sawit Logistik B2B Application
-- Date: November 25, 2025
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
-- OPTIONAL: Add comments to document the new columns
-- ===============================================================

COMMENT ON COLUMN profiles.company_name IS 'Company name (PT/CV) for mitra business partners';
COMMENT ON COLUMN profiles.job_title IS 'Job title/position of PIC (Person in Charge)';
COMMENT ON COLUMN profiles.latitude IS 'Warehouse latitude coordinate (Y-axis) for location mapping';
COMMENT ON COLUMN profiles.longitude IS 'Warehouse longitude coordinate (X-axis) for location mapping';

-- ===============================================================
-- OPTIONAL: Add check constraints for coordinate validation
-- Note: PostgreSQL doesn't support IF NOT EXISTS for constraints
-- ===============================================================

-- Check if latitude constraint exists, if not add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'profiles' AND constraint_name = 'check_latitude_range'
    ) THEN
        ALTER TABLE profiles 
        ADD CONSTRAINT check_latitude_range 
        CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));
    END IF;
END $$;

-- Check if longitude constraint exists, if not add it  
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'profiles' AND constraint_name = 'check_longitude_range'
    ) THEN
        ALTER TABLE profiles 
        ADD CONSTRAINT check_longitude_range 
        CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));
    END IF;
END $$;

-- ===============================================================
-- VERIFICATION QUERY: Check if columns were added successfully
-- ===============================================================

-- Run this query to verify the new columns exist:
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'profiles' 
  AND column_name IN ('company_name', 'job_title', 'latitude', 'longitude')
ORDER BY ordinal_position;

-- ===============================================================
-- SAMPLE DATA UPDATE (OPTIONAL - for testing)
-- ===============================================================

-- Example: Update existing mitra records with sample data
-- UPDATE profiles 
-- SET 
--   company_name = 'PT Sawit Makmur Indonesia',
--   job_title = 'Manager Operasional',
--   latitude = -6.2088,
--   longitude = 106.8456
-- WHERE role = 'mitra' AND email = 'mitra@example.com';

-- ===============================================================
-- ROLLBACK QUERY (if needed - USE WITH CAUTION!)
-- ===============================================================

-- IF YOU NEED TO REMOVE THE COLUMNS (PERMANENT DATA LOSS!):
-- ALTER TABLE profiles DROP COLUMN IF EXISTS company_name;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS job_title;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS latitude;
-- ALTER TABLE profiles DROP COLUMN IF EXISTS longitude;