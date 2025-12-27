-- Task 3: Fix RLS Policies for Profiles Table
-- This ensures authenticated users can read their own profile

-- Step 1: Disable RLS temporarily to clean up
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies on profiles
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename = 'profiles'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', policy_record.policyname);
    END LOOP;
END $$;

-- Step 3: Create simple, permissive policies

-- Policy 1: Authenticated users can view their own profile
CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Policy 2: Authenticated users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy 3: Service role has full access (for admin operations)
CREATE POLICY "Service role has full access"
ON public.profiles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Policy 4: Allow profile creation during registration
CREATE POLICY "Enable insert for authenticated users"
ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Step 4: Re-enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Step 5: Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;

-- Step 6: Fix roles table RLS
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view roles" ON public.roles;

CREATE POLICY "Authenticated users can view roles"
ON public.roles
FOR SELECT
TO authenticated
USING (true);

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.roles TO authenticated;
GRANT ALL ON public.roles TO service_role;

-- Verification queries
-- Check RLS status
SELECT 
    schemaname,
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'roles')
ORDER BY tablename;

-- Check policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles')
ORDER BY tablename, policyname;
