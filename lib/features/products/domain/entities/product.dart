import 'package:equatable/equatable.dart';

/// Pure domain entity for Product
/// No JSON serialization - that's handled by data layer
class Product extends Equatable {
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
  final String? imageUrl;
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
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if product has stock available
  bool get hasStock => stockAvailable > 0;

  /// Check if product is available for order
  bool get isAvailable => isActive && hasStock;

  /// Validate if quantity can be ordered
  bool canOrder(double quantity) {
    return quantity >= minimumOrder && quantity <= stockAvailable;
  }

  /// Get validation message for order quantity
  String? validateOrderQuantity(double quantity) {
    if (quantity < minimumOrder) {
      return 'Minimum order ${minimumOrder.toStringAsFixed(1)} $unit';
    }
    if (quantity > stockAvailable) {
      return 'Stok tidak mencukupi (tersedia: ${stockAvailable.toStringAsFixed(1)} $unit)';
    }
    return null;
  }

  /// Calculate total price for given quantity
  double calculateTotalPrice(double quantity) {
    return pricePerTon * quantity;
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    pricePerTon,
    unit,
    stockAvailable,
    minimumOrder,
    category,
    productCode,
    specifications,
    imageUrl,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $pricePerTon, stock: $stockAvailable)';
}
