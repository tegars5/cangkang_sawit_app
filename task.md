Prompt: Perbaikan Code Flutter + Supabase dengan Clean Architecture
Kamu adalah seorang senior Flutter developer yang berpengalaman dalam menerapkan Clean Architecture dan Supabase.
Tolong review dan perbaiki seluruh kode di branch v2 dari repo berikut:

Repo: https://github.com/tegars5/cangkang_sawit_app/tree/v2

Aplikasi ini adalah aplikasi penjualan dan pengiriman cangkang sawit dengan fitur tracking real-time menggunakan Google Maps API, terinspirasi dari alur Gojek/Grab.
Fitur utama:

Mitra membuat pesanan dan bisa melihat tracking progress driver secara real-time.

Admin mengelola produk, pesanan, membuat surat jalan, dan menugaskan driver.

Driver menerima notifikasi, melihat alamat tujuan di peta, dan mengupdate status pengiriman.

Tech stack:

Flutter (frontend)

Supabase (backend: auth, database, realtime)

Google Maps API (tracking lokasi)

Fokus Perbaikan
Struktur Project (Clean Architecture)

Pisahkan kode ke dalam 3 layer utama:

Presentation Layer: Widget Flutter dan state management (Bloc/Riverpod).

Domain Layer: Entities, use cases, dan business logic.

Data Layer: Repositories, data sources, dan model.

Gunakan pendekatan feature-first: setiap fitur (auth, product, order, delivery, tracking) punya folder sendiri di tiap layer.

Dependency Injection

Gunakan package seperti get_it atau riverpod untuk dependency injection agar kode lebih modular dan mudah di-test.

State Management

Gunakan Bloc atau Riverpod untuk mengelola state aplikasi.

Pisahkan business logic dari UI (jangan ada logic bisnis di widget).

Supabase Integration

Inisialisasi Supabase client di satu tempat (misalnya di lib/core/supabase/supabase_client.dart).

Gunakan environment variable untuk menyimpan URL dan key, jangan hardcode di kode.

Repository harus berinteraksi dengan Supabase, bukan langsung di widget.

Realtime Tracking

Gunakan Supabase Realtime untuk tracking lokasi driver.

Driver mengirim lokasi ke tabel khusus, mitra subscribe untuk melihat update real-time.

Gunakan Google Maps SDK untuk menampilkan marker lokasi driver.

Error Handling

Tambahkan error handling di setiap operasi Supabase dan tampilkan feedback ke pengguna.

Testing

Tambahkan unit test dan widget test untuk fitur utama.

Navigation & Routing

Gunakan package seperti go_router untuk mengatur navigasi dan alur aplikasi.