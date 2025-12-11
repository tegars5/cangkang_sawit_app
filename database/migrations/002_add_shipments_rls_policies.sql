-- Migration: Add RLS Policies for Shipments Table
-- This fixes the "row-level security policy" error when creating shipments

-- Step 1: Enable RLS on shipments table (if not already enabled)
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop existing policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Allow authenticated users to view shipments" ON public.shipments;
DROP POLICY IF EXISTS "Allow authenticated users to insert shipments" ON public.shipments;
DROP POLICY IF EXISTS "Allow authenticated users to update shipments" ON public.shipments;
DROP POLICY IF EXISTS "Allow admin to delete shipments" ON public.shipments;

-- Step 3: Create SELECT policy - All authenticated users can view shipments
CREATE POLICY "Allow authenticated users to view shipments"
ON public.shipments
FOR SELECT
TO authenticated
USING (true);

-- Step 4: Create INSERT policy - Authenticated users can create shipments
-- This allows the app to create shipments when orders are created
CREATE POLICY "Allow authenticated users to insert shipments"
ON public.shipments
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Step 5: Create UPDATE policy - Users can update shipments
-- Admin can update any shipment
-- Drivers can update their own shipments
CREATE POLICY "Allow users to update shipments"
ON public.shipments
FOR UPDATE
TO authenticated
USING (
  -- Admin can update any shipment
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role_id = 1
  )
  OR
  -- Driver can update their own shipments
  (driver_id = auth.uid())
  OR
  -- Allow update if driver_id is NULL (for assignment)
  (driver_id IS NULL)
)
WITH CHECK (
  -- Same conditions for the new row
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role_id = 1
  )
  OR
  (driver_id = auth.uid())
  OR
  (driver_id IS NULL)
);

-- Step 6: Create DELETE policy - Only admin can delete
CREATE POLICY "Allow admin to delete shipments"
ON public.shipments
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role_id = 1
  )
);

-- Add helpful comments
COMMENT ON POLICY "Allow authenticated users to view shipments" ON public.shipments 
IS 'All authenticated users can view shipments';

COMMENT ON POLICY "Allow authenticated users to insert shipments" ON public.shipments 
IS 'Authenticated users can create shipments (needed for order creation)';

COMMENT ON POLICY "Allow users to update shipments" ON public.shipments 
IS 'Admin can update any shipment, drivers can update their own, NULL driver_id can be updated for assignment';

COMMENT ON POLICY "Allow admin to delete shipments" ON public.shipments 
IS 'Only admin (role_id=1) can delete shipments';
