import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'controllers/registration_controller.dart';
import 'widgets/registration_form_fields.dart';
import 'widgets/location_picker.dart';
import 'registration_success_screen.dart';
import 'login_screen.dart';

/// Clean, modular registration screen
/// Uses RegistrationController for business logic
/// No direct Supabase calls in UI
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _locationPickerKey = GlobalKey<LocationPickerState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedRole = 'Mitra Bisnis';
  int _currentStep = 0;
  LatLng _selectedLocation = const LatLng(-6.2088, 106.8456); // Default Jakarta

  final List<String> _roles = ['Mitra Bisnis', 'driver'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to registration state changes
    ref.listen<RegistrationState>(registrationControllerProvider, (
      previous,
      next,
    ) {
      if (next.isSuccess) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistrationSuccessScreen(),
          ),
        );
        // Reset state
        ref.read(registrationControllerProvider.notifier).reset();
      } else if (next.error != null) {
        // Show error dialog
        _showErrorDialog('Registrasi Gagal', next.error!);
        // Reset state
        ref.read(registrationControllerProvider.notifier).reset();
      }
    });

    final registrationState = ref.watch(registrationControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: 32.h),

                // Role Selection
                RoleDropdown(
                  value: _selectedRole,
                  items: _roles,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      _currentStep = 0; // Reset to first step
                    });
                  },
                ),

                // Stepper for Mitra Bisnis
                if (_selectedRole == 'Mitra Bisnis')
                  _buildMitraStepper(registrationState)
                else
                  _buildForm(registrationState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Akun Baru',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Daftar untuk mulai menggunakan layanan kami',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMitraStepper(RegistrationState state) {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < 1) {
          if (_validateCurrentStep()) {
            setState(() {
              _currentStep++;
            });
          }
        } else {
          _handleRegistration();
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
        }
      },
      controlsBuilder: (context, details) {
        return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: state.isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep == 1 ? 'Daftar' : 'Lanjut',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              if (_currentStep > 0) ...[
                SizedBox(width: 12.w),
                TextButton(
                  onPressed: state.isLoading ? null : details.onStepCancel,
                  child: Text(
                    'Kembali',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('Informasi Akun'),
          content: _buildAccountInfoStep(),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Informasi Perusahaan & Lokasi'),
          content: _buildCompanyInfoStep(),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildAccountInfoStep() {
    return Form(
      key: _step1FormKey,
      child: Column(
        children: [
          RegistrationTextField(
            controller: _nameController,
            label: 'Nama Lengkap',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lengkap harus diisi';
              }
              return null;
            },
          ),
          RegistrationTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email harus diisi';
              }
              if (!value.contains('@')) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          PasswordField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password harus diisi';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoStep() {
    return Form(
      key: _step2FormKey,
      child: Column(
        children: [
          RegistrationTextField(
            controller: _companyController,
            label: 'Nama Perusahaan',
            icon: Icons.business,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama perusahaan harus diisi';
              }
              return null;
            },
          ),
          RegistrationTextField(
            controller: _jobTitleController,
            label: 'Jabatan',
            icon: Icons.work,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jabatan harus diisi';
              }
              return null;
            },
          ),
          RegistrationTextField(
            controller: _phoneController,
            label: 'Nomor Telepon',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor telepon harus diisi';
              }
              return null;
            },
          ),
          // Address field with location button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RegistrationTextField(
                controller: _addressController,
                label: 'Alamat Perusahaan (akan terisi otomatis dari peta)',
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) {
                  // Optional - will be auto-filled from location picker
                  return null;
                },
              ),
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isLoadingAddress
                      ? null
                      : _fillAddressFromCurrentLocation,
                  icon: _isLoadingAddress
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF2E7D32),
                          ),
                        )
                      : Icon(
                          Icons.my_location,
                          size: 18.sp,
                          color: const Color(0xFF2E7D32),
                        ),
                  label: Text(
                    'Gunakan Lokasi Saat Ini',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Location Picker
          LocationPicker(
            key: _locationPickerKey,
            initialLocation: _selectedLocation,
            onLocationChanged: (location) {
              _selectedLocation = location;
            },
            onAddressChanged: (address) {
              // Update address controller with geocoded address
              _addressController.text = address;
            },
          ),
        ],
      ),
    );
  }

  bool _isLoadingAddress = false;

  Future<void> _fillAddressFromCurrentLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Save location and update map
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // Update LocationPicker widget to show new location on map
      _locationPickerKey.currentState?.updateLocation(_selectedLocation);

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isEmpty
              ? place.subLocality!
              : ', ${place.subLocality}';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty
              ? place.administrativeArea!
              : ', ${place.administrativeArea}';
        }

        _addressController.text = address.isEmpty
            ? 'Alamat tidak ditemukan'
            : address;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alamat berhasil diisi dari lokasi saat ini'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  Widget _buildForm(RegistrationState state) {
    return Column(
      children: [
        _buildAccountInfoStep(),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _handleRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: state.isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1FormKey.currentState?.validate() ?? false;
      case 1:
        return _step2FormKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _handleRegistration() {
    print('🔍 DEBUG: _handleRegistration called');
    print('🔍 DEBUG: currentStep = $_currentStep');
    print('🔍 DEBUG: Validating step...');

    final isValid = _validateCurrentStep();
    print('🔍 DEBUG: Validation result = $isValid');

    if (!isValid) {
      print('❌ DEBUG: Validation failed, returning');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua field yang diperlukan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('✅ DEBUG: Validation passed, calling registration...');
    // Call controller to handle registration
    ref
        .read(registrationControllerProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          role: _selectedRole,
          companyName: _selectedRole == 'Mitra Bisnis'
              ? _companyController.text.trim()
              : null,
          jobTitle: _selectedRole == 'Mitra Bisnis'
              ? _jobTitleController.text.trim()
              : null,
          phone: _selectedRole == 'Mitra Bisnis'
              ? _phoneController.text.trim()
              : null,
          address: _selectedRole == 'Mitra Bisnis'
              ? _addressController.text.trim()
              : null,
          latitude: _selectedRole == 'Mitra Bisnis'
              ? _selectedLocation.latitude
              : null,
          longitude: _selectedRole == 'Mitra Bisnis'
              ? _selectedLocation.longitude
              : null,
        );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
