Task: Fix Admin Orders Page Crash (Null Safety)
Context: The user is experiencing a crash/error on the AdminOrdersPage. It is likely due to a Null Safety issue when parsing the Order model, specifically when accessing related data like users (Mitra) or order_items.

Objective: Make the Order model and AdminOrdersPage robust so it doesn't crash even if some data is missing.

Instructions:

Update lib/data/models/order.dart (Crucial):

Modify the fromMap or fromJson factory.

Safeguard Relations: When parsing related tables (like users or mitra), use a check.

Example Fix:

Dart

// Instead of: user: UserProfile.fromMap(map['users'])
// Use this:
user: map['users'] != null ? UserProfile.fromMap(map['users']) : null,
Safeguard Fields: Ensure required fields like totalPrice or status have fallback values (e.g., 0 or 'pending') if they are null in the database.

Update lib/features/admin/pages/admin_orders_page.dart:

In the ListView.builder, when displaying the order card:

Check if order.user is null before accessing order.user.name.

Use a fallback text like "Unknown User" or "Mitra Terhapus".

Example: Text(order.user?.name ?? 'Unknown Mitra').

Update lib/shared/repositories/order_repository.dart:

Ensure the .select() query correctly includes the relations needed, e.g., .select('*, users(*), order_items(*)').

Add a try-catch block around the fetch to log the specific error to the console (debugPrint).

Deliverables:

A crash-proof Order model.


Task: Fix Admin Products Page Error (Null Safety & Parsing)
Context: The user is reporting a crash/error on the Admin Products page, similar to the Orders page. This is likely due to Null Safety issues in the Product model (e.g., parsing price or stock) or UI rendering issues when a field is missing.

Objective: Harden the Product model and the AdminProductsPage to prevent crashes due to bad or missing data.

Action Items:

Update lib/data/models/product.dart (Crucial):

Safe Number Parsing: Ensure price and stock can handle both int and double from Supabase.

Fix: price: (map['price'] as num?)?.toDouble() ?? 0.0,

Fix: stock: (map['stock'] as num?)?.toInt() ?? 0,

Null Fallbacks: Ensure description defaults to an empty string '' if null.

Boolean Safety: Ensure isActive (or is_active) defaults to false if null.

Update lib/shared/repositories/product_repository.dart:

Wrap the getAllProducts (or fetchProducts) logic in a try-catch block.

Add debugPrint('Error fetching products: $e'); so we can see the exact error in the console.

Ensure the .select() query matches the table schema.

Update lib/features/admin/pages/admin_products_page.dart:

In the ListView.builder:

Check for nulls before displaying text.

Example: Text(product.name ?? 'No Name')

Example: Text('Stok: ${product.stock ?? 0}')

Add a logic to show a friendly "Gagal memuat produk" message if the list is null/error, instead of a red screen.

Deliverables:

A robust Product model that handles null/numeric types safely.

A crash-free AdminProductsPage.