-- Migration: Make driver_id nullable in shipments table
-- This allows shipments to be created without a driver assigned initially
-- Admin can assign driver later

-- Step 1: Drop the NOT NULL constraint on driver_id
ALTER TABLE public.shipments 
ALTER COLUMN driver_id DROP NOT NULL;

-- Step 2: Add 'assigned' status to the CHECK constraint if not already present
ALTER TABLE public.shipments 
DROP CONSTRAINT IF EXISTS shipments_status_check;

ALTER TABLE public.shipments 
ADD CONSTRAINT shipments_status_check 
CHECK (status::text = ANY (ARRAY[
  'pending'::character varying,
  'assigned'::character varying,
  'in_transit'::character varying, 
  'arrived'::character varying,
  'completed'::character varying,
  'cancelled'::character varying
]::text[]));

-- Step 3: Add index on driver_id for better query performance
CREATE INDEX IF NOT EXISTS idx_shipments_driver_id ON public.shipments(driver_id);

-- Step 4: Add index on status for filtering
CREATE INDEX IF NOT EXISTS idx_shipments_status ON public.shipments(status);

-- Step 5: Add index on order_id
CREATE INDEX IF NOT EXISTS idx_shipments_order_id ON public.shipments(order_id);

COMMENT ON COLUMN public.shipments.driver_id IS 'Driver assigned to this shipment. NULL if not yet assigned.';
COMMENT ON COLUMN public.shipments.assigned_at IS 'Timestamp when driver was assigned to shipment';
