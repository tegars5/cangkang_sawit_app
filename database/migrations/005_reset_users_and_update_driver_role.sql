-- Migration 005: Reset Users and Update Driver Role ID
-- Purpose: Clean slate - delete all users and update Driver role_id from 12 to 3
-- Date: 2025-12-17
-- WARNING: This will DELETE ALL existing users and their data!

-- ============================================================================
-- 1. DELETE ALL EXISTING USERS AND RELATED DATA
-- ============================================================================

-- Delete in correct order to avoid foreign key constraint violations

-- Step 1: Delete all orders-related data
DELETE FROM public.order_items WHERE TRUE;  -- If this table exists
DELETE FROM public.shipments WHERE TRUE;    -- If this table exists
DELETE FROM public.orders WHERE TRUE;

-- Step 2: Delete all profiles
DELETE FROM public.profiles WHERE TRUE;

-- Step 3: Delete all users from auth.users
-- Note: This requires SECURITY DEFINER or admin privileges
DO $$
DECLARE
  user_record RECORD;
BEGIN
  FOR user_record IN SELECT id FROM auth.users LOOP
    -- Delete user from auth schema
    DELETE FROM auth.users WHERE id = user_record.id;
  END LOOP;
END $$;

-- Verify deletion
SELECT 'All data deleted' AS status;
SELECT COUNT(*) as remaining_users FROM auth.users;
SELECT COUNT(*) as remaining_profiles FROM public.profiles;
SELECT COUNT(*) as remaining_orders FROM public.orders;

-- ============================================================================
-- 2. UPDATE DRIVER ROLE ID FROM 12 TO 3
-- ============================================================================

-- Drop existing trigger to update it
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create updated trigger function with Driver = 3
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
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
      WHEN NEW.raw_user_meta_data->>'role' = 'Driver' THEN 3  -- Changed from 12 to 3
      WHEN NEW.raw_user_meta_data->>'role' = 'driver' THEN 3  -- Changed from 12 to 3
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
  )
  VALUES (
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
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
    role_id = COALESCE(EXCLUDED.role_id, profiles.role_id),
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- 3. CREATE TEST USERS (OPTIONAL)
-- ============================================================================

-- Uncomment the following to create test users with known credentials
-- Note: You'll need to use Supabase Auth API or Dashboard to create users
-- as direct INSERT into auth.users is not recommended

/*
-- Test Admin User
-- Email: admin@test.com
-- Password: admin123
-- Create via Supabase Dashboard or Auth API

-- Test Mitra User  
-- Email: mitra@test.com
-- Password: test123456
-- Create via Supabase Dashboard or Auth API

-- Test Driver User
-- Email: driver@test.com
-- Password: test123456
-- Create via Supabase Dashboard or Auth API
*/

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

SELECT 'Migration 005 completed successfully' AS status;
SELECT 'Driver role_id updated from 12 to 3' AS change;
SELECT 'All users have been deleted - ready for fresh registration' AS note;

-- Show current state
SELECT COUNT(*) as total_users FROM auth.users;
SELECT COUNT(*) as total_profiles FROM public.profiles;
