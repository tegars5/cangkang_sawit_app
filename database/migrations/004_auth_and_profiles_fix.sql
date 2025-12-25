-- Migration 004: Auth and Profiles Fix
-- Purpose: Fix user registration flow, profile auto-creation, and RLS policies
-- Date: 2025-12-17

-- ============================================================================
-- 1. DROP AND RECREATE handle_new_user TRIGGER
-- ============================================================================

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create improved trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
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
      WHEN NEW.raw_user_meta_data->>'role' = 'Driver' THEN 12
      WHEN NEW.raw_user_meta_data->>'role' = 'driver' THEN 12
      WHEN NEW.raw_user_meta_data->>'role' = 'Mitra Bisnis' THEN 2
      WHEN NEW.raw_user_meta_data->>'role' = 'Mitra' THEN 2
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
  )
  VALUES (
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
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
    role_id = COALESCE(EXCLUDED.role_id, profiles.role_id),
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- 2. UPDATE RLS POLICIES FOR PROFILES
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.profiles;

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Policy: Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role_id = 1
    )
  );

-- Policy: Users can update own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy: Allow profile creation (for trigger)
CREATE POLICY "Enable insert for authenticated users only"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- 3. UPDATE RLS POLICIES FOR ORDERS
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can create own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;

-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view own orders
CREATE POLICY "Users can view own orders"
  ON public.orders
  FOR SELECT
  TO authenticated
  USING (auth.uid() = customer_id);

-- Policy: Admins can view all orders
CREATE POLICY "Admins can view all orders"
  ON public.orders
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role_id = 1
    )
  );

-- Policy: Users can create orders (customer_id must match auth.uid())
CREATE POLICY "Users can create own orders"
  ON public.orders
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = customer_id);

-- Policy: Users can update own orders
CREATE POLICY "Users can update own orders"
  ON public.orders
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = customer_id)
  WITH CHECK (auth.uid() = customer_id);

-- ============================================================================
-- 4. ADD INDEXES FOR PERFORMANCE
-- ============================================================================

-- Index on profiles.role_id for faster role-based queries
CREATE INDEX IF NOT EXISTS idx_profiles_role_id ON public.profiles(role_id);

-- Index on orders.customer_id for faster user order lookups
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.orders(customer_id);

-- Index on orders.status for filtering
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);

-- ============================================================================
-- 5. VERIFY ROLE MAPPING (OPTIONAL - SKIP IF TABLE STRUCTURE DIFFERENT)
-- ============================================================================

-- This section is optional and will be skipped if roles table doesn't exist
-- or has a different structure. Role mapping is handled in the trigger above.

-- Uncomment and modify the following if you want to ensure roles table has data:
/*
-- First check what columns exist in roles table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'roles' AND table_schema = 'public';

-- Then insert/update based on actual column names
-- Example if columns are: id, name, description
INSERT INTO public.roles (id, name, description)
VALUES 
  (1, 'Admin', 'Administrator with full access'),
  (2, 'Mitra Bisnis', 'Business partner'),
  (12, 'Driver', 'Delivery driver')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description;
*/

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Verify migration
SELECT 'Migration 004 completed successfully' AS status;

-- Show current profiles count by role
SELECT 
  role_id,
  COUNT(*) as user_count
FROM public.profiles
GROUP BY role_id
ORDER BY role_id;
