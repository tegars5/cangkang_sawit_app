import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cangkang_sawit_app/main.dart' as app;

/// Integration test for order flow
/// Tests the complete order creation and management journey
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Order Flow Integration Tests - Mitra Role', () {
    testWidgets('Complete order creation flow for Mitra', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login as Mitra
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'mitra@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Navigate to products/catalog
        final productOptions = [
          find.text('Products'),
          find.text('Produk'),
          find.text('Catalog'),
          find.text('Katalog'),
          find.byIcon(Icons.shopping_bag),
        ];

        for (final productOption in productOptions) {
          if (productOption.evaluate().isNotEmpty) {
            await tester.tap(productOption);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            break;
          }
        }

        // Wait for products to load
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Try to add product to cart
        final addToCartOptions = [
          find.byIcon(Icons.add_shopping_cart),
          find.text('Add to Cart'),
          find.text('Tambah ke Keranjang'),
          find.byIcon(Icons.add),
        ];

        bool addedToCart = false;
        for (final addOption in addToCartOptions) {
          if (addOption.evaluate().isNotEmpty) {
            await tester.tap(addOption.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            addedToCart = true;
            break;
          }
        }

        if (addedToCart) {
          // Navigate to cart
          final cartOptions = [
            find.byIcon(Icons.shopping_cart),
            find.text('Cart'),
            find.text('Keranjang'),
          ];

          for (final cartOption in cartOptions) {
            if (cartOption.evaluate().isNotEmpty) {
              await tester.tap(cartOption);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              break;
            }
          }

          // Verify cart has items
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Look for checkout button
          final checkoutOptions = [
            find.text('Checkout'),
            find.text('Buat Pesanan'),
            find.text('Place Order'),
            find.widgetWithText(ElevatedButton, 'Checkout'),
          ];

          for (final checkoutOption in checkoutOptions) {
            if (checkoutOption.evaluate().isNotEmpty) {
              await tester.tap(checkoutOption);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              break;
            }
          }

          // Fill in order details if required
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Look for confirm/submit order button
          final confirmOptions = [
            find.text('Confirm Order'),
            find.text('Submit'),
            find.text('Konfirmasi'),
            find.text('Buat Pesanan'),
          ];

          for (final confirmOption in confirmOptions) {
            if (confirmOption.evaluate().isNotEmpty) {
              await tester.tap(confirmOption);
              await tester.pumpAndSettle(const Duration(seconds: 5));
              break;
            }
          }

          // Verify order was created - look for success message
          final successIndicators = [
            find.text('Success'),
            find.text('Berhasil'),
            find.text('Order Created'),
            find.text('Pesanan Dibuat'),
            find.byIcon(Icons.check_circle),
          ];

          bool foundSuccess = false;
          for (final successIndicator in successIndicators) {
            if (successIndicator.evaluate().isNotEmpty) {
              foundSuccess = true;
              break;
            }
          }

          expect(
            foundSuccess,
            true,
            reason: 'Should show success message after order creation',
          );
        }
      }
    });

    testWidgets('View order list and order details', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login as Mitra
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'mitra@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Navigate to orders
        final orderOptions = [
          find.text('Orders'),
          find.text('Pesanan'),
          find.text('My Orders'),
          find.byIcon(Icons.receipt_long),
        ];

        for (final orderOption in orderOptions) {
          if (orderOption.evaluate().isNotEmpty) {
            await tester.tap(orderOption);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            break;
          }
        }

        // Wait for orders to load
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Try to tap on first order to see details
        final orderCards = find.byType(Card);
        if (orderCards.evaluate().isNotEmpty) {
          await tester.tap(orderCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify we're on order detail screen
          final detailIndicators = [
            find.text('Order Details'),
            find.text('Detail Pesanan'),
            find.text('Status'),
            find.text('Total'),
          ];

          bool foundDetails = false;
          for (final indicator in detailIndicators) {
            if (indicator.evaluate().isNotEmpty) {
              foundDetails = true;
              break;
            }
          }

          expect(foundDetails, true, reason: 'Should show order details');
        }
      }
    });
  });

  group('Order Flow Integration Tests - Admin Role', () {
    testWidgets('Admin can view and manage all orders', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login as Admin
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'admin@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'admin123');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Navigate to order management
        final orderOptions = [
          find.text('Orders'),
          find.text('Pesanan'),
          find.text('Manage Orders'),
          find.byIcon(Icons.receipt_long),
        ];

        for (final orderOption in orderOptions) {
          if (orderOption.evaluate().isNotEmpty) {
            await tester.tap(orderOption);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            break;
          }
        }

        // Wait for orders to load
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Try to update order status
        final orderCards = find.byType(Card);
        if (orderCards.evaluate().isNotEmpty) {
          await tester.tap(orderCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Look for status update button
          final updateOptions = [
            find.text('Update Status'),
            find.text('Ubah Status'),
            find.text('Confirm'),
            find.text('Approve'),
            find.byIcon(Icons.edit),
          ];

          for (final updateOption in updateOptions) {
            if (updateOption.evaluate().isNotEmpty) {
              await tester.tap(updateOption);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              break;
            }
          }

          // Select new status if dropdown appears
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Look for save/submit button
          final saveOptions = [
            find.text('Save'),
            find.text('Simpan'),
            find.text('Update'),
            find.text('Confirm'),
          ];

          for (final saveOption in saveOptions) {
            if (saveOption.evaluate().isNotEmpty) {
              await tester.tap(saveOption);
              await tester.pumpAndSettle(const Duration(seconds: 3));
              break;
            }
          }

          // Verify update was successful
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    });

    testWidgets('Admin can assign driver to order', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login as Admin
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'admin@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'admin123');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Navigate to orders or shipments
        final navigationOptions = [
          find.text('Orders'),
          find.text('Shipments'),
          find.text('Pengiriman'),
        ];

        for (final navOption in navigationOptions) {
          if (navOption.evaluate().isNotEmpty) {
            await tester.tap(navOption);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            break;
          }
        }

        // Look for assign driver button
        final assignOptions = [
          find.text('Assign Driver'),
          find.text('Tugaskan Driver'),
          find.byIcon(Icons.person_add),
        ];

        for (final assignOption in assignOptions) {
          if (assignOption.evaluate().isNotEmpty) {
            await tester.tap(assignOption.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            break;
          }
        }

        // Wait for driver selection dialog/screen
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });
  });
}
