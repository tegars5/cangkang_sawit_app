# 🛠️ Database Setup - SQL Scripts untuk Supabase

## 🔧 **SOLUSI: Setup Database Langsung di Supabase Console**

Error yang terjadi: `column profiles.email does not exist` - artinya struktur tabel belum sesuai.

---

## 📋 **LANGKAH 1: Buka Supabase Console**

1. **Buka:** https://supabase.com/dashboard
2. **Login** dengan akun Anda
3. **Pilih project:** `cangkang_sawit_app`
4. **Klik tab "SQL Editor"** di sidebar kiri

---

## 🗄️ **LANGKAH 2: Jalankan SQL Script Berikut**

### **A. Buat/Update Tabel Roles**

```sql
-- Create roles table
CREATE TABLE IF NOT EXISTS public.roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default roles
INSERT INTO public.roles (id, name) VALUES
    (1, 'Admin'),
    (2, 'Mitra Bisnis'),
    (3, 'Logistik')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name;
```

### **B. Buat/Update Tabel Profiles**

```sql
-- Create profiles table with correct structure
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role_id ON public.profiles(role_id);
```

### **C. Setup Row Level Security (RLS)**

```sql
-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles table
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

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

-- Policies for roles table (read-only for authenticated users)
DROP POLICY IF EXISTS "Authenticated users can view roles" ON public.roles;
CREATE POLICY "Authenticated users can view roles" ON public.roles
    FOR SELECT TO authenticated USING (true);
```

---

## 👥 **LANGKAH 3: Buat Test Users Langsung**

### **A. Buat Auth Users di Auth Tab**

1. Di Supabase Console, klik **"Authentication" → "Users"**
2. Klik **"Add User"**
3. Buat 3 users:

**User 1 - Admin:**

- Email: `admin@fujiyama.com`
- Password: `password123`
- Confirm Password: `password123`

**User 2 - Mitra:**

- Email: `mitra@fujiyama.com`
- Password: `password123`
- Confirm Password: `password123`

**User 3 - Driver:**

- Email: `driver@fujiyama.com`
- Password: `password123`
- Confirm Password: `password123`

### **B. Insert Profiles via SQL**

Setelah users dibuat, jalankan SQL ini (ganti UUID dengan ID users yang baru dibuat):

```sql
-- Insert profiles for test users
-- GANTI UUID di bawah dengan user ID yang sebenarnya dari tab Authentication

INSERT INTO public.profiles (id, email, full_name, role_id) VALUES
    ('USER_ID_ADMIN_DARI_AUTH_TAB', 'admin@fujiyama.com', 'Administrator System', 1),
    ('USER_ID_MITRA_DARI_AUTH_TAB', 'mitra@fujiyama.com', 'Mitra Bisnis Partner', 2),
    ('USER_ID_DRIVER_DARI_AUTH_TAB', 'driver@fujiyama.com', 'Driver Logistik', 3)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role_id = EXCLUDED.role_id,
    updated_at = NOW();
```

---

## ✅ **LANGKAH 4: Verifikasi Setup**

### **A. Cek Tabel dan Data**

```sql
-- Cek roles
SELECT * FROM public.roles;

-- Cek profiles dengan roles
SELECT
    p.email,
    p.full_name,
    r.name as role_name,
    p.created_at
FROM public.profiles p
JOIN public.roles r ON p.role_id = r.id
ORDER BY p.created_at;

-- Cek auth users
SELECT id, email, created_at FROM auth.users
WHERE email LIKE '%fujiyama.com';
```

### **B. Test Login di App**

Setelah setup selesai:

1. **Buka aplikasi Flutter**
2. **Login dengan:** `admin@fujiyama.com` / `password123`
3. **Harus berhasil** masuk ke Admin Dashboard

---

## 🚨 **Troubleshooting**

### **Jika Masih Error:**

1. **Cek struktur tabel** di Supabase Console → "Table Editor"
2. **Pastikan kolom `email` ada** di tabel `profiles`
3. **Pastikan RLS policies** tidak memblokir akses
4. **Restart aplikasi Flutter**

### **Jika User Creation Gagal:**

1. **Disable email confirmation** di Authentication Settings
2. **Set email confirmation** = disabled untuk development

---

## 📝 **Summary:**

1. ✅ Setup tabel `roles` dan `profiles` dengan struktur yang benar
2. ✅ Buat test users manual di Supabase Console
3. ✅ Insert profiles dengan role assignments
4. ✅ Test login di aplikasi

**Ini akan menyelesaikan masalah "column profiles.email does not exist" dan memungkinkan login yang sukses!**
