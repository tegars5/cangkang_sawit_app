Tolong perbaiki seluruh fitur Login dan Register pada project Flutter saya. 
Saya mengalami beberapa error, yaitu:

1. Login gagal karena muncul error “Gagal memuat profil pengguna”.
2. Data profil di Supabase tidak terbaca karena ID duplicate / tidak sinkron.
3. Tombol “Lanjut” pada Register tidak berfungsi.
4. Login Admin juga tidak berhasil.
5. Banyak field yang bernilai null atau tidak otomatis terisi.
6. Beberapa fungsi seperti loadUserProfile(), register(), dan login() tidak mengembalikan data yang benar.

Berikut yang saya butuhkan:

======================
🎯 **TUJUAN**
======================
1. Login harus bisa berjalan normal:
   - Cek email & password benar.
   - Ambil profil dari tabel “profiles”.
   - Kembalikan objek UserModel lengkap (tanpa null).
   - Redirect ke halaman yang sesuai role (Admin → dashboard admin, User → dashboard user).

2. Register harus berjalan normal:
   - Insert user ke Supabase.auth.
   - Insert profil lengkap ke tabel profiles.
   - Tidak boleh ada field null (isi default kalau belum ada data).

3. Validasi lengkap:
   - Email kosong → error
   - Password < 6 → error
   - Email sudah terdaftar → tampilkan error
   - Semua error harus user-friendly.

4. Fix semua error berikut (contoh):
   - “Failed to run SQL query”
   - “duplicate key violates unique constraint profiles_pkey”
   - role_id null
   - profile tidak ditemukan setelah login
   - argument type error di controller

======================
📌 **YANG HARUS DIBUATKAN**
======================
1. Perbaikan kode lengkap untuk:
   - auth_provider.dart
   - registration_controller.dart
   - login_controller.dart
   - user_repository.dart
   - profile_service.dart

2. SQL Script untuk membuat:
   - roles (admin, user)
   - profiles dengan constraint benar (tanpa null)
   - contoh insert data admin yang tidak membuat duplicate ID

3. Kode lengkap untuk:
   - Fungsi login()
   - Fungsi register()
   - loadUserProfile()
   - saveProfile()

4. Perbaikan UI:
   - Tombol “Lanjut” register harus aktif
   - Tombol login harus memanggil controller dengan benar
   - Tampilkan loading saat proses login/register

5. Middleware/guard:
   - Jika role == admin → navigate ke Admin Dashboard
   - Jika role == user → navigate ke User Dashboard

======================
📎 **CONTOH USER ADMIN**
======================
email: admin@gmail.com
password: password123
role: admin

Tolong buatkan juga kode SQL insert untuk admin agar tidak duplicate.

======================
📍 **CATATAN**
======================
– Gunakan Supabase (auth + public.profiles)
– Tidak boleh ada field null
– Pastikan pengambilan profil sukses setelah login
– Pastikan mapping model benar (UserModel, RoleModel, ProfileModel)

Setelah semua perbaikan, berikan saya:
1. Kode yang sudah diperbaiki
2. File baru (jika perlu)
3. SQL baru
4. Petunjuk testing login & register

