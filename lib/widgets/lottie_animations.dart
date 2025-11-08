import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart'; // Commented out until package is working

/// Professional success animation widget dengan Lottie
class LottieSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onComplete;
  final Duration displayDuration;

  const LottieSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onComplete,
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  State<LottieSuccessDialog> createState() => _LottieSuccessDialogState();

  /// Show success dialog dengan animation
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onComplete,
    Duration displayDuration = const Duration(seconds: 3),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LottieSuccessDialog(
        title: title,
        message: message,
        onComplete: onComplete,
        displayDuration: displayDuration,
      ),
    );
  }
}

class _LottieSuccessDialogState extends State<LottieSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismissDialog();
      }
    });
  }

  void _dismissDialog() async {
    await _fadeController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Success Animation
              SizedBox(
                height: 120.h,
                width: 120.w,
                child: _buildLottieAnimation(),
              ),

              SizedBox(height: 16.h),

              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // Message
              Text(
                widget.message,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),

              // Close Button (optional - auto closes)
              TextButton(
                onPressed: _dismissDialog,
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    // Professional animated success icon
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.6 + (_controller.value * 0.4),
            child: Transform.rotate(
              angle: _controller.value * 0.5,
              child: Icon(
                Icons.check_circle,
                size: 80.w,
                color: Color.lerp(
                  Colors.green[400],
                  Colors.green[600],
                  _controller.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loading animation widget
class LottieLoadingDialog extends StatefulWidget {
  final String message;

  const LottieLoadingDialog({super.key, this.message = 'Loading...'});

  @override
  State<LottieLoadingDialog> createState() => _LottieLoadingDialogState();

  /// Show loading dialog
  static Future<T?> show<T>(
    BuildContext context, {
    String message = 'Loading...',
    required Future<T> future,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LottieLoadingDialog(message: message),
    );

    try {
      // Wait for future to complete
      final result = await future;

      // Dismiss loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return result;
    } catch (e) {
      // Dismiss loading on error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }
}

class _LottieLoadingDialogState extends State<LottieLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation
            SizedBox(
              height: 60.h,
              width: 60.w,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2.0 * 3.14159,
                    child: CircularProgressIndicator(
                      strokeWidth: 4.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[600]!,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            Text(
              widget.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Success snackbar dengan animation
class LottieSnackbar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: duration,
      ),
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: duration,
      ),
    );
  }
}

/// Professional success page untuk hasil operasi besar
class SuccessPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const SuccessPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText = 'Continue',
    this.onButtonPressed,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 150.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[200]!, width: 2.w),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 100.w,
                    color: Colors.green[600],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16.h),

              // Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.subtitle,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 60.h),

              // Continue Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      widget.buttonText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
}
