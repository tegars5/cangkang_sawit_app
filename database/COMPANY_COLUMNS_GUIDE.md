# 🏢 **SQL Query: Add Company Columns to Profiles**

## 📋 **Query untuk Supabase SQL Editor:**

### **🚀 Main Query (Copy & Paste):**

```sql
-- Add company_name column (Company name like PT/CV)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);

-- Add job_title column (PIC position/title)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS job_title VARCHAR(100);

-- Add latitude column (Warehouse coordinate - Y axis)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;

-- Add longitude column (Warehouse coordinate - X axis)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
```

### **🔒 Optional Safety Constraints:**

```sql
-- Latitude validation (-90 to 90 degrees)
ALTER TABLE profiles
ADD CONSTRAINT IF NOT EXISTS check_latitude_range
CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));

-- Longitude validation (-180 to 180 degrees)
ALTER TABLE profiles
ADD CONSTRAINT IF NOT EXISTS check_longitude_range
CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));
```

### **✅ Verification Query:**

```sql
-- Check if columns were added successfully
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'profiles'
  AND column_name IN ('company_name', 'job_title', 'latitude', 'longitude')
ORDER BY ordinal_position;
```

## 📊 **Column Details:**

| Column Name    | Data Type        | Purpose                        | Example                     |
| -------------- | ---------------- | ------------------------------ | --------------------------- |
| `company_name` | VARCHAR(255)     | Nama PT/CV perusahaan mitra    | "PT Sawit Makmur Indonesia" |
| `job_title`    | VARCHAR(100)     | Jabatan PIC (Person in Charge) | "Manager Operasional"       |
| `latitude`     | DOUBLE PRECISION | Koordinat Y gudang/kantor      | -6.2088                     |
| `longitude`    | DOUBLE PRECISION | Koordinat X gudang/kantor      | 106.8456                    |

## 🛡️ **Safety Features:**

1. **IF NOT EXISTS** - Tidak error jika kolom sudah ada
2. **Nullable columns** - Data existing tidak rusak
3. **Coordinate validation** - Latitude & longitude dalam range valid
4. **Proper data types** - DOUBLE PRECISION untuk koordinat akurat

## 📖 **How to Use:**

### **Step 1: Execute Main Query**

1. Buka Supabase Dashboard
2. Go to SQL Editor
3. Copy-paste main query di atas
4. Klik "Run"

### **Step 2: Verify Results**

1. Run verification query
2. Pastikan 4 kolom baru muncul
3. Check data types sesuai

### **Step 3: Update Flutter Models (Optional)**

Setelah database updated, update model Profile di Flutter:

```dart
class Profile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? address;
  final String role;

  // New company fields
  final String? companyName;    // ✅ New
  final String? jobTitle;       // ✅ New
  final double? latitude;       // ✅ New
  final double? longitude;      // ✅ New
}
```

## 🎯 **Expected Results:**

After running the query, your profiles table will have:

**Original Columns:**

- id
- email
- full_name
- phone
- address
- role

**New Columns:**

- company_name ✅
- job_title ✅
- latitude ✅
- longitude ✅

## ⚠️ **Important Notes:**

1. **Safe to run** - Uses `IF NOT EXISTS` to prevent errors
2. **No data loss** - Existing data remains unchanged
3. **Nullable fields** - New columns allow NULL values
4. **Coordinate validation** - Prevents invalid lat/lng values
5. **Ready for Google Maps** - Coordinate fields compatible with mapping

**Status: Ready to execute in Supabase SQL Editor! 🚀**
