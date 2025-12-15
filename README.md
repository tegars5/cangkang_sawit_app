Cangkang Sawit Delivery App
Aplikasi penjualan dan pengiriman cangkang sawit berbasis Flutter dengan backend Supabase, dilengkapi tracking pengiriman real-time menggunakan Google Maps API seperti Gojek/Grab.​

Fitur Utama
Mitra membuat pesanan produk cangkang sawit, memantau status pesanan, dan melihat posisi driver secara real-time di peta.​

Admin mengelola produk, pesanan, surat jalan, dan menugaskan driver untuk pengiriman.​

Driver menerima tugas dari admin, melihat alamat tujuan di Google Maps, dan mengupdate status serta lokasi pengiriman.​

Role dan Alur Bisnis
Mitra
Registrasi / login sebagai mitra (Supabase Auth).​

Membuat pesanan: pilih produk, jumlah, alamat tujuan.

Melihat riwayat pesanan dan status (Menunggu, Diproses, Dalam Perjalanan, Selesai).

Membuka halaman tracking untuk melihat posisi driver di Google Maps secara real-time.​

Admin
Login sebagai admin.

CRUD produk (nama, harga, satuan, stok).​

Melihat daftar pesanan mitra dan mengubah status pesanan.

Membuat surat jalan (berisi data mitra, produk, jumlah, driver, alamat tujuan).

Menugaskan driver ke pesanan yang sudah memiliki surat jalan.​

Driver
Login sebagai driver.​

Melihat daftar tugas pengiriman yang ditugaskan admin.

Membuka detail tugas: data pesanan dan alamat tujuan di Google Maps.​

Memulai perjalanan, mengirim update lokasi berkala ke Supabase (real-time), dan menyelesaikan pengiriman.