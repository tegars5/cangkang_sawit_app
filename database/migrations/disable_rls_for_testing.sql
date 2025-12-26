-- TEMPORARY: Disable RLS for testing login
-- This will allow all authenticated users to read profiles
-- WARNING: Only use this for development/testing

-- Drop all existing policies on profiles
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Service role can do everything" ON public.profiles;

-- Create permissive policy for all authenticated users
CREATE POLICY "Allow all authenticated users to read profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (true);  -- Allow reading ALL profiles

CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Ensure RLS is enabled but with permissive policy
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop and recreate roles policies
DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON public.roles;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.roles;

CREATE POLICY "Allow all authenticated users to read roles"
ON public.roles
FOR SELECT
TO authenticated
USING (true);

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.roles TO authenticated;
GRANT UPDATE ON public.profiles TO authenticated;

-- Verify the changes
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles')
ORDER BY tablename, policyname;
