# 🎯 **QUICK FIX: Auto-Generate Test Users SQL**

## 🚀 **Solusi Tercepat - Copy-Paste SQL Script**

Daripada manual create users satu per satu, gunakan script ini untuk auto-generate semuanya:

---

## 📋 **LANGKAH MUDAH:**

### **1. Buka Supabase Console**

- https://supabase.com/dashboard
- Login → Pilih project `cangkang_sawit_app`
- Klik **"SQL Editor"**

### **2. Copy-Paste Script Ini:**

```sql
-- ========================================
-- 🛠️ COMPLETE DATABASE SETUP
-- ========================================

-- Step 1: Drop and Recreate Roles Table (fix structure issues)
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;

-- Create roles table with correct structure
CREATE TABLE public.roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert roles
INSERT INTO public.roles (id, name) VALUES
    (1, 'Admin'),
    (2, 'Mitra Bisnis'),
    (3, 'Logistik');-- Step 2: Create/Update Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    role_id INTEGER REFERENCES public.roles(id),
    phone VARCHAR(20),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role_id ON public.profiles(role_id);

-- Step 3: Enable RLS and Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.roles;

-- Create new policies
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON public.profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            JOIN public.roles r ON p.role_id = r.id
            WHERE p.id = auth.uid() AND r.name = 'Admin'
        )
    );

CREATE POLICY "Authenticated users can view roles" ON public.roles
    FOR SELECT TO authenticated USING (true);

-- Step 4: Create Test Users Function
CREATE OR REPLACE FUNCTION create_test_users()
RETURNS TABLE(user_id UUID, email TEXT, password TEXT, role_name TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    admin_id UUID;
    mitra_id UUID;
    driver_id UUID;
BEGIN
    -- Generate UUIDs for test users
    admin_id := gen_random_uuid();
    mitra_id := gen_random_uuid();
    driver_id := gen_random_uuid();

    -- Insert into auth.users (simulated - actual creation needs to be done via auth)
    -- We'll return the info needed to create manually

    -- Insert profiles (will work after users are created via auth)
    INSERT INTO public.profiles (id, email, full_name, role_id) VALUES
        (admin_id, 'admin@fujiyama.com', 'Administrator System', 1),
        (mitra_id, 'mitra@fujiyama.com', 'Mitra Bisnis Partner', 2),
        (driver_id, 'driver@fujiyama.com', 'Driver Logistik', 3)
    ON CONFLICT (email) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role_id = EXCLUDED.role_id,
        updated_at = NOW();

    -- Return user info for manual auth creation
    RETURN QUERY
    SELECT admin_id, 'admin@fujiyama.com'::TEXT, 'password123'::TEXT, 'Admin'::TEXT
    UNION ALL
    SELECT mitra_id, 'mitra@fujiyama.com'::TEXT, 'password123'::TEXT, 'Mitra Bisnis'::TEXT
    UNION ALL
    SELECT driver_id, 'driver@fujiyama.com'::TEXT, 'password123'::TEXT, 'Logistik'::TEXT;
END;
$$;

-- Step 5: Run the function to get user IDs
SELECT * FROM create_test_users();

-- Step 6: Verify setup
SELECT 'ROLES:' as type, name as info FROM public.roles
UNION ALL
SELECT 'PROFILES:' as type, email || ' (' || full_name || ')' as info FROM public.profiles;
```

### **3. Jalankan Script**

- Paste script di SQL Editor
- Klik **"Run"**
- Catat UUID yang dihasilkan

### **4. Buat Auth Users Manual**

Setelah script jalan, di tab **"Authentication" → "Users"**:

- **Add User** dengan email dan password yang sama
- **Gunakan UUID** yang dihasilkan script di atas

---

## 🎯 **ALTERNATIF SUPER CEPAT:**

Jika cara di atas ribet, coba ini:

### **Disable Email Confirmation Dulu:**

1. Di Supabase Console → **"Authentication" → "Settings"**
2. **Disable "Enable email confirmations"**
3. **Save**

### **Jalankan Script Sederhana:**

```sql
-- EMERGENCY FIX: Drop dan buat ulang tabel yang bermasalah
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;

-- Buat tabel roles dari awal dengan struktur yang benar
CREATE TABLE public.roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert roles (tanpa specify ID, biarkan auto-increment)
INSERT INTO public.roles (name) VALUES
    ('Admin'),
    ('Mitra Bisnis'),
    ('Logistik');

-- Buat tabel profiles dengan kolom email
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    role_id INTEGER REFERENCES public.roles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Disable RLS untuk development
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Verifikasi setup berhasil
SELECT 'SUCCESS - ROLES:' as status, id, name FROM public.roles;
```

### **Test Login di App:**

Setelah database siap:

1. **Buka aplikasi Flutter**
2. **Tekan "Create Test Users"** - sekarang harus berhasil
3. **Login dengan admin@fujiyama.com / password123**

---

## ✅ **Expected Result:**

Setelah setup ini, aplikasi Flutter akan bisa:

- ✅ Create test users tanpa error "column doesn't exist"
- ✅ Login berhasil dengan admin credentials
- ✅ Navigate ke Admin Dashboard

**Mari coba setup database ini dulu, kemudian test lagi di aplikasi!** 🚀
