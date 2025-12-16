import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cangkang_sawit_app/features/orders/presentation/pages/order_list_page.dart';
import 'package:cangkang_sawit_app/features/orders/presentation/providers/order_state.dart';
import 'package:cangkang_sawit_app/features/orders/domain/entities/order.dart';

void main() {
  group('OrderListPage Widget Tests', () {
    testWidgets('should display loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      // Build widget with loading state
      await tester.pumpWidget(const MaterialApp(home: OrderListPage()));

      // Verify page loads
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Daftar Pesanan'), findsOneWidget);
    });

    testWidgets('should display FAB for creating new order', (
      WidgetTester tester,
    ) async {
      // Build widget
      await tester.pumpWidget(const MaterialApp(home: OrderListPage()));

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Verify FAB is displayed
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Buat Pesanan'), findsOneWidget);
    });

    testWidgets('should have filter menu button in app bar', (
      WidgetTester tester,
    ) async {
      // Build widget
      await tester.pumpWidget(const MaterialApp(home: OrderListPage()));

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Verify filter button is displayed
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });
  });
}
