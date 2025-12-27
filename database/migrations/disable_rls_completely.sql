-- COMPLETELY DISABLE RLS FOR TESTING
-- Run this to bypass RLS issues during development

-- Disable RLS on profiles table
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Disable RLS on roles table  
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Drop ALL policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.profiles;
DROP POLICY IF EXISTS "Service role has full access" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.roles;

-- Grant full access to authenticated users (for testing)
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.roles TO authenticated;
GRANT ALL ON public.profiles TO anon;
GRANT ALL ON public.roles TO anon;

-- Verify RLS is disabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'roles');

-- Verify no policies exist
SELECT COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles');
