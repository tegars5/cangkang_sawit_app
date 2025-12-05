-- =====================================================
-- Sync Profiles with Auth Users
-- =====================================================
-- This script creates profiles for all auth users
-- =====================================================

-- 1. Delete existing profiles that don't match auth users
-- =====================================================
DELETE FROM public.profiles
WHERE id NOT IN (SELECT id FROM auth.users);

-- 2. Insert profiles for all auth users
-- =====================================================
-- Insert profile for admin@fujiyama.com
INSERT INTO public.profiles (id, email, full_name, role_id, phone, is_active, created_at)
SELECT 
  id,
  'admin@fujiyama.com',
  'Administrator System',
  1, -- Admin role
  '08123456789',
  true,
  now()
FROM auth.users
WHERE email = 'admin@fujiyama.com'
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  role_id = EXCLUDED.role_id,
  is_active = EXCLUDED.is_active;

-- Insert profile for driver@fujiyama.com
INSERT INTO public.profiles (id, email, full_name, role_id, phone, is_active, created_at)
SELECT 
  id,
  'driver@fujiyama.com',
  'Driver Logistik',
  3, -- Driver role
  '08123456790',
  true,
  now()
FROM auth.users
WHERE email = 'driver@fujiyama.com'
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  role_id = EXCLUDED.role_id,
  is_active = EXCLUDED.is_active;

-- Insert profile for mitra@fujiyama.com
INSERT INTO public.profiles (id, email, full_name, role_id, phone, is_active, created_at)
SELECT 
  id,
  'mitra@fujiyama.com',
  'Mitra Bisnis Partner',
  2, -- Mitra role
  '08123456791',
  true,
  now()
FROM auth.users
WHERE email = 'mitra@fujiyama.com'
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  role_id = EXCLUDED.role_id,
  is_active = EXCLUDED.is_active;

-- 3. Verify results
-- =====================================================
SELECT 
  p.id,
  p.email,
  p.full_name,
  p.role_id,
  r.name as role_name,
  p.is_active,
  CASE 
    WHEN au.id IS NOT NULL THEN 'YES'
    ELSE 'NO'
  END as has_auth_user
FROM public.profiles p
LEFT JOIN public.roles r ON p.role_id = r.id
LEFT JOIN auth.users au ON p.id = au.id
ORDER BY p.role_id;

-- =====================================================
-- Expected Result:
-- =====================================================
-- Should show 3 profiles:
-- 1. admin@fujiyama.com - Administrator System - Admin - YES
-- 2. mitra@fujiyama.com - Mitra Bisnis Partner - Mitra Bisnis - YES
-- 3. driver@fujiyama.com - Driver Logistik - Driver - YES
-- =====================================================

-- =====================================================
-- TESTING:
-- =====================================================
-- After running this script, you can login with:
-- 
-- Admin:
--   Email: admin@fujiyama.com
--   Password: (your password)
--
-- Mitra:
--   Email: mitra@fujiyama.com
--   Password: (your password)
--
-- Driver:
--   Email: driver@fujiyama.com
--   Password: (your password)
-- =====================================================
