-- ================================================
-- SKEMA DATABASE APLIKASI CANGKANG SAWIT
-- PT. Fujiyama Biomass Energy
-- ================================================

-- 1. Tabel Roles (Peran Pengguna)
CREATE TABLE public.roles (
    role_id smallint PRIMARY KEY,
    nama_peran varchar(50) NOT NULL UNIQUE
);

-- Insert data default roles
INSERT INTO public.roles (role_id, nama_peran) VALUES
(1, 'Admin'),
(2, 'Mitra Bisnis'),
(3, 'Logistik');

-- 2. Tabel Profiles (Profil Pengguna)
CREATE TABLE public.profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nama_lengkap varchar(255) NOT NULL,
    role_id smallint NOT NULL REFERENCES public.roles(role_id),
    telepon varchar(20),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 3. Tabel Products (Produk/Master Data)
CREATE TABLE public.products (
    product_id serial PRIMARY KEY,
    nama_produk varchar(255) NOT NULL,
    harga numeric(15,2) NOT NULL CHECK (harga > 0),
    satuan varchar(20) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Insert data default products
INSERT INTO public.products (nama_produk, harga, satuan) VALUES
('Cangkang Kelapa Sawit Grade A', 850000, 'Ton'),
('Cangkang Kelapa Sawit Grade B', 750000, 'Ton'),
('Cangkang Kelapa Sawit Grade C', 650000, 'Ton');

-- 4. Tabel Orders (Pesanan)
CREATE TABLE public.orders (
    order_id serial PRIMARY KEY,
    mitra_bisnis_id uuid NOT NULL REFERENCES public.profiles(user_id),
    nomor_pesanan varchar(50) NOT NULL UNIQUE,
    tanggal_pesan timestamptz DEFAULT now(),
    status_pesanan varchar(20) NOT NULL DEFAULT 'Baru' 
        CHECK (status_pesanan IN ('Baru', 'Dikonfirmasi', 'Dikemas', 'Dikirim', 'Selesai')),
    total_harga numeric(15,2),
    catatan text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 5. Tabel Order Details (Detail Pesanan)
CREATE TABLE public.order_details (
    detail_id serial PRIMARY KEY,
    order_id int NOT NULL REFERENCES public.orders(order_id) ON DELETE CASCADE,
    product_id int NOT NULL REFERENCES public.products(product_id),
    jumlah_dipesan numeric(10,2) NOT NULL CHECK (jumlah_dipesan > 0),
    jumlah_diterima numeric(10,2) DEFAULT 0 CHECK (jumlah_diterima >= 0),
    harga_satuan numeric(15,2) NOT NULL,
    subtotal numeric(15,2) GENERATED ALWAYS AS (jumlah_diterima * harga_satuan) STORED,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 6. Tabel Shipments (Pengiriman)
CREATE TABLE public.shipments (
    shipment_id serial PRIMARY KEY,
    order_id int NOT NULL UNIQUE REFERENCES public.orders(order_id),
    driver_id uuid NOT NULL REFERENCES public.profiles(user_id),
    nomor_surat_jalan varchar(50) NOT NULL UNIQUE,
    url_surat_jalan varchar(500),
    url_bukti_kirim varchar(500),
    tanggal_kirim timestamptz,
    tanggal_tiba timestamptz,
    status_pengiriman varchar(20) NOT NULL DEFAULT 'Menunggu'
        CHECK (status_pengiriman IN ('Menunggu', 'Dalam Perjalanan', 'Tiba')),
    alamat_tujuan text,
    catatan_pengiriman text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 7. Tabel Driver Locations (Lokasi GPS Driver)
CREATE TABLE public.driver_locations (
    location_id bigserial PRIMARY KEY,
    driver_id uuid NOT NULL REFERENCES public.profiles(user_id),
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    timestamp timestamptz DEFAULT now(),
    speed real,
    accuracy real,
    shipment_id int REFERENCES public.shipments(shipment_id)
);

-- ================================================
-- INDEXES untuk performa
-- ================================================

-- Index untuk pencarian yang sering dilakukan
CREATE INDEX idx_profiles_role_id ON public.profiles(role_id);
CREATE INDEX idx_orders_mitra_bisnis_id ON public.orders(mitra_bisnis_id);
CREATE INDEX idx_orders_status ON public.orders(status_pesanan);
CREATE INDEX idx_orders_tanggal ON public.orders(tanggal_pesan);
CREATE INDEX idx_order_details_order_id ON public.order_details(order_id);
CREATE INDEX idx_shipments_driver_id ON public.shipments(driver_id);
CREATE INDEX idx_shipments_status ON public.shipments(status_pengiriman);
CREATE INDEX idx_driver_locations_driver_id ON public.driver_locations(driver_id);
CREATE INDEX idx_driver_locations_timestamp ON public.driver_locations(timestamp);
CREATE INDEX idx_driver_locations_shipment_id ON public.driver_locations(shipment_id);

-- ================================================
-- TRIGGERS untuk updated_at
-- ================================================

-- Fungsi untuk update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger untuk setiap tabel yang memiliki updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_details_updated_at BEFORE UPDATE ON public.order_details
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shipments_updated_at BEFORE UPDATE ON public.shipments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ================================================

-- Enable RLS pada semua tabel
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

-- Policies untuk profiles
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- Admin dapat melihat semua profiles
CREATE POLICY "Admin can view all profiles" ON public.profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 1
        )
    );

-- Policies untuk products
CREATE POLICY "Everyone can view active products" ON public.products
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admin can manage products" ON public.products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 1
        )
    );

-- Policies untuk orders
CREATE POLICY "Mitra can view own orders" ON public.orders
    FOR SELECT USING (mitra_bisnis_id = auth.uid());

CREATE POLICY "Mitra can create orders" ON public.orders
    FOR INSERT WITH CHECK (mitra_bisnis_id = auth.uid());

CREATE POLICY "Admin can view all orders" ON public.orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 1
        )
    );

CREATE POLICY "Admin can update orders" ON public.orders
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 1
        )
    );

-- Policies untuk order_details
CREATE POLICY "Users can view order details if they can view the order" ON public.order_details
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.orders o
            WHERE o.order_id = order_details.order_id
            AND (
                o.mitra_bisnis_id = auth.uid() OR
                EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role_id = 1)
            )
        )
    );

-- Policies untuk shipments
CREATE POLICY "Driver can view assigned shipments" ON public.shipments
    FOR SELECT USING (driver_id = auth.uid());

CREATE POLICY "Driver can update assigned shipments" ON public.shipments
    FOR UPDATE USING (driver_id = auth.uid());

CREATE POLICY "Admin can manage all shipments" ON public.shipments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 1
        )
    );

-- Policies untuk driver_locations
CREATE POLICY "Driver can insert own locations" ON public.driver_locations
    FOR INSERT WITH CHECK (driver_id = auth.uid());

CREATE POLICY "Driver can view own locations" ON public.driver_locations
    FOR SELECT USING (driver_id = auth.uid());

CREATE POLICY "Users can view driver locations for orders they can access" ON public.driver_locations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.shipments s
            JOIN public.orders o ON s.order_id = o.order_id
            WHERE s.driver_id = driver_locations.driver_id
            AND (
                o.mitra_bisnis_id = auth.uid() OR
                EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role_id = 1)
            )
        )
    );

-- ================================================
-- STORAGE BUCKETS SETUP
-- ================================================

-- Bucket untuk Surat Jalan
INSERT INTO storage.buckets (id, name, public) VALUES ('surat-jalan', 'surat-jalan', false);

-- Bucket untuk Bukti Kirim
INSERT INTO storage.buckets (id, name, public) VALUES ('bukti-kirim', 'bukti-kirim', false);

-- Policies untuk storage surat-jalan
CREATE POLICY "Admin can upload surat jalan" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'surat-jalan' AND
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 1
        )
    );

CREATE POLICY "Authenticated users can view surat jalan" ON storage.objects
    FOR SELECT USING (bucket_id = 'surat-jalan' AND auth.role() = 'authenticated');

-- Policies untuk storage bukti-kirim
CREATE POLICY "Driver can upload bukti kirim" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'bukti-kirim' AND
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND role_id = 3
        )
    );

CREATE POLICY "Authenticated users can view bukti kirim" ON storage.objects
    FOR SELECT USING (bucket_id = 'bukti-kirim' AND auth.role() = 'authenticated');

-- ================================================
-- REALTIME PUBLICATION untuk driver_locations
-- ================================================

-- Enable realtime untuk driver_locations
ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.shipments;

COMMIT;