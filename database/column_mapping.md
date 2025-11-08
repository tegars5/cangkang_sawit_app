# Database Column Mapping - Indonesian to English

## Orders Table

| Old (Indonesian)         | New (English)      |
| ------------------------ | ------------------ |
| mitra_id                 | customer_id        |
| tanggal_pesanan          | order_date         |
| status_pesanan           | status             |
| total_kuantitas          | total_quantity     |
| total_kuantitas_diterima | confirmed_quantity |
| total_harga              | total_amount       |
| catatan_admin            | admin_notes        |
| catatan_mitra            | customer_notes     |
| tanggal_konfirmasi       | confirmed_at       |
| tanggal_selesai          | completed_at       |

### Status Values:

- 'Baru' → 'pending'
- 'Dikonfirmasi' → 'confirmed'
- 'Dikirim' → 'shipped'
- 'Selesai' → 'completed'
- 'Dibatalkan' → 'cancelled'

## Products Table

| Old (Indonesian) | New (English)   |
| ---------------- | --------------- |
| nama_produk      | name            |
| deskripsi        | description     |
| harga            | price_per_kg    |
| satuan           | unit            |
| stok_tersedia    | stock_available |
| kategori         | category        |
| kode_produk      | product_code    |
| spesifikasi      | specifications  |

## Order Details Table

| Old (Indonesian) | New (English)      |
| ---------------- | ------------------ |
| jumlah_dipesan   | requested_quantity |
| jumlah_diterima  | confirmed_quantity |
| harga_satuan     | unit_price         |
| catatan          | notes              |

## Shipments Table

| Old (Indonesian)  | New (English)         |
| ----------------- | --------------------- |
| nomor_surat_jalan | delivery_note_number  |
| url_surat_jalan   | delivery_note_url     |
| url_bukti_kirim   | proof_of_delivery_url |
| status_pengiriman | status                |
| tanggal_dibuat    | assigned_at           |
| tanggal_mulai     | started_at            |
| tanggal_selesai   | completed_at          |
| estimasi_tiba     | estimated_arrival     |

### Shipment Status Values:

- 'Menunggu' → 'pending'
- 'Dalam Perjalanan' → 'in_transit'
- 'Tiba' → 'arrived'
- 'Selesai' → 'completed'

## Storage Buckets

| Old (Indonesian) | New (English)       |
| ---------------- | ------------------- |
| 'surat-jalan'    | 'delivery-notes'    |
| 'bukti-kirim'    | 'proof-of-delivery' |

## TODO: Flutter Code Updates Needed

1. Update all ORDER queries in OrderConfirmationScreen
2. Update all PRODUCTS queries in repositories
3. Update SHIPMENT queries in ShipmentAssignmentScreen
4. Update status constants throughout the app
5. Update Storage bucket references
