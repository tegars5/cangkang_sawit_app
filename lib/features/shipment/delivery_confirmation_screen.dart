import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/models/shipment.dart';
import '../../core/repositories/shipment_repository.dart';
import '../../core/services/photo_upload_service.dart';
import '../../shared/widgets/loading_overlay.dart';

class DeliveryConfirmationScreen extends ConsumerStatefulWidget {
  final Shipment shipment;

  const DeliveryConfirmationScreen({super.key, required this.shipment});

  @override
  ConsumerState<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends ConsumerState<DeliveryConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customerNameController = TextEditingController();

  List<File> _selectedPhotos = [];
  List<String> _uploadedPhotoUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _customerNameController.text = widget.shipment.order?.customerName ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk mengambil foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      await _requestCameraPermission();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _uploadPhotos() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih minimal 1 foto sebagai bukti pengiriman'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final photoPaths = _selectedPhotos.map((file) => file.path).toList();

      final uploadedUrls =
          await PhotoUploadService.uploadMultipleDeliveryPhotos(
            shipmentId: widget.shipment.id,
            photoPaths: photoPaths,
            onProgress: (current, total) {
              setState(() {
                _uploadProgress = current / total;
              });
            },
          );

      setState(() {
        _uploadedPhotoUrls = uploadedUrls;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto berhasil diunggah'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedPhotoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah foto bukti pengiriman terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the first uploaded photo as the primary delivery photo
      final primaryPhotoUrl = _uploadedPhotoUrls.first;

      // Update shipment status to delivered with delivery photo
      await ShipmentRepository.completeShipment(
        widget.shipment.id,
        primaryPhotoUrl,
      );

      // Update notes if provided
      if (_notesController.text.trim().isNotEmpty) {
        await ShipmentRepository.updateShipment(
          widget.shipment.id,
          notes: _notesController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengiriman berhasil diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to previous screen with success result
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan pengiriman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konfirmasi Pengiriman'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipment Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Pengiriman',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildInfoRow(
                          'No. Surat Jalan:',
                          widget.shipment.deliveryNoteNumber,
                        ),
                        _buildInfoRow(
                          'Alamat Tujuan:',
                          widget.shipment.destinationAddress,
                        ),
                        if (widget.shipment.order?.customerName != null)
                          _buildInfoRow(
                            'Nama Pelanggan:',
                            widget.shipment.order!.customerName,
                          ),
                        if (widget.shipment.pickupDate != null)
                          _buildInfoRow(
                            'Tanggal Pickup:',
                            widget.shipment.formattedPickupDate,
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Customer Name Confirmation
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Nama Penerima',
                    hintText: 'Masukkan nama penerima barang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama penerima harus diisi';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Photo Section
                Text(
                  'Foto Bukti Pengiriman *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),

                // Add Photo Button
                Container(
                  width: double.infinity,
                  height: 120.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.grey.shade50,
                  ),
                  child: InkWell(
                    onTap: _selectedPhotos.length < 5
                        ? _showImagePickerOptions
                        : null,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40.sp,
                          color: _selectedPhotos.length < 5
                              ? Colors.green
                              : Colors.grey,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _selectedPhotos.length < 5
                              ? 'Tambah Foto (${_selectedPhotos.length}/5)'
                              : 'Maksimal 5 foto',
                          style: TextStyle(
                            color: _selectedPhotos.length < 5
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // Selected Photos Grid
                if (_selectedPhotos.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1,
                    ),
                    itemCount: _selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                _selectedPhotos[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(4.w),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 15.h),

                  // Upload Photos Button
                  if (_uploadedPhotoUrls.isEmpty && !_isUploading)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadPhotos,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Unggah Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),

                  // Upload Progress
                  if (_isUploading) ...[
                    SizedBox(height: 10.h),
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Mengunggah foto... ${(_uploadProgress * 100).toInt()}%',
                          style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],

                  // Upload Success
                  if (_uploadedPhotoUrls.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            '${_uploadedPhotoUrls.length} foto berhasil diunggah',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                SizedBox(height: 20.h),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Catatan Tambahan (Opsional)',
                    hintText: 'Catatan kondisi barang, lokasi penerimaan, dll.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: const Icon(Icons.note, color: Colors.green),
                  ),
                  maxLines: 3,
                ),

                SizedBox(height: 30.h),

                // Complete Delivery Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _uploadedPhotoUrls.isNotEmpty && !_isLoading
                        ? _completeDelivery
                        : null,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Selesaikan Pengiriman',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
