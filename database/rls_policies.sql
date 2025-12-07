-- =====================================================
-- Row Level Security (RLS) Policies
-- Cangkang Sawit App
-- =====================================================
-- Run this in Supabase SQL Editor to enable RLS
-- =====================================================

-- =====================================================
-- 1. ENABLE RLS on all tables
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. PROFILES - Everyone can read, users can update own
-- =====================================================
-- Allow users to read all profiles (needed for customer info in orders)
CREATE POLICY "Allow read access to all profiles"
ON public.profiles FOR SELECT
USING (true);

-- Allow users to update their own profile
CREATE POLICY "Allow users to update own profile"
ON public.profiles FOR UPDATE
USING (auth.uid() = id);

-- Allow users to insert their own profile (for registration)
CREATE POLICY "Allow users to insert own profile"
ON public.profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- =====================================================
-- 3. PRODUCTS - Everyone can read, Admin can manage
-- =====================================================
-- Allow everyone to read active products
CREATE POLICY "Allow read access to products"
ON public.products FOR SELECT
USING (true);

-- Allow admin to insert products
CREATE POLICY "Allow admin to insert products"
ON public.products FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1  -- role_id 1 = admin
  )
);

-- Allow admin to update products
CREATE POLICY "Allow admin to update products"
ON public.products FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- Allow admin to delete products
CREATE POLICY "Allow admin to delete products"
ON public.products FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- =====================================================
-- 4. ORDERS - Mitra can CRUD own, Admin can see all
-- =====================================================
-- Mitra can read their own orders, Admin can read all
CREATE POLICY "Allow users to read orders"
ON public.orders FOR SELECT
USING (
  auth.uid() = customer_id  -- Mitra sees own orders
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1  -- Admin sees all
  )
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 3  -- Driver sees assigned orders
  )
);

-- Mitra can create orders
CREATE POLICY "Allow mitra to create orders"
ON public.orders FOR INSERT
WITH CHECK (
  auth.uid() = customer_id  -- Can only create order for themselves
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 2  -- role_id 2 = mitra
  )
);

-- Admin can update orders (confirm, cancel, etc)
CREATE POLICY "Allow admin to update orders"
ON public.orders FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- Admin can delete orders
CREATE POLICY "Allow admin to delete orders"
ON public.orders FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- =====================================================
-- 5. ORDER_DETAILS - Follow parent order permissions
-- =====================================================
-- Read order details if can read parent order
CREATE POLICY "Allow users to read order details"
ON public.order_details FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id
    AND (
      customer_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role_id IN (1, 3)  -- Admin or Driver
      )
    )
  )
);

-- Mitra can insert order details when creating order
CREATE POLICY "Allow mitra to insert order details"
ON public.order_details FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id AND customer_id = auth.uid()
  )
);

-- Admin can update order details
CREATE POLICY "Allow admin to update order details"
ON public.order_details FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- Admin can delete order details
CREATE POLICY "Allow admin to delete order details"
ON public.order_details FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- =====================================================
-- 6. SHIPMENTS - Admin creates, Driver updates
-- =====================================================
-- Admin and Driver can read shipments
CREATE POLICY "Allow read access to shipments"
ON public.shipments FOR SELECT
USING (
  auth.uid() = driver_id  -- Driver sees assigned shipments
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1  -- Admin sees all
  )
  OR EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = order_id AND customer_id = auth.uid()  -- Mitra sees shipments for their orders
  )
);

-- Admin can create shipments
CREATE POLICY "Allow admin to create shipments"
ON public.shipments FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

-- Admin and Driver can update shipments
CREATE POLICY "Allow admin and driver to update shipments"
ON public.shipments FOR UPDATE
USING (
  auth.uid() = driver_id  -- Driver can update assigned shipment
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1  -- Admin can update any
  )
);

-- =====================================================
-- 7. DELIVERIES - Driver manages
-- =====================================================
CREATE POLICY "Allow read access to deliveries"
ON public.deliveries FOR SELECT
USING (
  auth.uid() = driver_id
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

CREATE POLICY "Allow driver to create deliveries"
ON public.deliveries FOR INSERT
WITH CHECK (auth.uid() = driver_id);

CREATE POLICY "Allow driver to update deliveries"
ON public.deliveries FOR UPDATE
USING (auth.uid() = driver_id);

-- =====================================================
-- 8. DRIVER_LOCATIONS - Driver updates own location
-- =====================================================
CREATE POLICY "Allow read driver locations"
ON public.driver_locations FOR SELECT
USING (
  auth.uid() = driver_id
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role_id = 1
  )
);

CREATE POLICY "Allow driver to insert location"
ON public.driver_locations FOR INSERT
WITH CHECK (auth.uid() = driver_id);

CREATE POLICY "Allow driver to update location"
ON public.driver_locations FOR UPDATE
USING (auth.uid() = driver_id);

-- =====================================================
-- 9. NOTIFICATIONS - Users see own notifications
-- =====================================================
CREATE POLICY "Allow users to read own notifications"
ON public.notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Allow insert notifications"
ON public.notifications FOR INSERT
WITH CHECK (true);  -- System can create notifications

CREATE POLICY "Allow users to update own notifications"
ON public.notifications FOR UPDATE
USING (auth.uid() = user_id);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Check existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
