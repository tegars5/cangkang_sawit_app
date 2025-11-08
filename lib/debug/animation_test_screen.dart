import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/lottie_animations.dart';

/// Widget untuk test professional animations
class AnimationTestScreen extends StatefulWidget {
  const AnimationTestScreen({super.key});

  @override
  State<AnimationTestScreen> createState() => _AnimationTestScreenState();
}

class _AnimationTestScreenState extends State<AnimationTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Professional Animations'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Professional UI Test',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 40.h),

            // Test Success Dialog
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  LottieSuccessDialog.show(
                    context,
                    title: 'Success!',
                    message: 'Test berhasil dengan animasi profesional!',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Show Success Animation',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Test Loading Dialog
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await LottieLoadingDialog.show(
                    context,
                    message: 'Loading test...',
                    future: Future.delayed(const Duration(seconds: 2)),
                  );

                  LottieSnackbar.showSuccess(
                    context,
                    message: 'Loading selesai!',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Show Loading Animation',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Test Error Snackbar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  LottieSnackbar.showError(
                    context,
                    message: 'Test error message dengan style professional',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Show Error Notification',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Test Success Page
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessPage(
                        title: 'Operasi Berhasil!',
                        subtitle: 'Semua test animasi berfungsi dengan baik.',
                        buttonText: 'Kembali',
                        onButtonPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Show Success Page',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            Text(
              'Semua animasi menggunakan custom Flutter animations\nuntuk performa optimal!',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
