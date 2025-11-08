-- Main System Flows Database Schema
-- Execute this in Supabase SQL Editor

-- ==========================================
-- 1. ORDERS TABLE (Enhanced for Business Flow)
-- ==========================================
DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL, -- Format: ORD/2025/10/001
    customer_id UUID NOT NULL REFERENCES profiles(id), -- Renamed from mitra_id
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Order status for business flow
    status VARCHAR(50) DEFAULT 'pending' CHECK (
        status IN ('pending', 'confirmed', 'shipped', 'completed', 'cancelled')
    ),
    
    -- Total values
    total_quantity DECIMAL(10,2) NOT NULL,
    confirmed_quantity DECIMAL(10,2) DEFAULT 0, -- For partial acceptance
    total_amount DECIMAL(15,2) NOT NULL,
    
    -- Notes
    admin_notes TEXT,
    customer_notes TEXT,
    
    -- Timestamps
    confirmed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 2. PRODUCTS TABLE (Create First - Referenced by order_details)
-- ==========================================
DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_per_kg DECIMAL(10,2) NOT NULL, -- Price per kilogram
    unit VARCHAR(50) DEFAULT 'ton', -- Unit of measure (ton, kg, etc)
    
    -- Stock management
    stock_available DECIMAL(10,2) DEFAULT 0,
    minimum_order DECIMAL(10,2) DEFAULT 1,
    
    -- Additional details
    category VARCHAR(100) NOT NULL DEFAULT 'Palm Shell',
    product_code VARCHAR(100) UNIQUE,
    specifications TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 3. ORDER_DETAILS TABLE (Line Items)
-- ==========================================
DROP TABLE IF EXISTS order_details CASCADE;

CREATE TABLE order_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    
    -- Quantities for business flow
    requested_quantity DECIMAL(10,2) NOT NULL, -- Quantity requested by customer
    confirmed_quantity DECIMAL(10,2) DEFAULT 0, -- Quantity confirmed by admin (partial acceptance)
    
    -- Pricing
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    
    -- Notes per item
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 4. SHIPMENTS TABLE (Enhanced for Delivery Management)
-- ==========================================
DROP TABLE IF EXISTS shipments CASCADE;

CREATE TABLE shipments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id),
    driver_id UUID NOT NULL REFERENCES profiles(id),
    
    -- Delivery note number (manual input by admin)
    delivery_note_number VARCHAR(100) UNIQUE NOT NULL, -- Format: DN/2025/10/001
    
    -- Document URLs
    delivery_note_url TEXT, -- PDF delivery note from Supabase Storage
    proof_of_delivery_url TEXT, -- Photo proof from driver
    
    -- Shipment status for business flow
    status VARCHAR(50) DEFAULT 'pending' CHECK (
        status IN ('pending', 'in_transit', 'arrived', 'completed')
    ),
    
    -- Tracking timestamps
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE, -- When driver starts
    completed_at TIMESTAMP WITH TIME ZONE, -- When driver completes
    
    -- Estimation
    estimated_arrival TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 5. DRIVER_LOCATIONS TABLE (Real-time GPS Tracking)
-- ==========================================
DROP TABLE IF EXISTS driver_locations CASCADE;

CREATE TABLE driver_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES profiles(id),
    shipment_id UUID REFERENCES shipments(id), -- Optional: link ke shipment tertentu
    
    -- GPS coordinates
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    
    -- Location metadata
    accuracy DECIMAL(8,2), -- GPS accuracy in meters
    altitude DECIMAL(8,2), -- Altitude in meters
    speed DECIMAL(8,2), -- Speed in km/h
    heading DECIMAL(6,2), -- Direction in degrees
    
    -- Timestamps
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table sudah dibuat di atas, tidak perlu duplikasi

-- ==========================================
-- 6. CREATE INDEXES FOR PERFORMANCE
-- ==========================================

-- Orders indexes
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Shipments indexes  
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipments_driver ON shipments(driver_id);
CREATE INDEX idx_shipments_order ON shipments(order_id);

-- Driver locations indexes for real-time tracking
CREATE INDEX idx_driver_locations_driver ON driver_locations(driver_id);
CREATE INDEX idx_driver_locations_shipment ON driver_locations(shipment_id);
CREATE INDEX idx_driver_locations_timestamp ON driver_locations(timestamp);

-- Order details indexes
CREATE INDEX idx_order_details_order ON order_details(order_id);
CREATE INDEX idx_order_details_product ON order_details(product_id);

-- Products indexes
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_category ON products(category);

-- ==========================================
-- 7. ENABLE REALTIME FOR GPS TRACKING
-- ==========================================

-- Enable Realtime subscriptions for real-time GPS tracking
ALTER PUBLICATION supabase_realtime ADD TABLE driver_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE shipments;
ALTER PUBLICATION supabase_realtime ADD TABLE orders;

-- ==========================================
-- 8. INSERT SAMPLE PRODUCTS
-- ==========================================

-- Sample products with English column names
INSERT INTO products (product_code, name, category, price_per_kg, unit, stock_available, description, specifications) VALUES
('PS-001', 'Palm Shell Grade A', 'Palm Shell', 350.00, 'ton', 1000.00, 'Premium quality palm shell for biomass', 'Moisture content: <15%, Size: 2-6mm'),
('PS-002', 'Palm Shell Grade B', 'Palm Shell', 320.00, 'ton', 800.00, 'Standard quality palm shell for industry', 'Moisture content: <20%, Size: 2-8mm'),
('PS-003', 'Palm Shell Grade C', 'Palm Shell', 280.00, 'ton', 1200.00, 'Economic grade palm shell', 'Moisture content: <25%, Size: mixed'),
('FB-001', 'Palm Fiber Grade A', 'Fiber', 250.00, 'ton', 500.00, 'Palm fiber for biomass fuel', 'Moisture content: <20%, Fiber length: uniform'),
('KS-001', 'Kernel Shell Premium', 'Kernel', 400.00, 'ton', 300.00, 'Premium palm kernel shell', 'Moisture content: <12%, Size: 4-8mm');

-- ==========================================
-- 9. CREATE STORAGE BUCKETS (Run in Supabase Dashboard > Storage)
-- ==========================================

-- These need to be created in Supabase Dashboard:
-- 1. Bucket: 'delivery-notes' for PDF documents
-- 2. Bucket: 'proof-of-delivery' for delivery photos
-- 3. Set appropriate policies for authenticated users

-- ==========================================
-- 10. VERIFY SCHEMA
-- ==========================================

-- Verify tables created
SELECT 
    table_name, 
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('orders', 'order_details', 'shipments', 'driver_locations', 'products')
ORDER BY table_name;

COMMIT;