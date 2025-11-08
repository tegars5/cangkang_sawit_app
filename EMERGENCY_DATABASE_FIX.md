# 🚨 **EMERGENCY FIX: Database Structure Problem**

## ⚡ **SUPER SIMPLE SOLUTION - Step by Step**

Error `column "id" of relation "roles" does not exist` artinya tabel sudah ada tapi strukturnya salah.

---

## 🛠️ **LANGKAH PERBAIKAN MUDAH:**

### **STEP 1: Cek Struktur Tabel Yang Ada**

Jalankan SQL ini dulu untuk lihat apa yang ada:

```sql
-- Cek tabel apa saja yang ada
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Cek struktur tabel roles (jika ada)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'roles' AND table_schema = 'public';

-- Cek struktur tabel profiles (jika ada)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'profiles' AND table_schema = 'public';
```

### **STEP 2: Clean Slate - Hapus Semua & Mulai Fresh**

```sql
-- Hapus tabel yang bermasalah
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;

-- Buat ulang dengan struktur yang benar
CREATE TABLE public.roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert data roles
INSERT INTO public.roles (name) VALUES
    ('Admin'),
    ('Mitra Bisnis'),
    ('Logistik');

-- Buat tabel profiles
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    role_id INTEGER REFERENCES public.roles(id),
    phone VARCHAR(20),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Disable RLS untuk development
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;

-- Verifikasi hasil
SELECT 'ROLES:' as table_type, id, name FROM public.roles
UNION ALL
SELECT 'STRUCTURE:' as table_type, 0 as id, 'Tables created successfully' as name;
```

### **STEP 3: Test di Aplikasi**

Setelah database clean, test:

1. **Buka aplikasi Flutter**
2. **Tekan "🧪 Comprehensive Test"**
3. **Tekan "Test DB"** - harus show roles found: 3
4. **Tekan "Normal Create"** atau "Force Create"
5. **Test login admin@fujiyama.com / password123**

---

## 🔍 **TROUBLESHOOTING ALTERNATIF:**

### **Jika Masih Error, Coba Manual Create:**

1. **Supabase Console** → **"Table Editor"**
2. **Create New Table** → nama: `roles`
3. **Add columns:**

   - `id`: `int8` (Primary Key, Auto-increment)
   - `name`: `text` (Unique)
   - `created_at`: `timestamptz` (Default: now())

4. **Insert data manual:**

   - Row 1: name = `Admin`
   - Row 2: name = `Mitra Bisnis`
   - Row 3: name = `Logistik`

5. **Create table** `profiles`:
   - `id`: `uuid` (Primary Key)
   - `email`: `text` (Unique)
   - `full_name`: `text`
   - `role_id`: `int8` (Foreign Key → roles.id)
   - `created_at`: `timestamptz` (Default: now())
   - `updated_at`: `timestamptz` (Default: now())

---

## ✅ **Expected Result:**

Setelah fix ini:

- ✅ **No more column errors**
- ✅ **Test DB shows "Roles found: 3"**
- ✅ **Create users berhasil**
- ✅ **Login admin sukses**

**Mari coba clean slate approach dulu! DROP semua tabel lama dan buat fresh.** 🚀
