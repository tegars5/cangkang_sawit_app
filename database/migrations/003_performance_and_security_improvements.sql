-- Migration: Performance and Security Improvements
-- Version: 003
-- Description: Add indexes, RLS policies, triggers, and missing columns

-- ============================================================================
-- 1. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Orders table indexes
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON public.orders(order_date DESC);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);

-- Order details indexes
CREATE INDEX IF NOT EXISTS idx_order_details_order_id ON public.order_details(order_id);
CREATE INDEX IF NOT EXISTS idx_order_details_product_id ON public.order_details(product_id);

-- Shipments indexes
CREATE INDEX IF NOT EXISTS idx_shipments_order_id ON public.shipments(order_id);
CREATE INDEX IF NOT EXISTS idx_shipments_driver_id ON public.shipments(driver_id);
CREATE INDEX IF NOT EXISTS idx_shipments_status ON public.shipments(status);
CREATE INDEX IF NOT EXISTS idx_shipments_created_at ON public.shipments(created_at DESC);

-- Driver locations indexes (CRITICAL for real-time tracking)
CREATE INDEX IF NOT EXISTS idx_driver_locations_driver_id ON public.driver_locations(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_locations_shipment_id ON public.driver_locations(shipment_id);
CREATE INDEX IF NOT EXISTS idx_driver_locations_timestamp ON public.driver_locations(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_driver_locations_active ON public.driver_locations(driver_id, shipment_id, timestamp DESC);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- Profiles indexes
CREATE INDEX IF NOT EXISTS idx_profiles_role_id ON public.profiles(role_id);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- ============================================================================
-- 2. ADD MISSING COLUMNS
-- ============================================================================

-- Orders table: payment and cancellation columns
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_method VARCHAR,
  ADD COLUMN IF NOT EXISTS payment_status VARCHAR DEFAULT 'unpaid',
  ADD COLUMN IF NOT EXISTS payment_date TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- Add CHECK constraint for payment_status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'orders_payment_status_check'
  ) THEN
    ALTER TABLE public.orders
      ADD CONSTRAINT orders_payment_status_check 
      CHECK (payment_status IN ('unpaid', 'partial', 'paid', 'refunded'));
  END IF;
END $$;

-- Shipments table: additional tracking columns
ALTER TABLE public.shipments
  ADD COLUMN IF NOT EXISTS pickup_photo TEXT,
  ADD COLUMN IF NOT EXISTS delivery_photo TEXT,
  ADD COLUMN IF NOT EXISTS signature_url TEXT,
  ADD COLUMN IF NOT EXISTS distance_km NUMERIC,
  ADD COLUMN IF NOT EXISTS fuel_cost NUMERIC;

-- Driver locations table: monitoring columns
ALTER TABLE public.driver_locations
  ADD COLUMN IF NOT EXISTS battery_level INTEGER,
  ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT true;

-- Add CHECK constraint for battery_level
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'driver_locations_battery_check'
  ) THEN
    ALTER TABLE public.driver_locations
      ADD CONSTRAINT driver_locations_battery_check 
      CHECK (battery_level >= 0 AND battery_level <= 100);
  END IF;
END $$;

-- Products table: additional product details
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS image_url TEXT,
  ADD COLUMN IF NOT EXISTS specifications JSONB,
  ADD COLUMN IF NOT EXISTS max_order_quantity INTEGER;

-- ============================================================================
-- 3. CREATE TRIGGERS FOR AUTO-UPDATE
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_shipments_updated_at ON public.shipments;
CREATE TRIGGER update_shipments_updated_at
  BEFORE UPDATE ON public.shipments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_order_details_updated_at ON public.order_details;
CREATE TRIGGER update_order_details_updated_at
  BEFORE UPDATE ON public.order_details
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger to create profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role_id, is_active)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    COALESCE((NEW.raw_user_meta_data->>'role_id')::integer, 2),
    true
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- 4. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipment_timeline ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 5. CREATE RLS POLICIES
-- ============================================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Customers can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;
DROP POLICY IF EXISTS "Customers can create orders" ON public.orders;
DROP POLICY IF EXISTS "Drivers can view assigned shipments" ON public.shipments;
DROP POLICY IF EXISTS "Admins can manage all shipments" ON public.shipments;
DROP POLICY IF EXISTS "Drivers can insert own location" ON public.driver_locations;
DROP POLICY IF EXISTS "Anyone authenticated can view driver locations" ON public.driver_locations;
DROP POLICY IF EXISTS "Anyone can view active products" ON public.products;
DROP POLICY IF EXISTS "Admins can manage products" ON public.products;
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;

-- Profiles policies
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role_id = 1
    )
  );

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Orders policies
CREATE POLICY "Customers can view own orders"
  ON public.orders FOR SELECT
  USING (customer_id = auth.uid());

CREATE POLICY "Admins can view all orders"
  ON public.orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role_id = 1
    )
  );

CREATE POLICY "Customers can create orders"
  ON public.orders FOR INSERT
  WITH CHECK (customer_id = auth.uid());

-- Shipments policies
CREATE POLICY "Drivers can view assigned shipments"
  ON public.shipments FOR SELECT
  USING (driver_id = auth.uid());

CREATE POLICY "Admins can manage all shipments"
  ON public.shipments FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role_id = 1
    )
  );

-- Driver locations policies
CREATE POLICY "Drivers can insert own location"
  ON public.driver_locations FOR INSERT
  WITH CHECK (driver_id = auth.uid());

CREATE POLICY "Anyone authenticated can view driver locations"
  ON public.driver_locations FOR SELECT
  TO authenticated
  USING (true);

-- Products policies
CREATE POLICY "Anyone can view active products"
  ON public.products FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins can manage products"
  ON public.products FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role_id = 1
    )
  );

-- Notifications policies
CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================================================
-- 6. HELPER FUNCTIONS
-- ============================================================================

-- Function to calculate order total
CREATE OR REPLACE FUNCTION calculate_order_total(order_uuid UUID)
RETURNS NUMERIC AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT SUM(subtotal) INTO total
  FROM public.order_details
  WHERE order_id = order_uuid;
  
  RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get active shipments for driver
CREATE OR REPLACE FUNCTION get_driver_active_shipments(driver_uuid UUID)
RETURNS TABLE (
  shipment_id UUID,
  order_number VARCHAR,
  status VARCHAR,
  destination_address TEXT,
  customer_name VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    o.order_number,
    s.status,
    s.destination_address,
    p.full_name
  FROM public.shipments s
  JOIN public.orders o ON s.order_id = o.id
  JOIN public.profiles p ON o.customer_id = p.id
  WHERE s.driver_id = driver_uuid
    AND s.status IN ('pending', 'in_transit')
  ORDER BY s.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. ENABLE REALTIME PUBLICATION
-- ============================================================================

-- Note: Run these commands in Supabase SQL Editor or via API
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_locations;
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.shipments;
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
