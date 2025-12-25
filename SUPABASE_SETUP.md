# 🗄️ Supabase Storage Setup Guide

## 📦 Storage Buckets Status

### ✅ Buckets yang Sudah Ada:

1. **`bukti-kirim`** - Untuk foto bukti pengiriman (Proof of Delivery)
2. **`surat-jalan`** - Untuk dokumen PDF surat jalan (Delivery Notes)

### ❌ Buckets yang Perlu Dibuat:

3. **`users`** - Untuk foto profil user
4. **`products`** - Untuk gambar produk

---

## 🚀 Quick Setup dengan SQL

Buka **SQL Editor** di Supabase Dashboard, copy-paste script ini, lalu klik **Run**:

```sql
-- ============================================
-- 1. BUAT BUCKET USERS
-- ============================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'users',
  'users',
  true,
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png']
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. BUAT BUCKET PRODUCTS
-- ============================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'products',
  'products',
  true,
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png']
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. RPC FUNCTIONS UNTUK PERFORMANCE
-- ============================================

-- Function: Count total orders
CREATE OR REPLACE FUNCTION count_orders()
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(*)::INTEGER FROM orders);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Count orders by status
CREATE OR REPLACE FUNCTION count_orders_by_status(status_param TEXT)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(*)::INTEGER FROM orders WHERE status = status_param);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. GRANT PERMISSIONS
-- ============================================
GRANT EXECUTE ON FUNCTION count_orders() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION count_orders_by_status(TEXT) TO anon, authenticated;

-- ============================================
-- 5. STORAGE POLICIES (OPTIONAL - For RLS)
-- ============================================

-- Policy: Anyone can view public buckets
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id IN ('bukti-kirim', 'surat-jalan', 'users', 'products'));

-- Policy: Authenticated users can upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id IN ('bukti-kirim', 'surat-jalan', 'users', 'products')
);

-- Policy: Users can delete their own uploads
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  auth.role() = 'authenticated' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## 📊 Bucket Configuration Details

| Bucket Name   | Purpose                  | Max Size | Allowed Types  | Public |
| ------------- | ------------------------ | -------- | -------------- | ------ |
| `bukti-kirim` | Proof of Delivery Photos | 10 MB    | JPG, JPEG, PNG | ✅ Yes |
| `surat-jalan` | Delivery Note Documents  | 10 MB    | PDF            | ✅ Yes |
| `users`       | User Profile Photos      | 5 MB     | JPG, JPEG, PNG | ✅ Yes |
| `products`    | Product Images           | 5 MB     | JPG, JPEG, PNG | ✅ Yes |

---

## 🔧 Manual Setup (Alternative)

Jika tidak ingin pakai SQL, setup manual via Dashboard:

### Bucket: `users`

1. Klik **"New bucket"**
2. Name: `users`
3. Public bucket: ✅ ON
4. Restrict file size: ✅ ON → Set **5 MB**
5. Restrict MIME types: ✅ ON → Add:
   - `image/jpeg`
   - `image/jpg`
   - `image/png`
6. Klik **Create**

### Bucket: `products`

1. Klik **"New bucket"**
2. Name: `products`
3. Public bucket: ✅ ON
4. Restrict file size: ✅ ON → Set **5 MB**
5. Restrict MIME types: ✅ ON → Add:
   - `image/jpeg`
   - `image/jpg`
   - `image/png`
6. Klik **Create**

---

## 🎯 Usage in Flutter Code

### 1. Upload Proof of Delivery

```dart
final fileUploadService = ref.read(fileUploadServiceProvider);

final url = await fileUploadService.uploadProofOfDelivery(
  shipmentId: 'shipment-123',
  imageFile: File('/path/to/photo.jpg'),
);
// URL: https://[project].supabase.co/storage/v1/object/public/bukti-kirim/shipment-123_1234567890.jpg
```

### 2. Upload Delivery Note PDF

```dart
final url = await fileUploadService.uploadDeliveryNote(
  shipmentId: 'shipment-123',
  pdfFile: File('/path/to/note.pdf'),
);
// URL: https://[project].supabase.co/storage/v1/object/public/surat-jalan/shipment-123_1234567890.pdf
```

### 3. Upload Profile Photo

```dart
final url = await fileUploadService.uploadProfilePhoto(
  userId: 'user-456',
  imageFile: File('/path/to/photo.jpg'),
);
// URL: https://[project].supabase.co/storage/v1/object/public/users/user-456_1234567890.jpg
```

### 4. Upload Product Image

```dart
final url = await fileUploadService.uploadProductImage(
  productId: 'product-789',
  imageFile: File('/path/to/product.jpg'),
);
// URL: https://[project].supabase.co/storage/v1/object/public/products/product-789_1234567890.jpg
```

---

## ✅ Verification

Setelah run SQL script, verify di Dashboard:

1. **Storage** → **Files** → Lihat 4 buckets:

   - ✅ bukti-kirim
   - ✅ surat-jalan
   - ✅ users
   - ✅ products

2. **Database** → **Functions** → Lihat 2 functions:

   - ✅ count_orders()
   - ✅ count_orders_by_status(text)

3. Test upload dari Flutter app:
   ```bash
   flutter run
   # Upload test file via app
   ```

---

## 🔒 Security Best Practices

### Row Level Security (RLS)

Policies sudah dibuat untuk:

- ✅ Public read access (semua orang bisa lihat)
- ✅ Authenticated upload (hanya user login bisa upload)
- ✅ Owner delete (user hanya bisa hapus file sendiri)

### MIME Type Restrictions

- ✅ Hanya accept image types (JPG, PNG)
- ✅ PDF untuk delivery notes
- ❌ Block executable files (.exe, .sh)
- ❌ Block scripts (.js, .php)

### File Size Limits

- ✅ Max 5-10 MB per file
- ❌ Prevent large video uploads
- ❌ Prevent DOS attacks

---

## 🐛 Troubleshooting

### Error: "Policy violation"

**Solution:** Run policy creation SQL di atas atau disable RLS untuk testing:

```sql
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

### Error: "Bucket not found"

**Solution:** Verify bucket name di code sama dengan di dashboard (case-sensitive!)

### Error: "File too large"

**Solution:** Compress image before upload atau increase file_size_limit

### Error: "Invalid MIME type"

**Solution:** Check file extension atau add MIME type ke allowed list

---

## 📞 Support

Jika ada masalah:

1. Check error message di Flutter console
2. Check Supabase Dashboard → Logs
3. Verify bucket settings di Storage → Settings
4. Test upload via Supabase Dashboard → Storage → Upload

---

## 🎉 Done!

Setelah setup selesai, aplikasi sudah bisa:

- ✅ Upload foto bukti pengiriman
- ✅ Upload dokumen surat jalan (PDF)
- ✅ Upload foto profil user
- ✅ Upload gambar produk
- ✅ View uploaded files via public URL
- ✅ Delete files (owner only)

**Happy Coding! 🚀**
