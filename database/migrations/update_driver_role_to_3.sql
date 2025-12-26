-- ============================================================================
-- Migration: Update Driver Role ID from 12 to 3
-- Date: 2025-12-26
-- Purpose: Change all driver role references from ID 12 to ID 3
-- ============================================================================

BEGIN;

-- ============================================================================
-- STEP 1: Ensure Driver role with ID 3 exists
-- ============================================================================

-- Create role with ID 3 if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.roles WHERE id = 3) THEN
    INSERT INTO public.roles (id, name, created_at)
    VALUES (3, 'Driver', NOW())
    ON CONFLICT (id) DO NOTHING;
    RAISE NOTICE 'Created Driver role with ID 3';
  ELSE
    RAISE NOTICE 'Driver role with ID 3 already exists';
  END IF;
END $$;

-- ============================================================================
-- STEP 2: Update all profiles with role_id = 12 to role_id = 3
-- ============================================================================

-- First, update all profiles that reference role_id = 12
DO $$
DECLARE
  affected_count INTEGER;
BEGIN
  UPDATE public.profiles 
  SET role_id = 3 
  WHERE role_id = 12;
  
  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RAISE NOTICE 'Updated % profiles from role_id 12 to 3', affected_count;
END $$;

-- ============================================================================
-- STEP 3: Delete old role with ID 12 (now safe after profiles are updated)
-- ============================================================================

-- Delete the old role with ID 12
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.roles WHERE id = 12) THEN
    DELETE FROM public.roles WHERE id = 12;
    RAISE NOTICE 'Deleted old role with ID 12';
  ELSE
    RAISE NOTICE 'No role with ID 12 to delete';
  END IF;
END $$;

-- ============================================================================
-- STEP 4: Update trigger function to use role_id = 3 for drivers
-- ============================================================================

-- Drop existing trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Recreate trigger function with correct driver role_id = 3
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  user_role_id INT;
  user_full_name TEXT;
BEGIN
  -- Extract role from metadata (default to 2 = Mitra if not provided)
  user_role_id := COALESCE(
    (NEW.raw_user_meta_data->>'role_id')::INT,
    CASE 
      WHEN NEW.raw_user_meta_data->>'role' = 'Admin' THEN 1
      WHEN NEW.raw_user_meta_data->>'role' = 'admin' THEN 1
      WHEN NEW.raw_user_meta_data->>'role' = 'Driver' THEN 3
      WHEN NEW.raw_user_meta_data->>'role' = 'driver' THEN 3
      WHEN NEW.raw_user_meta_data->>'role' = 'Mitra Bisnis' THEN 2
      WHEN NEW.raw_user_meta_data->>'role' = 'Mitra' THEN 2
      ELSE 2 -- Default to Mitra
    END
  );

  -- Extract full name from metadata
  user_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    split_part(NEW.email, '@', 1) -- Fallback to email username
  );

  -- Insert profile (use ON CONFLICT to handle race conditions)
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role_id,
    is_active,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    user_full_name,
    user_role_id,
    true,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role_id = EXCLUDED.role_id,
    updated_at = NOW();

  RETURN NEW;
END;
$$;

-- Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- STEP 5: Verification
-- ============================================================================

-- Check roles table
SELECT 
  'Roles Table' AS table_name,
  id,
  name,
  created_at
FROM public.roles
ORDER BY id;

-- Check profiles with driver role
SELECT 
  'Driver Profiles' AS info,
  COUNT(*) AS total_drivers
FROM public.profiles
WHERE role_id = 3;

-- Check if any profiles still have role_id = 12
SELECT 
  'Profiles with old ID' AS info,
  COUNT(*) AS count_with_old_id
FROM public.profiles
WHERE role_id = 12;

-- ============================================================================
-- COMMIT TRANSACTION
-- ============================================================================

COMMIT;

-- Success message
SELECT '✅ Migration completed successfully!' AS status;
SELECT '✅ Driver role ID changed from 12 to 3' AS change;
SELECT '✅ All user profiles updated' AS profiles;
SELECT '✅ Trigger function updated' AS trigger_function;
