import 'package:flutter/material.dart';

/// Safe wrapper untuk dashboard screens yang handle navigation errors
class SafeDashboardWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const SafeDashboardWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // Prevent back button from causing Navigator errors
        // Already handled by canPop: false
      },
      child: child,
    );
  }
}
