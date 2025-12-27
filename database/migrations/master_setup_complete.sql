-- MASTER SETUP SCRIPT - Run this in Supabase SQL Editor
-- This script fixes all login issues mentioned in task.md

-- =============================================================================
-- TASK 1: Fix Roles Table Data
-- =============================================================================

TRUNCATE TABLE public.roles RESTART IDENTITY CASCADE;

INSERT INTO public.roles (id, name) VALUES 
  (1, 'Admin'),
  (2, 'Mitra Bisnis'),
  (3, 'Driver')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

SELECT setval('roles_id_seq', 4, false);

-- =============================================================================
-- TASK 2: Create Auto Profile Creation Trigger
-- =============================================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_role_id INTEGER;
BEGIN
  IF NEW.email LIKE '%admin%' THEN
    user_role_id := 1;
  ELSIF NEW.email LIKE '%driver%' THEN
    user_role_id := 3;
  ELSE
    user_role_id := 2;
  END IF;

  INSERT INTO public.profiles (
    id, email, full_name, role_id, is_active, created_at, updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    user_role_id,
    true,
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- TASK 3: Fix RLS Policies
-- =============================================================================

-- Disable RLS temporarily
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname, tablename
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename IN ('profiles', 'roles')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', 
                      policy_record.policyname, 
                      policy_record.tablename);
    END LOOP;
END $$;

-- Create clean policies for profiles
CREATE POLICY "Users can view own profile"
ON public.profiles FOR SELECT TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE TO authenticated
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users"
ON public.profiles FOR INSERT TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "Service role has full access"
ON public.profiles FOR ALL TO service_role
USING (true) WITH CHECK (true);

-- Create policy for roles
CREATE POLICY "Authenticated users can view roles"
ON public.roles FOR SELECT TO authenticated
USING (true);

-- Re-enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT ON public.roles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
GRANT ALL ON public.roles TO service_role;

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Check roles data
SELECT id, name, created_at FROM public.roles ORDER BY id;

-- Check RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'roles');

-- Check policies
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'roles')
ORDER BY tablename, policyname;

-- Check trigger exists
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- =============================================================================
-- OPTIONAL: Create test users if needed
-- =============================================================================

-- Uncomment below to create test users
-- Note: Replace passwords with bcrypt hashed versions
/*
-- You need to hash passwords first using bcrypt
-- Example: password123 -> $2a$10$...

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token
) VALUES
  (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated', 
    'admin@gmail.com',
    '$2a$10$YOUR_HASHED_PASSWORD_HERE',
    NOW(),
    NOW(),
    NOW(),
    '',
    ''
  );
*/

COMMIT;
