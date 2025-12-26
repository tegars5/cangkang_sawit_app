-- ============================================================================
-- RESET ALL USERS, ROLES, PROFILES, AND RELATED DATA
-- Date: 2025-12-26
-- WARNING: This will DELETE ALL EXISTING DATA!
-- ============================================================================

BEGIN;

-- ============================================================================
-- STEP 1: Delete all dependent data first (to avoid foreign key violations)
-- ============================================================================

DO $$
BEGIN
  -- Delete tasks (depends on driver_id and order_id)
  DELETE FROM public.tasks WHERE TRUE;
  RAISE NOTICE '✓ Deleted all tasks';

  -- Delete shipment_timeline (depends on shipment_id)
  DELETE FROM public.shipment_timeline WHERE TRUE;
  RAISE NOTICE '✓ Deleted all shipment timeline entries';

  -- Delete driver_locations (depends on driver_id and shipment_id)
  DELETE FROM public.driver_locations WHERE TRUE;
  RAISE NOTICE '✓ Deleted all driver locations';

  -- Delete driver_performance (depends on driver_id)
  DELETE FROM public.driver_performance WHERE TRUE;
  RAISE NOTICE '✓ Deleted all driver performance records';

  -- Delete deliveries (depends on driver_id and shipment_id)
  DELETE FROM public.deliveries WHERE TRUE;
  RAISE NOTICE '✓ Deleted all deliveries';

  -- Delete shipments (depends on driver_id and order_id)
  DELETE FROM public.shipments WHERE TRUE;
  RAISE NOTICE '✓ Deleted all shipments';

  -- Delete notifications (depends on user_id)
  DELETE FROM public.notifications WHERE TRUE;
  RAISE NOTICE '✓ Deleted all notifications';

  -- Delete order_details (depends on order_id and product_id)
  DELETE FROM public.order_details WHERE TRUE;
  RAISE NOTICE '✓ Deleted all order details';

  -- Delete orders (depends on customer_id)
  DELETE FROM public.orders WHERE TRUE;
  RAISE NOTICE '✓ Deleted all orders';
END $$;

-- ============================================================================
-- STEP 2: Delete all profiles
-- ============================================================================

DO $$
BEGIN
  DELETE FROM public.profiles WHERE TRUE;
  RAISE NOTICE '✓ Deleted all profiles';
END $$;

-- ============================================================================
-- STEP 3: Delete all users from auth.users
-- ============================================================================

-- Note: This requires service_role or admin privileges
DO $$
DECLARE
  user_record RECORD;
  deleted_count INTEGER := 0;
BEGIN
  FOR user_record IN SELECT id FROM auth.users LOOP
    DELETE FROM auth.users WHERE id = user_record.id;
    deleted_count := deleted_count + 1;
  END LOOP;
  RAISE NOTICE '✓ Deleted % users from auth.users', deleted_count;
END $$;

-- ============================================================================
-- STEP 4: Reset roles table and create correct roles
-- ============================================================================

DO $$
BEGIN
  -- Delete all existing roles
  DELETE FROM public.roles WHERE TRUE;
  RAISE NOTICE '✓ Deleted all roles';

  -- Reset the sequence to start from 1
  ALTER SEQUENCE IF EXISTS roles_id_seq RESTART WITH 1;

  -- Create roles with correct IDs
  INSERT INTO public.roles (id, name, created_at) 
  OVERRIDING SYSTEM VALUE
  VALUES 
    (1, 'Admin', NOW()),
    (2, 'Mitra Bisnis', NOW()),
    (3, 'Driver', NOW());

  RAISE NOTICE '✓ Created roles: Admin (1), Mitra Bisnis (2), Driver (3)';
END $$;

-- ============================================================================
-- STEP 5: Update/Recreate trigger function
-- ============================================================================

-- Drop existing trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Recreate trigger function with correct driver role_id = 3
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  user_role_id INT;
  user_full_name TEXT;
BEGIN
  -- Extract role from metadata (default to 2 = Mitra if not provided)
  user_role_id := COALESCE(
    (NEW.raw_user_meta_data->>'role_id')::INT,
    CASE 
      WHEN NEW.raw_user_meta_data->>'role' = 'Admin' THEN 1
      WHEN NEW.raw_user_meta_data->>'role' = 'admin' THEN 1
      WHEN NEW.raw_user_meta_data->>'role' = 'Driver' THEN 3
      WHEN NEW.raw_user_meta_data->>'role' = 'driver' THEN 3
      WHEN NEW.raw_user_meta_data->>'role' = 'Mitra Bisnis' THEN 2
      WHEN NEW.raw_user_meta_data->>'role' = 'Mitra' THEN 2
      WHEN NEW.raw_user_meta_data->>'role' = 'mitra' THEN 2
      ELSE 2 -- Default to Mitra
    END
  );

  -- Extract full name from metadata
  user_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    split_part(NEW.email, '@', 1) -- Fallback to email username
  );

  -- Insert profile (use ON CONFLICT to handle race conditions)
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role_id,
    is_active,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    user_full_name,
    user_role_id,
    true,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role_id = EXCLUDED.role_id,
    updated_at = NOW();

  RETURN NEW;
END;
$$;

-- Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DO $$
BEGIN
  RAISE NOTICE '✓ Trigger function updated';
END $$;

-- ============================================================================
-- STEP 6: Verification
-- ============================================================================

-- Count remaining data
DO $$
DECLARE
  user_count INTEGER;
  profile_count INTEGER;
  role_count INTEGER;
  order_count INTEGER;
  shipment_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  SELECT COUNT(*) INTO role_count FROM public.roles;
  SELECT COUNT(*) INTO order_count FROM public.orders;
  SELECT COUNT(*) INTO shipment_count FROM public.shipments;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'VERIFICATION RESULTS:';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Users in auth.users: %', user_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  RAISE NOTICE 'Roles: %', role_count;
  RAISE NOTICE 'Orders: %', order_count;
  RAISE NOTICE 'Shipments: %', shipment_count;
  RAISE NOTICE '==============================================';
END $$;

-- Show roles table
SELECT 
  '📋 Roles Table' AS info,
  id,
  name,
  created_at
FROM public.roles
ORDER BY id;

-- ============================================================================
-- COMMIT TRANSACTION
-- ============================================================================

COMMIT;

-- ============================================================================
-- SUCCESS MESSAGES
-- ============================================================================

SELECT '✅ ALL DATA RESET SUCCESSFULLY!' AS status;
SELECT '✅ All users deleted from auth.users' AS users;
SELECT '✅ All profiles deleted' AS profiles;
SELECT '✅ All orders, shipments, and related data deleted' AS data;
SELECT '✅ Roles recreated: Admin (1), Mitra Bisnis (2), Driver (3)' AS roles;
SELECT '✅ Trigger function updated for new user registration' AS trigger_info;
SELECT '⚠️  You can now create new users via Supabase Auth' AS next_step;
