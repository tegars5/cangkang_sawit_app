# 🔐 **CARA LOGIN SEBAGAI ADMIN**

## 📱 **Login Credentials untuk Admin:**

### 🎯 **Admin Login:**

```
Email: admin@fujiyama.com
Password: password123
```

## 🚀 **Langkah-langkah Login:**

### 1. **Buka Aplikasi**

- Aplikasi akan menampilkan login screen
- Pastikan tidak ada overflow (sudah diperbaiki)

### 2. **Input Credentials Admin**

- **Email**: Ketik `admin@fujiyama.com`
- **Password**: Ketik `password123`
- Klik tombol **"Masuk"**

### 3. **Otomatis Redirect ke Admin Dashboard**

- Setelah login berhasil, aplikasi akan otomatis redirect ke **Admin Dashboard**
- Dashboard admin memiliki fitur:
  - 📊 **Statistics Cards**: Total orders, pending shipments, products, users
  - 📋 **Order Management**: Kelola semua pesanan
  - 📦 **Product Management**: Kelola katalog produk
  - 🚚 **Shipping**: Manajemen pengiriman
  - 👥 **User Management**: Kelola users

## 🛠️ **Jika User Belum Ada (First Time Setup):**

### Option 1: Create via App

1. Di login screen, klik **"Create Test Users (Dev Only)"**
2. Tunggu proses selesai
3. Login dengan credentials admin di atas

### Option 2: Create Manual (Advanced)

1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project: **pblydtqugcbrlezemerg**
3. Go to **Authentication > Users**
4. Add user: `admin@fujiyama.com` dengan password `password123`
5. Jalankan SQL untuk assign role admin

## 🎯 **Dashboard Admin Features:**

### 📊 **Statistics Overview:**

- **Total Orders**: Jumlah pesanan keseluruhan
- **Pending Shipments**: Pengiriman yang menunggu
- **Products**: Jumlah produk dalam katalog
- **Users**: Total users di sistem

### 📋 **Menu Utama Admin:**

1. **Order Management** 📦

   - Lihat semua pesanan masuk
   - Approve/reject pesanan
   - Assign driver untuk pengiriman
   - Track status pengiriman

2. **Product Management** 🌿

   - Tambah produk cangkang sawit
   - Edit harga dan deskripsi
   - Manage stok availability
   - Set kategori dan grade

3. **Shipping Management** 🚚

   - Monitor semua pengiriman
   - Assign driver ke pesanan
   - Real-time GPS tracking
   - Delivery confirmation

4. **User Management** 👥
   - Kelola user accounts
   - Assign roles (Admin, Mitra, Driver)
   - Monitor user activity
   - Manage permissions

## 🔍 **Testing Admin Flow:**

### 1. **Login Test**

```bash
Email: admin@fujiyama.com
Password: password123
Expected: Redirect to Admin Dashboard
```

### 2. **Navigation Test**

- Cek semua menu cards bisa diklik
- Pastikan statistics cards menampilkan data
- Test logout functionality

### 3. **Role Verification**

- Login sebagai admin harus masuk ke Admin Dashboard
- Tidak bisa akses fitur Mitra atau Driver
- Full access ke semua admin features

## ⚠️ **Troubleshooting:**

### Issue: "User not found" atau "Invalid credentials"

**Solution:**

1. Pastikan test users sudah dibuat dengan klik "Create Test Users"
2. Check spelling: `admin@fujiyama.com` (bukan admin@gmail.com)
3. Password: `password123` (lowercase, tidak ada spasi)

### Issue: "Role tidak dikenali"

**Solution:**

1. User ada tapi role belum assign
2. Jalankan SQL script di database untuk assign role admin
3. Check di Supabase dashboard: profiles table harus ada role_id = 1

### Issue: Login berhasil tapi tidak redirect

**Solution:**

1. Check console untuk error messages
2. Pastikan AdminDashboard widget tidak ada error
3. Restart aplikasi dan coba lagi

## 📱 **Current Status:**

✅ **Login screen fixed** - Tidak ada overflow
✅ **Test credentials ready** - Admin user siap
✅ **Role-based navigation** - Auto redirect berdasarkan role  
✅ **Admin dashboard UI** - Complete dengan menu grid
🚧 **Backend integration** - Next development phase

---

**🎉 Sekarang Anda siap login sebagai Admin dan explore semua fitures!**

**Login = admin@fujiyama.com / password123** 🔑
