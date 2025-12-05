# Quick Debug Guide - Login Error

## Error yang Terjadi
"Login Gagal" → "Gagal memuat profil pengguna"

## Kemungkinan Penyebab

### 1. Profile Tidak Ditemukan di Database
**Check**:
```sql
SELECT * FROM profiles WHERE email = 'admin@gmail.com';
```

**Jika kosong**: Profile belum dibuat
**Solution**: Run SQL script lagi atau create manual

### 2. role_id NULL
**Check**:
```sql
SELECT id, email, full_name, role_id FROM profiles WHERE email = 'admin@gmail.com';
```

**Jika role_id NULL**: Update role_id
**Solution**:
```sql
UPDATE profiles 
SET role_id = 1 
WHERE email = 'admin@gmail.com';
```

### 3. Relasi roles Tidak Ada
**Check**:
```sql
SELECT p.*, r.name as role_name
FROM profiles p
LEFT JOIN roles r ON p.role_id = r.id
WHERE p.email = 'admin@gmail.com';
```

**Jika role_name NULL**: roles table kosong
**Solution**: Run SQL fix script bagian roles

## Quick Fix Steps

1. **Buka Supabase SQL Editor**

2. **Check Profile**:
```sql
SELECT * FROM profiles WHERE email = 'admin@gmail.com';
```

3. **Jika profile ada tapi role_id NULL**:
```sql
UPDATE profiles 
SET role_id = 1,
    full_name = 'Administrator',
    is_active = true
WHERE email = 'admin@gmail.com';
```

4. **Verify**:
```sql
SELECT p.id, p.email, p.full_name, p.role_id, r.name as role_name, p.is_active
FROM profiles p
LEFT JOIN roles r ON p.role_id = r.id
WHERE p.email = 'admin@gmail.com';
```

Expected result:
- role_id: 1
- role_name: Admin
- full_name: Administrator
- is_active: true

5. **Restart app dan coba login lagi**

## Debug dengan Console Log

Setelah update LoginController, cek console saat login:
- Lihat pesan error yang lebih detail
- Cek apakah ada "Profile loading error"
- Cek exception details

## Jika Masih Error

Kirim screenshot dari:
1. Supabase → Table Editor → profiles (filter admin@gmail.com)
2. Console log saat login
3. Error dialog yang muncul
