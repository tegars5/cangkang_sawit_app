-- ULTIMATE FIX: Completely disable RLS and grant all permissions
-- Run this in Supabase SQL Editor

-- 1. Disable RLS on all relevant tables
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- 2. Drop ALL existing policies (clean slate)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname, tablename 
              FROM pg_policies 
              WHERE schemaname = 'public' 
                AND tablename IN ('profiles', 'roles'))
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', r.policyname, r.tablename);
    END LOOP;
END $$;

-- 3. Grant full access to authenticated users
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.roles TO authenticated;
GRANT ALL ON public.profiles TO anon;
GRANT ALL ON public.roles TO anon;

-- 4. Verify RLS is disabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'roles');

-- Should show rowsecurity = false for both tables

-- 5. Verify no policies exist
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles');

-- Should return empty (no policies)
