/// Model untuk Product (Master Data Produk) - products table
class Product {
  /// Helper method untuk parsing number ke double dengan aman
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  final String id;
  final String name;
  final String? description;
  final double pricePerTon;
  final String unit;
  final double stockAvailable;
  final double minimumOrder;
  final String category;
  final String? productCode;
  final String? specifications;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.pricePerTon,
    this.unit = 'ton',
    this.stockAvailable = 0,
    this.minimumOrder = 1,
    this.category = 'Palm Shell',
    this.productCode,
    this.specifications,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      pricePerTon: _parseToDouble(json['price_per_ton']) ?? 0.0,
      unit: json['unit'] as String? ?? 'ton',
      stockAvailable: _parseToDouble(json['stock_available']) ?? 0.0,
      minimumOrder: _parseToDouble(json['minimum_order']) ?? 1.0,
      category: json['category'] as String? ?? 'Palm Shell',
      productCode: json['product_code'] as String?,
      specifications: json['specifications'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_ton': pricePerTon,
      'unit': unit,
      'stock_available': stockAvailable,
      'minimum_order': minimumOrder,
      'category': category,
      'product_code': productCode,
      'specifications': specifications,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Helper method untuk format price
  String get formattedPrice {
    return 'Rp ${pricePerTon.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/$unit';
  }

  /// Backward compatibility getter
  double get price => pricePerTon;

  /// Helper method untuk cek stock availability
  bool get hasStock => stockAvailable > 0;

  /// Helper method untuk format stock
  String get formattedStock {
    return '${stockAvailable.toStringAsFixed(1)} $unit';
  }

  /// Helper method untuk display nama lengkap dengan satuan
  String get displayName => '$name ($unit)';

  /// Alias untuk stockAvailable - untuk kemudahan akses
  double get stock => stockAvailable;

  /// Alias untuk minimumOrder - untuk kompatibilitas
  double get minOrder => minimumOrder;

  /// Helper method untuk cek apakah bisa order dengan quantity tertentu
  bool canOrder(double quantity) {
    return quantity >= minimumOrder && quantity <= stockAvailable;
  }

  /// Helper method untuk validasi order quantity
  String? validateOrderQuantity(double quantity) {
    if (quantity < minimumOrder) {
      return 'Minimum order ${minimumOrder.toStringAsFixed(1)} $unit';
    }
    if (quantity > stockAvailable) {
      return 'Stok tidak mencukupi (tersedia: ${stockAvailable.toStringAsFixed(1)} $unit)';
    }
    return null;
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? pricePerTon,
    String? unit,
    double? stockAvailable,
    double? minimumOrder,
    String? category,
    String? productCode,
    String? specifications,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerTon: pricePerTon ?? this.pricePerTon,
      unit: unit ?? this.unit,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      category: category ?? this.category,
      productCode: productCode ?? this.productCode,
      specifications: specifications ?? this.specifications,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, pricePerTon: $pricePerTon, unit: $unit, stockAvailable: $stockAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
