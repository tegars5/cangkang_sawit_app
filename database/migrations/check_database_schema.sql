-- CHECK DATABASE SCHEMA - Run this to verify database structure
-- This will help diagnose "Database error querying schema" issue

-- =============================================================================
-- 1. CHECK PROFILES TABLE STRUCTURE
-- =============================================================================

SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'profiles'
ORDER BY ordinal_position;

-- =============================================================================
-- 2. CHECK ROLES TABLE STRUCTURE
-- =============================================================================

SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'roles'
ORDER BY ordinal_position;

-- =============================================================================
-- 3. CHECK FOREIGN KEY CONSTRAINTS
-- =============================================================================

SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name IN ('profiles', 'roles')
ORDER BY tc.table_name;

-- =============================================================================
-- 4. CHECK CURRENT DATA IN PROFILES
-- =============================================================================

SELECT 
  id,
  email,
  full_name,
  role_id,
  is_active,
  created_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 10;

-- =============================================================================
-- 5. CHECK ROLES DATA
-- =============================================================================

SELECT * FROM public.roles ORDER BY id;

-- =============================================================================
-- 6. CHECK RLS STATUS
-- =============================================================================

SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles');

-- =============================================================================
-- 7. CHECK ACTIVE POLICIES
-- =============================================================================

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles')
ORDER BY tablename, policyname;

-- =============================================================================
-- 8. CHECK TRIGGERS
-- =============================================================================

SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name = 'on_auth_user_created';

-- =============================================================================
-- 9. CHECK FOR MISSING PROFILES (users without profiles)
-- =============================================================================

SELECT 
  u.id,
  u.email,
  u.created_at as user_created_at,
  p.id as profile_id,
  p.created_at as profile_created_at
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL;

-- =============================================================================
-- 10. VERIFY TEST USERS
-- =============================================================================

SELECT 
  p.email,
  p.full_name,
  p.role_id,
  r.name as role_name,
  p.is_active,
  p.created_at
FROM public.profiles p
LEFT JOIN public.roles r ON p.role_id = r.id
WHERE p.email IN ('admin@gmail.com', 'driver@gmail.com', 'mitra@gmail.com')
ORDER BY p.email;
