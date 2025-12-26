-- CLEAN SLATE: Drop ALL existing policies completely
-- Then create simple permissive policies for testing

-- Drop ALL policies from profiles table
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow all authenticated users to read profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow read access to all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow users to update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.profiles;
DROP POLICY IF EXISTS "Enable read for users" ON public.profiles;
DROP POLICY IF EXISTS "Enable update for users" ON public.profiles;
DROP POLICY IF EXISTS "Service role has full access to profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;

-- Drop ALL policies from roles table
DROP POLICY IF EXISTS "Allow all authenticated users to read roles" ON public.roles;
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.roles;
DROP POLICY IF EXISTS "Enable read for all users" ON public.roles;
DROP POLICY IF EXISTS "Service role has full access to roles" ON public.roles;
DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON public.roles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.roles;

-- DISABLE RLS completely for testing
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Verify all policies are gone
SELECT 
    schemaname, 
    tablename, 
    policyname
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles')
ORDER BY tablename, policyname;

-- Should return empty result
