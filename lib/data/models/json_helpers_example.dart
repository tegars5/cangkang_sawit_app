/// Example usage of JsonHelpers for safe JSON parsing
/// Demonstrasi cara menggunakan JsonHelpers dalam model parsing

import '../models/json_helpers.dart';

/// Contoh Model yang menggunakan JsonHelpers
class ExampleModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final bool isActive;
  final DateTime? createdAt;
  final List<String> tags;

  ExampleModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isActive,
    this.createdAt,
    required this.tags,
  });

  /// Safe parsing dengan JsonHelpers
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: JsonHelpers.safeString(json['id']),
      name: JsonHelpers.safeString(json['name'], defaultValue: 'Unknown'),

      // Safe double parsing - tidak akan crash meski data dari DB adalah int
      price: JsonHelpers.safeDouble(json['price']),

      // Safe int parsing - mendukung konversi dari double/string
      quantity: JsonHelpers.safeInt(json['quantity']),

      // Safe bool parsing - mendukung 0/1, "true"/"false"
      isActive: JsonHelpers.safeBool(json['is_active'], defaultValue: true),

      // Safe DateTime parsing
      createdAt: JsonHelpers.safeDateTime(json['created_at']),

      // Safe List parsing dengan converter function
      tags: JsonHelpers.safeList<String>(
        json['tags'],
        (item) => JsonHelpers.safeString(item),
        defaultValue: [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'tags': tags,
    };
  }
}

/// Contoh data yang mungkin bermasalah dari Supabase
void demonstrateUsage() {
  // Data problematik dari Supabase (mixed types)
  final problematicData = {
    'id': 'product-1',
    'name': 'Palm Shell',
    'price': 1500, // int dari database, tapi model butuh double
    'quantity': '10', // string dari form input
    'is_active': 1, // int 1/0 dari database, tapi model butuh bool
    'created_at': '2024-11-21T10:30:00Z',
    'tags': ['grade-a', 'premium', 'organic'], // list string
  };

  // SEBELUM JsonHelpers (AKAN ERROR):
  // price: json['price'] as double, // ❌ CRASH! int is not subtype of double

  // SESUDAH JsonHelpers (AMAN):
  final model = ExampleModel.fromJson(problematicData);
  print('✅ Model berhasil dibuat: ${model.name} - Rp${model.price}');

  // Test dengan data null/missing
  final incompleteData = {
    'id': 'product-2',
    // name missing - akan dapat default
    // price missing - akan dapat 0.0
    // quantity null
    'quantity': null,
    'is_active': 'false', // string boolean
    // tags missing - akan dapat []
  };

  final safeModel = ExampleModel.fromJson(incompleteData);
  print('✅ Model aman dari null: ${safeModel.name} - ${safeModel.isActive}');
}

/// Migration guide dari parsing lama ke JsonHelpers
class MigrationExamples {
  // ❌ SEBELUM (Error prone):
  static Map<String, dynamic> oldParsing(Map<String, dynamic> json) {
    return {
      'total_quantity': json['total_quantity'] as double, // CRASH jika int
      'price': json['price'] as double, // CRASH jika int
      'is_active': json['is_active'] as bool, // CRASH jika int 0/1
    };
  }

  // ✅ SESUDAH (Safe):
  static Map<String, dynamic> newParsing(Map<String, dynamic> json) {
    return {
      'total_quantity': JsonHelpers.safeDouble(json['total_quantity']),
      'price': JsonHelpers.safeDouble(json['price']),
      'is_active': JsonHelpers.safeBool(json['is_active']),
    };
  }

  // ✅ ATAU dengan fallback custom:
  static Map<String, dynamic> newParsingWithDefaults(
    Map<String, dynamic> json,
  ) {
    return {
      'total_quantity': JsonHelpers.safeDouble(
        json['total_quantity'],
        defaultValue: 1.0,
      ),
      'price': JsonHelpers.safeDouble(json['price'], defaultValue: 0.0),
      'is_active': JsonHelpers.safeBool(json['is_active'], defaultValue: true),
    };
  }
}
