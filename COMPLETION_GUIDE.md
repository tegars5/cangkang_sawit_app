Berikut adalah panduan lengkap berupa file Markdown (`COMPLETION_GUIDE.md`) yang dapat Anda gunakan sebagai acuan (roadmap) dan juga berisi **Prompt** untuk melengkapi aplikasi "Cangkang Sawit App" Anda.

Dokumen ini mencakup perbaikan bug kritis yang ditemukan pada kode Anda (ketidaksesuaian dengan database) dan langkah-langkah sistematis untuk menyelesaikan fitur.

-----

### **COMPLETION\_GUIDE.md**

# Panduan Penyelesaian Aplikasi Cangkang Sawit (Clean Code & Riverpod)

Dokumen ini disusun untuk melengkapi pengembangan aplikasi Cangkang Sawit berbasis Flutter, Riverpod, dan Supabase. Panduan ini mencakup perbaikan skema, struktur folder, dan prompt untuk men-generate kode.

-----

## 1\. 🚨 PERBAIKAN KRITIS (Critical Fixes)

Berdasarkan kode `AuthRepository` dan skema database yang Anda berikan, terdapat ketidakcocokan nama kolom yang **akan menyebabkan aplikasi error saat Register**.

**File:** `lib/data/repositories/auth_repository.dart`
**Masalah:** Nama kolom di kode (`user_id`, `nama_lengkap`, `telepon`) tidak sesuai dengan skema database (`id`, `full_name`, `phone`).

**Kode yang Harus Diperbaiki (Method `signUp`):**

```dart
// SEBELUM (Salah):
// await _supabaseService.client.from('profiles').insert({
//   'user_id': response.user!.id,
//   'nama_lengkap': namaLengkap,
//   'role_id': roleId,
//   'telepon': telepon,
// });

// SESUDAH (Benar - Sesuai Skema):
await _supabaseService.client.from('profiles').insert({
  'id': response.user!.id, // Primary Key profiles merujuk ke auth.users.id
  'email': email,           // Kolom email wajib diisi (NOT NULL)
  'full_name': namaLengkap, // Kolom di DB adalah 'full_name'
  'role_id': roleId,
  'phone': telepon,         // Kolom di DB adalah 'phone'
  'created_at': DateTime.now().toIso8601String(),
});
```

-----

## 2\. Struktur State Management (Riverpod)

Untuk menjaga **Clean Code**, kita akan menggunakan arsitektur:
`UI` -\> `Controller (AsyncNotifierProvider)` -\> `Repository` -\> `Service (Supabase)`.

Pastikan Anda membuat file-file provider berikut (jika belum ada):

1.  **`lib/features/auth/controllers/auth_controller.dart`**
      * Menghandle state login/register/logout.
      * Mengakses `AuthRepository`.
2.  **`lib/features/mitra/controllers/product_controller.dart`**
      * Fetch data `products`.
3.  **`lib/features/mitra/controllers/order_controller.dart`**
      * Create order, fetch history.
4.  **`lib/features/admin/controllers/admin_controller.dart`**
      * Manage users, approve orders.

-----

## 3\. Master Prompts untuk Generator Code

Anda dapat menyalin prompt di bawah ini ke AI (ChatGPT/Claude/Gemini) untuk membuat kode fitur yang belum lengkap secara spesifik dan bersih.

### A. Prompt untuk Melengkapi Fitur Auth (Login/Register)

> "Saya sedang membuat aplikasi Flutter dengan Supabase & Riverpod. Saya sudah punya `AuthRepository`. Tolong buatkan saya file `lib/features/auth/controllers/auth_controller.dart` menggunakan `AsyncNotifier` dari Riverpod untuk menghandle Login dan Register.
>
> Setelah itu, buatkan UI `lib/features/auth/login_screen.dart` yang modern, menggunakan `flutter_screenutil` untuk ukuran responsif, dan menghandle state loading/error dari controller tersebut. Pastikan ada validasi form."

### B. Prompt untuk Fitur Mitra (Customer Dashboard)

> "Saya butuh fitur Dashboard untuk Role Mitra. Tolong buatkan kode untuk:
>
> 1.  `lib/features/mitra/controllers/product_controller.dart`: Fetch data dari tabel `products` (filter `is_active = true`).
> 2.  `lib/features/mitra/pages/product_catalog_screen.dart`: Menampilkan GridView produk. Gunakan card yang menarik. Tampilkan harga per ton.
> 3.  `lib/features/mitra/controllers/cart_controller.dart`: Simple state untuk menampung item yang dipilih sebelum checkout.
> 4.  `lib/features/mitra/pages/create_order_screen.dart`: Form untuk checkout. Input alamat pengiriman dan tanggal. Simpan ke tabel `orders` dan `order_details`."

### C. Prompt untuk Fitur Admin (Manage Orders)

> "Untuk Role Admin, saya butuh halaman manajemen pesanan.
>
> 1.  Buat `AdminOrderController` untuk fetch semua data dari tabel `orders` join `profiles` (customer).
> 2.  Buat UI `lib/features/admin/pages/admin_orders_page.dart` yang menampilkan list pesanan dengan tab filter status (Pending, Confirmed, Shipped, Completed).
> 3.  Tambahkan fitur di UI untuk mengupdate status pesanan (misal dari Pending -\> Confirmed)."

### D. Prompt untuk Fitur Driver (Delivery Tasks)

> "Untuk Role Driver, tolong buatkan:
>
> 1.  `DriverTaskController`: Fetch data dari tabel `shipments` atau `tasks` yang `driver_id`-nya sesuai user login.
> 2.  `lib/features/driver/pages/driver_dashboard_page.dart`: Menampilkan ringkasan tugas hari ini.
> 3.  Integrasi `geolocator` untuk mengupdate tabel `driver_locations` setiap 5 menit (gunakan background service jika memungkinkan)."

-----

## 4\. Checklist Kelengkapan File

Pastikan struktur folder Anda minimal seperti ini agar mudah di-maintain:

```text
lib/
├── core/
│   ├── constants/
│   ├── services/ (SupabaseService, LocationService)
│   └── widgets/ (CustomButton, CustomTextField)
├── data/
│   ├── models/ (UserProfile, Order, Product, Shipment)
│   └── repositories/ (AuthRepo, OrderRepo, ProductRepo)
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   └── pages/ (LoginScreen, RegisterScreen)
│   ├── mitra/
│   │   ├── controllers/
│   │   └── pages/ (Dashboard, OrderHistory, ProductList)
│   ├── admin/
│   │   ├── controllers/
│   │   └── pages/ (Dashboard, UserMgmt, OrderMgmt)
│   └── driver/
│       ├── controllers/
│       └── pages/ (Dashboard, DeliveryMap)
└── main.dart
```

-----

## 5\. Tips Clean Code (Tambahan)

1.  **Gunakan `ScreenUtil` Konsisten:** Jangan campur `height: 20` dengan `height: 20.h`. Selalu gunakan `.h`, `.w`, atau `.sp` agar UI proporsional di semua HP.
2.  **Hindari Logic di UI:** Jangan memanggil `Supabase.instance.client...` langsung di dalam Widget (`onPressed`). Pindahkan logic tersebut ke `Controller` atau `Repository`. UI hanya boleh memanggil `ref.read(authControllerProvider.notifier).login(...)`.
3.  **Error Handling:** Di repository, selalu bungkus `try-catch` dan lempar Custom Exception agar UI bisa menampilkan pesan error yang ramah pengguna (misal: "Koneksi internet bermasalah" bukan "SocketException").

-----

### Cara Menggunakan Guide Ini:

1.  **Perbaiki Database Insert** di `AuthRepository` terlebih dahulu (Poin 1).
2.  **Copy-Paste** file `main.dart` dan `supabase_service.dart` yang sudah Anda miliki karena strukturnya sudah bagus.
3.  Gunakan **Prompt (Poin 3)** satu per satu ke AI Helper Anda untuk men-generate fitur per fitur (mulai dari Auth -\> Mitra -\> Admin -\> Driver).
4.  Setiap kali AI memberikan kode, cek apakah import-nya sesuai dengan struktur folder Anda di Poin 4.