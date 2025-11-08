// Widget test untuk Cangkang Sawit App
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Mock app untuk testing
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        title: 'Cangkang Sawit App Test',
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(child: Text('Test Screen')),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('App should load test screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TestApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that test screen loads
    expect(find.text('Test Screen'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
}
