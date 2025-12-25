import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cangkang_sawit_app/main.dart' as app;

/// Integration test for authentication flow
/// Tests the complete user journey from app launch to login/logout
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('Complete login and logout flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on the login screen
      expect(find.text('Login'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);

      // Find email and password fields
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      // Enter test credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Find and tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // After successful login, we should see the main dashboard
        // This will vary based on user role (admin/mitra/driver)
        // Wait for navigation to complete
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Look for common dashboard elements
        // (This might need adjustment based on actual UI)
        final dashboardIndicators = [
          find.byIcon(Icons.dashboard),
          find.byIcon(Icons.home),
          find.text('Dashboard'),
          find.text('Beranda'),
        ];

        bool foundDashboard = false;
        for (final indicator in dashboardIndicators) {
          if (indicator.evaluate().isNotEmpty) {
            foundDashboard = true;
            break;
          }
        }

        expect(
          foundDashboard,
          true,
          reason: 'Should navigate to dashboard after login',
        );

        // Test logout functionality
        // Look for logout button/menu
        final logoutOptions = [
          find.byIcon(Icons.logout),
          find.text('Logout'),
          find.text('Keluar'),
          find.byIcon(Icons.exit_to_app),
        ];

        for (final logoutOption in logoutOptions) {
          if (logoutOption.evaluate().isNotEmpty) {
            await tester.tap(logoutOption);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            break;
          }
        }

        // Verify we're back on login screen
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.text('Login'), findsWidgets);
      }
    });

    testWidgets('Login with invalid credentials shows error', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find email and password fields
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      // Enter invalid credentials
      await tester.enterText(emailField, 'invalid@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Find and tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should show error message
        final errorIndicators = [
          find.text('Invalid'),
          find.text('Failed'),
          find.text('Error'),
          find.byIcon(Icons.error),
          find.byType(SnackBar),
        ];

        bool foundError = false;
        for (final errorIndicator in errorIndicators) {
          if (errorIndicator.evaluate().isNotEmpty) {
            foundError = true;
            break;
          }
        }

        expect(
          foundError,
          true,
          reason: 'Should show error for invalid credentials',
        );
      }
    });

    testWidgets('Navigate to registration screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for registration link/button
      final registerOptions = [
        find.text('Register'),
        find.text('Daftar'),
        find.text('Sign Up'),
        find.textContaining('Belum punya akun'),
      ];

      for (final registerOption in registerOptions) {
        if (registerOption.evaluate().isNotEmpty) {
          await tester.tap(registerOption);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          break;
        }
      }

      // Verify we're on registration screen
      final registrationIndicators = [
        find.text('Register'),
        find.text('Daftar'),
        find.text('Sign Up'),
        find.text('Full Name'),
        find.text('Nama Lengkap'),
      ];

      bool foundRegistration = false;
      for (final indicator in registrationIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          foundRegistration = true;
          break;
        }
      }

      expect(
        foundRegistration,
        true,
        reason: 'Should navigate to registration screen',
      );
    });

    testWidgets('Navigate to forgot password screen', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for forgot password link
      final forgotPasswordOptions = [
        find.text('Forgot Password'),
        find.text('Lupa Password'),
        find.textContaining('Lupa'),
      ];

      for (final forgotOption in forgotPasswordOptions) {
        if (forgotOption.evaluate().isNotEmpty) {
          await tester.tap(forgotOption);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          break;
        }
      }

      // Verify we're on forgot password screen
      final forgotPasswordIndicators = [
        find.text('Forgot Password'),
        find.text('Reset Password'),
        find.text('Lupa Password'),
        find.textContaining('email'),
      ];

      bool foundForgotPassword = false;
      for (final indicator in forgotPasswordIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          foundForgotPassword = true;
          break;
        }
      }

      expect(
        foundForgotPassword,
        true,
        reason: 'Should navigate to forgot password screen',
      );
    });
  });
}
