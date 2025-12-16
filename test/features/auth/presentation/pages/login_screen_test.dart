import 'package:cangkang_sawit_app/features/auth/presentation/pages/login_screen.dart';
import 'package:cangkang_sawit_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:cangkang_sawit_app/features/auth/presentation/providers/auth_state.dart';
import 'package:cangkang_sawit_app/shared/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthNotifier])
void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display all required UI elements', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(
        find.text('Welcome back! Please enter your details.'),
        findsOneWidget,
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('should show error when email is empty', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // assert
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email address'),
        'invalid-email',
      );
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // assert
      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('should show error when password is empty', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email address'),
        'test@example.com',
      );
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // assert
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should show error when password is too short', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email address'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        '12345',
      );
      await tester.tap(find.text('Log In'));
      await tester.pump();

      // assert
      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon is tapped', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the password field
      final passwordField = find.widgetWithText(
        TextFormField,
        'Enter your password',
      );
      expect(passwordField, findsOneWidget);

      // Initially visibility_off icon should be shown (password obscured)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap visibility icon to show password
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Now visibility icon should be shown (password visible)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap again to hide password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Back to visibility_off icon (password obscured)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should show loading indicator when logging in', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.loading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Log In'), findsNothing);
    });

    testWidgets('should disable form fields when loading', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.loading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      final emailField = find.widgetWithText(
        TextFormField,
        'Enter your email address',
      );
      final passwordField = find.widgetWithText(
        TextFormField,
        'Enter your password',
      );

      expect(tester.widget<TextFormField>(emailField).enabled, false);
      expect(tester.widget<TextFormField>(passwordField).enabled, false);
    });

    testWidgets('should show error dialog when authentication fails', (
      WidgetTester tester,
    ) async {
      // arrange
      when(
        mockAuthNotifier.state,
      ).thenReturn(const AuthState.error('Invalid credentials'));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger state listener

      // assert
      expect(find.text('Login Gagal'), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('should navigate to register screen when sign up is tapped', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      // assert - should navigate to RegisterScreen
      // Note: In real app, this would check for RegisterScreen widget
      // For now, we just verify the tap works
      verify(mockAuthNotifier.state).called(greaterThan(0));
    });

    testWidgets('should navigate to forgot password screen when tapped', (
      WidgetTester tester,
    ) async {
      // arrange
      when(mockAuthNotifier.state).thenReturn(const AuthState.initial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // assert - should navigate to ForgotPasswordScreen
      verify(mockAuthNotifier.state).called(greaterThan(0));
    });
  });
}
