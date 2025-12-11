1. Penjelasan Alur Aplikasi (Flow)
Aplikasi ini adalah Sistem Supply Chain Cangkang Sawit yang melibatkan 3 Aktor Utama. Bayangkan alurnya seperti estafet barang:

A. Mitra (Pembeli/Klien)
Tugas: Membeli cangkang sawit.

Alur:

Login/Register: Masuk ke aplikasi.

Dashboard: Melihat ringkasan (Product Catalog).

Create Order: Memilih produk -> Masukkan jumlah (tonase) -> Checkout.

Tracking: Memantau pesanan yang sedang dikirim (mirip Gojek/Grab, bisa lihat lokasi Driver).

History: Melihat riwayat pesanan selesai.

B. Admin (Pengelola)
Tugas: Mengatur pesanan & logistik.

Alur:

Manage Orders: Menerima pesanan dari Mitra (Status: Pending -> Confirmed).

Prepare Shipment: Setelah pesanan dikonfirmasi, Admin membuat "Pengiriman" (Shipment) dan menetapkan Driver (Assign Driver) serta kendaraan.

Monitoring: Admin bisa melihat semua lokasi driver secara real-time di peta.

C. Driver (Kurir)
Tugas: Mengantar barang.

Alur:

Task List: Menerima tugas pengiriman baru dari Admin.

Update Status:

On the way to Pickup (Menuju gudang muat).

Loading (Sedang memuat cangkang sawit).

On Delivery (Sedang jalan ke lokasi Mitra -> GPS Tracking Aktif).

Arrived/Unloading (Sampai).

Completed (Selesai).

Upload Bukti: Biasanya upload foto surat jalan/barang sampai.

2. Masalah Utama di Kodingan (Kenapa Kakak Bingung)
Dari daftar file, saya menemukan DUPLIKASI PARAH yang harus dibersihkan:

Model Ganda (Bahaya): Kakak punya lib/data/models/order.dart DAN lib/shared/models/order.dart.

Masalah: Kalau Kakak update satu file, file yang lain tidak berubah. Nanti error "Type Mismatch" di mana-mana.

Solusi: Hapus folder lib/data/models, pindahkan semua ke lib/shared/models (atau sebaliknya, pilih satu saja).

State Management Gado-gado: Ada folder controllers (biasanya istilah GetX/MVC) di lib/features/admin/controllers, tapi ada juga providers (Riverpod/Provider) di lib/features/admin/providers.

Masalah: Membingungkan cara update datanya.

Solusi: Standarisasi. Gunakan satu istilah (misal: semua pakai Provider/Notifier).

File Sampah: Ada lib/main_clean.dart. Ini file percobaan yang lupa dihapus? Sebaiknya hanya ada satu main.dart. Ada folder lib/debug dan lib/utils/test_user_creator.dart yang tercampur di production code.

