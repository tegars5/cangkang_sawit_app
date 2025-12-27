    -- ULTIMATE FIX - Complete database setup and verification
    -- Run this script to fix ALL login issues at once

    BEGIN;

    -- =============================================================================
    -- STEP 1: Ensure roles table has correct data
    -- =============================================================================

    TRUNCATE TABLE public.roles RESTART IDENTITY CASCADE;

    INSERT INTO public.roles (id, name, created_at) VALUES 
    (1, 'Admin', NOW()),
    (2, 'Mitra Bisnis', NOW()),
    (3, 'Driver', NOW())
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

    SELECT setval('roles_id_seq', 4, false);

    -- =============================================================================
    -- STEP 2: Completely disable RLS for testing
    -- =============================================================================

    ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

    -- Drop ALL existing policies
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

    -- Grant full access (for development/testing)
    GRANT ALL ON public.profiles TO authenticated, anon;
    GRANT ALL ON public.roles TO authenticated, anon;

    -- =============================================================================
    -- STEP 3: Recreate trigger for auto profile creation
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
    -- Determine role based on email
    IF NEW.email LIKE '%admin%' THEN
        user_role_id := 1;
    ELSIF NEW.email LIKE '%driver%' THEN
        user_role_id := 3;
    ELSE
        user_role_id := 2;
    END IF;

    -- Insert profile (use INSERT with ON CONFLICT to handle race conditions)
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
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
        role_id = COALESCE(EXCLUDED.role_id, profiles.role_id),
        updated_at = NOW();

    RETURN NEW;
    END;
    $$;

    CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

    -- =============================================================================
    -- STEP 4: Fix existing users - create profiles for users without one
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
    WHERE p.id IS NULL
    ON CONFLICT (id) DO NOTHING;

    -- =============================================================================
    -- STEP 5: Update existing profiles to ensure role_id is not null
    -- =============================================================================

    UPDATE public.profiles
    SET role_id = CASE 
    WHEN email LIKE '%admin%' THEN 1
    WHEN email LIKE '%driver%' THEN 3
    ELSE 2
    END,
    updated_at = NOW()
    WHERE role_id IS NULL;

    COMMIT;

    -- =============================================================================
    -- VERIFICATION QUERIES
    -- =============================================================================

    -- Check roles
    SELECT '=== ROLES ===' as section;
    SELECT id, name FROM public.roles ORDER BY id;

    -- Check RLS status
    SELECT '=== RLS STATUS ===' as section;
    SELECT tablename, rowsecurity FROM pg_tables 
    WHERE schemaname = 'public' AND tablename IN ('profiles', 'roles');

    -- Check policies (should be empty for testing)
    SELECT '=== POLICIES (should be 0) ===' as section;
    SELECT COUNT(*) as policy_count FROM pg_policies
    WHERE schemaname = 'public' AND tablename IN ('profiles', 'roles');

    -- Check trigger
    SELECT '=== TRIGGER ===' as section;
    SELECT trigger_name, event_object_table FROM information_schema.triggers
    WHERE trigger_name = 'on_auth_user_created';

    -- Check test users
    SELECT '=== TEST USERS ===' as section;
    SELECT 
    p.email,
    p.full_name,
    p.role_id,
    r.name as role_name,
    p.is_active
    FROM public.profiles p
    LEFT JOIN public.roles r ON p.role_id = r.id
    WHERE p.email IN ('admin@gmail.com', 'driver@gmail.com', 'mitra@gmail.com')
    ORDER BY p.email;

    -- Check for users without profiles
    SELECT '=== USERS WITHOUT PROFILES (should be 0) ===' as section;
    SELECT COUNT(*) as missing_profiles
    FROM auth.users u
    LEFT JOIN public.profiles p ON u.id = p.id
    WHERE p.id IS NULL;

    -- Check profiles table structure
    SELECT '=== PROFILES TABLE COLUMNS ===' as section;
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
    ORDER BY ordinal_position;
