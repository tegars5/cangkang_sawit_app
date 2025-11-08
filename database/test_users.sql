-- Test Users untuk Login Cangkang Sawit App
-- Jalankan query ini di Supabase SQL Editor untuk membuat test users

-- 1. Insert test roles (jika belum ada)
INSERT INTO public.roles (id, name, description) 
VALUES 
  (1, 'Admin', 'Administrator sistem dengan akses penuh'),
  (2, 'Mitra Bisnis', 'Partner bisnis yang dapat membuat pesanan'),
  (3, 'Logistik', 'Driver untuk pengiriman dan tracking GPS')
ON CONFLICT (id) DO NOTHING;

-- 2. Insert test user profiles (akan dibuat otomatis saat user register via Supabase Auth)
-- Catatan: User auth harus dibuat melalui Supabase Auth terlebih dahulu

-- Untuk membuat test users, jalankan kode Dart berikut di Flutter app atau buat manual di Supabase Auth Dashboard:

/*
Test Users untuk Login:

1. ADMIN USER
   Email: admin@fujiyama.com
   Password: password123
   Role: Admin

2. MITRA BISNIS USER  
   Email: mitra@fujiyama.com
   Password: password123
   Role: Mitra Bisnis

3. DRIVER/LOGISTIK USER
   Email: driver@fujiyama.com  
   Password: password123
   Role: Logistik

CARA MEMBUAT TEST USERS:

Option 1 - Via Supabase Dashboard:
1. Buka Supabase Dashboard: https://supabase.com/dashboard
2. Pilih project Anda
3. Go to Authentication > Users
4. Klik "Add user" 
5. Tambahkan email dan password sesuai list di atas
6. Setelah user dibuat, jalankan query SQL di bawah untuk assign role

Option 2 - Via SQL (recommended):
Gunakan query di bawah untuk create users dan assign roles sekaligus
*/

-- 3. Assign roles ke users (jalankan setelah users dibuat)
-- Replace 'user-uuid-here' dengan actual UUID dari Supabase Auth

-- Contoh update profiles setelah user auth dibuat:
-- UPDATE auth.users SET raw_user_meta_data = '{"role": "admin"}' 
-- WHERE email = 'admin@fujiyama.com';

-- INSERT INTO public.profiles (id, email, full_name, role_id, created_at, updated_at)
-- VALUES 
--   ('admin-user-uuid', 'admin@fujiyama.com', 'Administrator', 1, NOW(), NOW()),
--   ('mitra-user-uuid', 'mitra@fujiyama.com', 'Mitra Bisnis', 2, NOW(), NOW()),  
--   ('driver-user-uuid', 'driver@fujiyama.com', 'Driver Logistik', 3, NOW(), NOW())
-- ON CONFLICT (id) DO NOTHING;

-- 4. Insert beberapa sample products
INSERT INTO public.products (name, type, price_per_kg, description, is_active)
VALUES 
  ('Cangkang Sawit Grade A', 'Premium', 1500.00, 'Cangkang sawit kualitas terbaik untuk biomass', true),
  ('Cangkang Sawit Grade B', 'Standard', 1200.00, 'Cangkang sawit kualitas standard untuk fuel', true),
  ('Cangkang Sawit Grade C', 'Economy', 900.00, 'Cangkang sawit kualitas ekonomis', true)
ON CONFLICT DO NOTHING;

-- 5. Enable RLS jika belum aktif
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 6. Buat policy untuk testing (development only)
DROP POLICY IF EXISTS "Enable read access for all users" ON public.profiles;
CREATE POLICY "Enable read access for all users" ON public.profiles
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.profiles;  
CREATE POLICY "Enable insert for authenticated users" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Enable update for own profile" ON public.profiles;
CREATE POLICY "Enable update for own profile" ON public.profiles  
  FOR UPDATE USING (auth.uid() = id);

-- Products policies
DROP POLICY IF EXISTS "Enable read access for all products" ON public.products;
CREATE POLICY "Enable read access for all products" ON public.products
  FOR SELECT USING (is_active = true);

COMMIT;