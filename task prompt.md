Driver Real-Time Tracking Implementation
Implementasi fitur tracking real-time untuk driver menggunakan Google Maps API, mirip dengan aplikasi Grab saat membawa penumpang, namun untuk pengiriman barang cangkang sawit.

User Review Required
IMPORTANT

Auto-Start Tracking Behavior Tracking akan otomatis dimulai ketika driver ditugaskan (assigned) ke shipment. Driver dapat mematikan tracking secara manual, namun akan ada peringatan bahwa tracking diperlukan untuk monitoring pengiriman.

IMPORTANT

Database Schema Update Tabel driver_locations di database sudah ada dan memiliki kolom yang diperlukan. Namun, perlu dipastikan bahwa kolom shipment_id nullable sudah sesuai dengan schema yang ada.

Proposed Changes
Driver Feature - Tracking Page
[NEW] 
driver_tracking_page.dart
Halaman tracking utama untuk driver yang menampilkan:

Google Maps dengan marker posisi driver saat ini
Marker tujuan pengiriman (destination)
Polyline rute dari posisi driver ke tujuan
Info panel dengan detail shipment
Status tracking (aktif/tidak aktif)
Tombol toggle untuk start/stop tracking
ETA (Estimated Time of Arrival) ke tujuan
Jarak yang tersisa
Kecepatan saat ini
Fitur khusus:

Auto-start tracking ketika shipment status = 'in_transit'
Real-time location updates setiap 10 detik
Auto-save location ke database setiap 30 detik
Camera auto-follow driver location
Zoom controls
Driver Feature - Services
[NEW] 
driver_tracking_service.dart
Service untuk mengelola tracking logic:

Auto-start tracking ketika driver assigned
Periodic location updates
Location persistence ke database
Tracking state management
Background tracking support (future enhancement)
Driver Feature - Controllers
[NEW] 
driver_tracking_controller.dart
Riverpod StateNotifier untuk state management:

Tracking state (active/inactive)
Current location
Active shipment
ETA calculation
Distance calculation
Route polyline generation
Driver Feature - Integration
[MODIFY] 
driver_dashboard_screen.dart
Update untuk integrasi dengan tracking page:

Tambah button "Mulai Tracking" pada shipment card
Navigate ke tracking page ketika shipment dimulai
Auto-redirect ke tracking page jika ada active shipment dengan status 'in_transit'
[MODIFY] 
task_detail_page.dart
Update navigation button untuk membuka tracking page:

Replace TODO pada navigation button (line 38-39)
Navigate ke driver tracking page dengan shipment data
Shared - Location Repository Enhancement
[MODIFY] 
location_repository.dart
Enhancement untuk mendukung driver tracking:

Add method untuk get latest driver location
Add method untuk calculate ETA based on distance and speed
Improve error handling untuk location updates
Shared - Shipment Model Enhancement
[MODIFY] 
shipment.dart
Tambah helper properties:

destinationLat dan destinationLng dari database schema
Helper untuk check if tracking should be active
Getter untuk destination coordinates
Verification Plan
Automated Tests
Tidak ada automated tests yang akan dibuat untuk fase ini karena fokus pada UI dan integrasi dengan Google Maps yang memerlukan manual testing.

Manual Verification
NOTE

Manual testing akan dilakukan oleh user karena memerlukan device fisik dengan GPS dan Google Maps API key yang valid.

Prerequisites:

Pastikan Google Maps API key sudah dikonfigurasi di Android (
android/app/src/main/AndroidManifest.xml
) dan iOS (
ios/Runner/AppDelegate.swift
)
Pastikan permissions untuk location sudah ditambahkan di manifest files
Device fisik atau emulator dengan GPS enabled
Test Scenarios:

Test Auto-Start Tracking

Login sebagai driver
Lihat shipment dengan status 'assigned' di dashboard
Tap "Mulai" untuk start shipment
Verify: Otomatis navigate ke tracking page
Verify: Tracking otomatis aktif (GPS icon hijau)
Verify: Map menampilkan marker driver dan destination
Test Real-Time Location Updates

Dengan tracking aktif, pindahkan device/emulator
Verify: Marker driver bergerak mengikuti posisi baru
Verify: Polyline route update
Verify: Distance dan ETA update
Test Location Persistence

Biarkan tracking berjalan selama 1-2 menit
Check database table driver_locations
Verify: Ada record baru setiap ~30 detik
Verify: Data latitude, longitude, speed, heading tersimpan
Test Manual Stop/Start Tracking

Tap tombol GPS untuk stop tracking
Verify: Muncul warning dialog
Confirm stop
Verify: GPS icon berubah warna/status
Tap lagi untuk start tracking
Verify: Tracking aktif kembali
Test Navigation Integration

Dari task detail page, tap navigation icon
Verify: Navigate ke tracking page
Verify: Shipment data ditampilkan dengan benar
Test Permission Handling

Uninstall dan install ulang app
Login sebagai driver dan start shipment
Verify: Muncul permission request untuk location
Deny permission
Verify: Error message ditampilkan
Grant permission
Verify: Tracking bisa dimulai
Expected Results:

Tracking otomatis start ketika shipment dimulai
Location updates smooth dan real-time
Data tersimpan ke database secara periodik
UI responsive dan tidak lag
Battery usage reasonable (akan dimonitor)
User Feedback Required:

Apakah interval 30 detik untuk save location sudah sesuai?
Apakah perlu fitur background tracking ketika app di-minimize?
Apakah perlu notifikasi ketika mendekati destination?