# Google Maps API Setup Guide

## 🗝️ **Dapatkan API Key Google Maps**

### 1. Buka Google Cloud Console

- Pergi ke: https://console.cloud.google.com/
- Login dengan akun Google Anda

### 2. Buat atau Pilih Project

- Buat project baru atau pilih project yang sudah ada
- Aktifkan billing untuk project (diperlukan untuk Maps API)

### 3. Aktifkan APIs yang Diperlukan

Aktifkan APIs berikut di Google Cloud Console:

- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Places API**
- **Directions API**
- **Distance Matrix API**
- **Geocoding API**

### 4. Buat API Key

- Pergi ke "Credentials" → "Create Credentials" → "API Key"
- Copy API Key yang dihasilkan

### 5. Konfigurasi API Key Restrictions (Opsional tapi Direkomendasikan)

- Edit API Key
- Tambahkan Application restrictions:
  - **Android**: Tambahkan package name `com.example.cangkang_sawit_app` dan SHA-1 fingerprint
  - **iOS**: Tambahkan bundle identifier

## 🔧 **Setup di Aplikasi Flutter**

### 1. Update Android Configuration

Edit file: `android/app/src/main/AndroidManifest.xml`

Ganti `YOUR_GOOGLE_MAPS_API_KEY_HERE` dengan API Key Anda:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyC4R6AN7SmRN9sUIuADN4upf7cJqSmoq8E" />
```

### 2. Update iOS Configuration

Edit file: `ios/Runner/Info.plist`

Ganti `YOUR_GOOGLE_MAPS_API_KEY_HERE` dengan API Key Anda:

```xml
<key>GMSApiKey</key>
<string>AIzaSyC4R6AN7SmRN9sUIuADN4upf7cJqSmoq8E</string>
```

### 3. Install Dependencies

```bash
flutter pub get
```

## 📱 **Penggunaan dalam Kode**

### 1. Import Google Maps Widget

```dart
import '../features/maps/widgets/google_map_widget.dart';
import '../features/maps/screens/delivery_tracking_screen.dart';
```

### 2. Gunakan GoogleMapWidget

```dart
GoogleMapWidget(
  initialLat: -6.2088,
  initialLng: 106.8456,
  zoom: 15.0,
  showCurrentLocation: true,
  enableLocationTracking: true,
  markers: myMarkers,
  polylines: myPolylines,
)
```

### 3. Buka Delivery Tracking Screen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DeliveryTrackingScreen(
      shipmentId: 'SHIP123',
      shipmentNumber: 'CS-2024-001',
      shipmentData: shipmentData,
    ),
  ),
);
```

## 🎯 **Fitur yang Tersedia**

### ✅ **LocationService**

- `getCurrentPosition()` - Dapatkan posisi saat ini
- `getLocationStream()` - Streaming lokasi real-time
- `calculateDistance()` - Hitung jarak antar titik
- `enableBackgroundMode()` - Tracking background

### ✅ **GoogleMapWidget**

- Menampilkan peta Google Maps
- Marker kustom
- Polylines untuk rute
- Location tracking real-time
- Interaksi tap pada peta

### ✅ **DeliveryTrackingScreen**

- Tracking pengiriman real-time
- Estimasi waktu dan jarak
- Marker driver dan tujuan
- Informasi detail pengiriman
- Tombol hubungi driver

## 🔐 **Security Best Practices**

### 1. Restrict API Key

- Batasi penggunaan API Key per aplikasi
- Tambahkan SHA fingerprint untuk Android
- Tambahkan bundle ID untuk iOS

### 2. Monitor Usage

- Pantau penggunaan di Google Cloud Console
- Set quota limits untuk mencegah over-usage
- Enable billing alerts

### 3. Environment Variables (Production)

Untuk production, simpan API key di environment variables atau secure storage.

## ⚡ **Performance Tips**

### 1. Optimize Map Loading

- Set initial zoom level yang sesuai
- Limit jumlah marker yang ditampilkan
- Use marker clustering untuk banyak marker

### 2. Location Updates

- Set interval yang sesuai (5-10 detik)
- Use distance filter untuk mengurangi updates
- Disable tracking saat tidak diperlukan

### 3. Background Processing

- Enable background mode hanya saat diperlukan
- Handle permission dengan baik
- Implement proper error handling

## 🚀 **Ready to Use!**

Setelah setup selesai:

1. Ganti API key dengan yang asli
2. Test di device fisik (GPS tidak bekerja di emulator)
3. Berikan permission lokasi saat pertama kali dibuka
4. Nikmati fitur tracking real-time! 🗺️✨
