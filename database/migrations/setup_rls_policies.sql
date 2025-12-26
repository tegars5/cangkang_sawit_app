-- ============================================================================
-- Setup RLS Policies for Authentication
-- Date: 2025-12-26
-- Purpose: Enable RLS and create policies for profiles and roles tables
-- ============================================================================

BEGIN;

-- ============================================================================
-- PROFILES TABLE POLICIES
-- ============================================================================

-- Enable RLS on profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Service role has full access to profiles" ON public.profiles;

-- Policy: Users can read their own profile
CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy: Service role can do anything (for admin operations)
CREATE POLICY "Service role has full access to profiles"
ON public.profiles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- ============================================================================
-- ROLES TABLE POLICIES
-- ============================================================================

-- Enable RLS on roles table
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.roles;
DROP POLICY IF EXISTS "Service role has full access to roles" ON public.roles;

-- Policy: Anyone authenticated can read roles (for login)
CREATE POLICY "Authenticated users can view roles"
ON public.roles
FOR SELECT
TO authenticated
USING (true);

-- Policy: Only service role can modify roles
CREATE POLICY "Service role has full access to roles"
ON public.roles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show enabled RLS tables
SELECT 
  schemaname, 
  tablename, 
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'roles');

-- Show policies
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

COMMIT;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

SELECT '✅ RLS policies created successfully!' AS status;
SELECT '✅ Profiles table: Users can view/update own profile' AS profiles_policy;
SELECT '✅ Roles table: All authenticated users can read' AS roles_policy;
SELECT '⚠️  Now you can login with email/password!' AS next_step;
