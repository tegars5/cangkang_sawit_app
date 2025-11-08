# Setup Supabase untuk Cangkang Sawit App

## Project Supabase sudah dibuat!

**Project URL**: https://pblydtqugcbrlezemerg.supabase.co
**Anon Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBibHlkdHF1Z2NicmxlemVtZXJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1NzM2ODksImV4cCI6MjA3NzE0OTY4OX0.Dwd0AcSCRw2uBCQqZB1m63MD1ZcjzPDYoNpOnPRPmU4

## 1. Konfigurasi Database

### 1.1 Jalankan SQL Schema

1. Buka SQL Editor di dashboard Supabase: https://pblydtqugcbrlezemerg.supabase.co/project/_/sql
2. Copy paste isi file `supabase/schema.sql`
3. Klik "Run" untuk mengeksekusi script
4. Pastikan semua tabel berhasil dibuat

### 1.2 Verifikasi Tabel

Pastikan tabel berikut berhasil dibuat:

- `roles`
- `profiles`
- `products`
- `orders`
- `order_details`
- `shipments`
- `driver_locations`

## 3. Setup Storage

### 3.1 Buat Storage Buckets

1. Buka Storage di dashboard Supabase
2. Buat bucket baru dengan nama `surat-jalan`:

   - **Name**: `surat-jalan`
   - **Public**: ✅ (Centang)
   - **File size limit**: 10 MB
   - **Allowed mime types**: `application/pdf`

3. Buat bucket baru dengan nama `bukti-kirim`:
   - **Name**: `bukti-kirim`
   - **Public**: ✅ (Centang)
   - **File size limit**: 10 MB
   - **Allowed mime types**: `image/jpeg,image/png,image/jpg`

### 3.2 Setup Storage Policies

Buat policies untuk mengatur akses storage:

```sql
-- Policy untuk bucket surat-jalan
CREATE POLICY "Allow authenticated uploads to surat-jalan" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'surat-jalan' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Allow public read access to surat-jalan" ON storage.objects
FOR SELECT USING (bucket_id = 'surat-jalan');

-- Policy untuk bucket bukti-kirim
CREATE POLICY "Allow authenticated uploads to bukti-kirim" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'bukti-kirim' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Allow public read access to bukti-kirim" ON storage.objects
FOR SELECT USING (bucket_id = 'bukti-kirim');
```

## 4. Konfigurasi Authentication

### 4.1 Settings Auth

1. Buka Authentication > Settings
2. Konfigurasi:
   - **Site URL**: `https://your-domain.com` (atau `http://localhost:3000` untuk development)
   - **JWT expiry**: 3600 (1 hour)
   - **Enable email confirmations**: ❌ (Nonaktif untuk development)
   - **Enable phone confirmations**: ❌ (Nonaktif)

### 4.2 Email Templates (Opsional)

Customize email templates jika diperlukan untuk production.

## 5. Konfigurasi Flutter App

### 5.1 Dapatkan API Keys

1. Buka Settings > API
2. Copy:
   - **Project URL**: `https://xxxxxxxxxxxx.supabase.co`
   - **anon/public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 5.2 Update Constants

Edit file `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://xxxxxxxxxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  // ... rest of constants
}
```

## 6. Insert Data Awal (Seeding)

### 6.1 Data Roles

```sql
INSERT INTO roles (id, name, description) VALUES
(1, 'Admin', 'Administrator sistem'),
(2, 'Mitra Bisnis', 'Partner bisnis yang dapat membuat pesanan'),
(3, 'Logistik', 'Driver/kurir yang menangani pengiriman');
```

### 6.2 Data Products

```sql
INSERT INTO products (name, description, price_per_kg, unit) VALUES
('Cangkang Kelapa Sawit Grade A', 'Cangkang kelapa sawit kualitas premium', 1500.00, 'kg'),
('Cangkang Kelapa Sawit Grade B', 'Cangkang kelapa sawit kualitas standar', 1200.00, 'kg'),
('Cangkang Kelapa Sawit Grade C', 'Cangkang kelapa sawit kualitas ekonomis', 1000.00, 'kg');
```

### 6.3 User Testing (Opsional)

Buat user testing melalui Authentication > Users atau via SQL:

```sql
-- Akan dibuat otomatis saat user register melalui app
-- Atau bisa dibuat manual di dashboard Supabase
```

## 7. Konfigurasi Real-time

### 7.1 Enable Real-time

1. Buka Settings > API
2. Scroll ke "Real-time" section
3. Enable real-time untuk tabel yang diperlukan:
   - `driver_locations` ✅
   - `orders` ✅
   - `shipments` ✅

### 7.2 Test Real-time

Test connection di browser console:

```javascript
const { createClient } = supabase;
const supabaseUrl = "YOUR_SUPABASE_URL";
const supabaseKey = "YOUR_SUPABASE_ANON_KEY";
const client = createClient(supabaseUrl, supabaseKey);

// Test subscription
const subscription = client
  .channel("driver_locations")
  .on("postgres_changes", { event: "*", schema: "public", table: "driver_locations" }, (payload) => console.log("Change received!", payload))
  .subscribe();
```

## 8. Setup Environment Variables (Production)

Untuk production, gunakan environment variables:

```bash
# .env
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 9. Testing Setup

### 9.1 Test Database Connection

```dart
// Test di Flutter app
await Supabase.initialize(
  url: AppConstants.supabaseUrl,
  anonKey: AppConstants.supabaseAnonKey,
);

final response = await Supabase.instance.client
  .from('roles')
  .select();

print('Roles: $response');
```

### 9.2 Test Storage Upload

```dart
final file = File('path/to/test.pdf');
final response = await Supabase.instance.client
  .storage
  .from('surat-jalan')
  .upload('test.pdf', file);

print('Upload result: $response');
```

## 10. Monitoring & Maintenance

### 10.1 Dashboard Monitoring

- Monitor usage di dashboard Supabase
- Check logs untuk errors
- Monitor database performance

### 10.2 Backup Strategy

- Enable point-in-time recovery (Pro plan)
- Regular database backups
- Export important data

## Troubleshooting

### Common Issues:

1. **RLS Policies**: Pastikan Row Level Security policies sudah benar
2. **CORS Issues**: Check site URL di auth settings
3. **Storage Upload Fails**: Verifikasi bucket policies dan file permissions
4. **Real-time Not Working**: Check if real-time enabled untuk tabel terkait

### Debug Tools:

- Supabase logs
- Network tab di browser
- Flutter debug console

---

📝 **Note**: Simpan API keys dengan aman dan jangan commit ke version control!
