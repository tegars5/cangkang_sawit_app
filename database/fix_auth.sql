-- =====================================================
-- Complete Auth System Fix - SQL Scripts
-- =====================================================
-- Run these scripts in Supabase SQL Editor
-- =====================================================

-- 1. Ensure roles table has correct data
-- =====================================================
-- Note: roles table only has id and name columns
INSERT INTO public.roles (id, name) VALUES
(1, 'Admin'),
(2, 'Mitra Bisnis'),
(3, 'Driver')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name;

-- 2. Fix profiles table constraints and defaults
-- =====================================================
-- Add default values to prevent null errors
ALTER TABLE public.profiles
  ALTER COLUMN full_name SET DEFAULT 'User',
  ALTER COLUMN is_active SET DEFAULT true,
  ALTER COLUMN created_at SET DEFAULT now();

-- Ensure email is unique (if not already)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'profiles_email_unique'
  ) THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_email_unique UNIQUE (email);
  END IF;
END $$;

-- 3. Create admin user safely (no duplicates)
-- =====================================================
-- First, check if admin exists in auth.users
-- If not, you need to create via Supabase Auth API or Dashboard
-- This script only creates the profile if auth user exists

DO $$
DECLARE
  admin_user_id uuid;
BEGIN
  -- Get admin user ID from auth.users
  SELECT id INTO admin_user_id
  FROM auth.users
  WHERE email = 'admin@gmail.com';

  -- If admin exists in auth, ensure profile exists
  IF admin_user_id IS NOT NULL THEN
    INSERT INTO public.profiles (id, email, full_name, role_id, phone, is_active, created_at)
    VALUES (
      admin_user_id,
      'admin@gmail.com',
      'Administrator',
      1,
      '08123456789',
      true,
      now()
    )
    ON CONFLICT (id) DO UPDATE SET
      role_id = 1,
      full_name = 'Administrator',
      is_active = true,
      email = 'admin@gmail.com';
  ELSE
    RAISE NOTICE 'Admin user not found in auth.users. Please create via Supabase Dashboard first.';
  END IF;
END $$;

-- 4. Clean up any orphaned profiles (optional)
-- =====================================================
-- Remove profiles that don't have corresponding auth users
-- CAUTION: Only run if you're sure about this
-- DELETE FROM public.profiles
-- WHERE id NOT IN (SELECT id FROM auth.users);

-- 5. Verify data
-- =====================================================
-- Check roles
SELECT * FROM public.roles ORDER BY id;

-- Check admin profile
SELECT p.*, r.name as role_name
FROM public.profiles p
LEFT JOIN public.roles r ON p.role_id = r.id
WHERE p.email = 'admin@gmail.com';

-- Check all profiles
SELECT p.id, p.email, p.full_name, r.name as role_name, p.is_active
FROM public.profiles p
LEFT JOIN public.roles r ON p.role_id = r.id
ORDER BY p.created_at DESC
LIMIT 10;

-- =====================================================
-- MANUAL STEPS (if admin doesn't exist):
-- =====================================================
-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add User" → "Create new user"
-- 3. Email: admin@gmail.com
-- 4. Password: password123
-- 5. Auto Confirm User: YES
-- 6. Then run the script above again to create profile
-- =====================================================
