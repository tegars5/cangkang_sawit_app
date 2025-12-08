import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/order.dart';
import '../../../shared/services/file_upload_service.dart';
import '../../../shared/services/notification_service.dart';
import '../../../core/repositories/shipment_repository.dart';
import '../../../shared/repositories/user_repository.dart';
import '../../../shared/models/user_profile.dart';

class PrepareShipmentPage extends ConsumerStatefulWidget {
  final Order order;

  const PrepareShipmentPage({super.key, required this.order});

  @override
  ConsumerState<PrepareShipmentPage> createState() =>
      _PrepareShipmentPageState();
}

class _PrepareShipmentPageState extends ConsumerState<PrepareShipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryNoteController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedDriverId;
  File? _selectedFile;
  String? _selectedFileName;
  bool _isLoading = false;
  bool _isUploadingFile = false;

  List<UserProfile> _drivers = [];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  @override
  void dispose() {
    _deliveryNoteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    try {
      final drivers = await UserRepository.getUsersByRole('driver');
      if (mounted) {
        setState(() {
          _drivers = drivers;
        });

        // Show warning if no drivers found
        if (drivers.isEmpty) {
          _showError(
            'Tidak ada driver tersedia. Pastikan ada user dengan role "driver" di database.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memuat data driver: $e');
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileSize = await file.length();

        // Check file size (max 5MB)
        if (fileSize > 5 * 1024 * 1024) {
          _showError('Ukuran file maksimal 5MB');
          return;
        }

        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      _showError('Gagal memilih file: $e');
    }
  }

  Future<void> _assignShipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDriverId == null) {
      _showError('Silakan pilih driver');
      return;
    }

    if (_selectedFile == null) {
      _showError('Silakan upload dokumen surat jalan');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload file to Supabase Storage
      setState(() {
        _isUploadingFile = true;
      });

      final fileUrl = await FileUploadService.uploadDeliveryNote(
        _selectedFile!,
        widget.order.id,
      );

      setState(() {
        _isUploadingFile = false;
      });

      // Create shipment
      final shipment = await ShipmentRepository.createShipment(
        orderId: widget.order.id,
        driverId: _selectedDriverId!,
        deliveryNoteNumber: _deliveryNoteController.text.trim(),
        destinationAddress: widget.order.deliveryAddress ?? 'N/A',
        deliveryNoteUrl: fileUrl,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        pickupDate: widget.order.pickupDate,
      );

      // Send notification to driver
      await NotificationService.sendDriverAssignmentNotification(
        driverId: _selectedDriverId!,
        shipmentId: shipment.id,
        orderNumber: widget.order.orderNumber,
      );

      // Update order status to 'shipped'
      await Supabase.instance.client
          .from('orders')
          .update({'status': 'shipped'})
          .eq('id', widget.order.id);

      if (mounted) {
        // Show success dialog with Lottie animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Success Title
                  Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Success Message
                  Text(
                    'Driver berhasil ditugaskan untuk pengiriman ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24.h),

                  // OK Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close both dialog and prepare shipment page
                        Navigator.of(context)
                          ..pop()
                          ..pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showError('Gagal menugaskan pengiriman: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingFile = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Prepare Shipment',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Details Section
              _buildSectionTitle('Order Details'),
              SizedBox(height: 12.h),
              _buildOrderDetailsCard(),
              SizedBox(height: 24.h),

              // Shipment Details Section
              _buildSectionTitle('Shipment Details'),
              SizedBox(height: 12.h),

              // Nomor Surat Jalan
              Text(
                'Nomor Surat Jalan',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _deliveryNoteController,
                decoration: InputDecoration(
                  hintText: 'Enter delivery order number',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor surat jalan harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Catatan (Optional)
              Text(
                'Catatan untuk Driver (Opsional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Hubungi customer 30 menit sebelum sampai',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Pilih Driver
              Text(
                'Pilih Driver',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _selectedDriverId,
                decoration: InputDecoration(
                  hintText: 'Select a driver',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                items: _drivers.map((driver) {
                  return DropdownMenuItem<String>(
                    value: driver.id,
                    child: Text(
                      driver.fullName ?? 'Unknown',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDriverId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Driver harus dipilih';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Dokumen Surat Jalan
              Text(
                'Dokumen Surat Jalan',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              _buildFileUploadArea(),
              SizedBox(height: 32.h),

              // Assign Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _assignShipment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Assign Shipment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildDetailRow('Order ID', widget.order.orderNumber),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Business Partner',
            widget.order.customerName ?? 'N/A',
          ),
          SizedBox(height: 12.h),
          _buildDetailRow('Destination', widget.order.deliveryAddress ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadArea() {
    return InkWell(
      onTap: _isLoading ? null : _pickFile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedFile == null) ...[
              Icon(Icons.upload_file, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 14.sp),
                  children: [
                    TextSpan(
                      text: 'Click to upload',
                      style: TextStyle(
                        color: const Color(0xFF1B5E20),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' or drag and drop',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'PDF only (MAX. 5MB)',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
            ] else ...[
              Icon(Icons.check_circle, size: 48.sp, color: Colors.green),
              SizedBox(height: 12.h),
              Text(
                _selectedFileName ?? 'File selected',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Change file'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                ),
              ),
            ],
            if (_isUploadingFile) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: 200.w,
                child: const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B5E20)),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Uploading...',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
