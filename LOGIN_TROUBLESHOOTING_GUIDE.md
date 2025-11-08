# 🔧 Login Troubleshooting Guide

## Error: "Invalid login credentials"

Jika Anda mendapat error "Invalid login credentials", ikuti langkah-langkah berikut:

### 1. ✅ Pastikan Test Users Sudah Dibuat

**Langkah paling penting:** Tekan tombol **"Create Test Users (Dev Only)"** di halaman login.

#### Credentials yang akan dibuat:

- **Admin:** `admin@fujiyama.com` / `password123`
- **Mitra Bisnis:** `mitra@fujiyama.com` / `password123`
- **Driver/Logistik:** `driver@fujiyama.com` / `password123`

### 2. 🔍 Jika Masih Error Setelah Create Test Users

1. **Restart aplikasi** (tekan `R` di terminal atau restart emulator)
2. **Tunggu 10-15 detik** untuk sinkronisasi database
3. **Coba login ulang** dengan salah satu credentials di atas

### 3. 📝 Format Input yang Benar

- **Email:** Harus lengkap dengan @fujiyama.com
- **Password:** Persis `password123` (huruf kecil semua)
- **Tidak ada spasi** di awal atau akhir

### 4. 🔄 Jika Masih Bermasalah

1. **Tekan tombol "Create Test Users"** sekali lagi
2. **Lihat notifikasi** apakah users berhasil dibuat
3. **Tunggu beberapa saat** sebelum mencoba login

### 5. 🌐 Cek Koneksi Internet

Pastikan:

- ✅ Koneksi internet stabil
- ✅ Supabase dapat diakses
- ✅ Tidak ada firewall yang memblokir

### 6. 📱 Test di Emulator vs Device

- **Emulator:** Biasanya lebih stabil untuk testing
- **Physical device:** Pastikan connected ke WiFi yang sama

## 🆘 Jika Semua Langkah di Atas Gagal

1. **Buka terminal** dan jalankan:

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Atau restart dari awal:**
   - Stop aplikasi (Ctrl+C di terminal)
   - Jalankan `flutter run` lagi
   - Tekan "Create Test Users" segera setelah app terbuka

## 📞 Untuk Developer

Jika Anda developer yang mengalami masalah:

1. **Cek Supabase Console:**

   - Buka https://supabase.com/dashboard
   - Masuk ke project `cangkang_sawit_app`
   - Cek tabel `auth.users` dan `profiles`

2. **Cek Database Schema:**

   - Pastikan tabel `roles` ada dan terisi
   - Pastikan tabel `profiles` ada
   - Pastikan RLS policies configured

3. **Debug Mode:**
   - Buka developer console
   - Lihat error messages detail
   - Check network requests ke Supabase

---

## 🎯 Quick Solution (TL;DR)

1. **Tekan "Create Test Users (Dev Only)"**
2. **Tunggu notifikasi sukses**
3. **Login dengan:** `admin@fujiyama.com` / `password123`
4. **Jika gagal:** Restart app dan coba lagi

---

_Last updated: October 27, 2025_
