-- FIX EXISTING USERS - Create profiles for users that don't have one yet
-- Run this after master_setup_complete.sql

-- =============================================================================
-- Create profiles for existing users without profiles
-- =============================================================================

INSERT INTO public.profiles (id, email, full_name, role_id, is_active, created_at, updated_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', 'User') as full_name,
  CASE 
    WHEN u.email LIKE '%admin%' THEN 1
    WHEN u.email LIKE '%driver%' THEN 3
    ELSE 2
  END as role_id,
  true as is_active,
  NOW() as created_at,
  NOW() as updated_at
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL;

-- Verify profiles created
SELECT 
  u.email,
  p.id,
  p.role_id,
  r.name as role_name
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
LEFT JOIN public.roles r ON p.role_id = r.id
ORDER BY u.email;
