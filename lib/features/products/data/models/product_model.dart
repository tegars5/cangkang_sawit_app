import '../../domain/entities/product.dart' as domain;

/// Data model for Product with JSON serialization
/// Extends domain entity and adds fromJson/toJson
class ProductModel extends domain.Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.pricePerTon,
    super.unit,
    super.stockAvailable,
    super.minimumOrder,
    super.category,
    super.productCode,
    super.specifications,
    super.imageUrl,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  /// Helper method for safe number parsing
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
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
      imageUrl: json['image_url'] as String?,
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
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert domain entity to model
  factory ProductModel.fromEntity(domain.Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      pricePerTon: product.pricePerTon,
      unit: product.unit,
      stockAvailable: product.stockAvailable,
      minimumOrder: product.minimumOrder,
      category: product.category,
      productCode: product.productCode,
      specifications: product.specifications,
      imageUrl: product.imageUrl,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// Convert model to domain entity
  domain.Product toEntity() {
    return domain.Product(
      id: id,
      name: name,
      description: description,
      pricePerTon: pricePerTon,
      unit: unit,
      stockAvailable: stockAvailable,
      minimumOrder: minimumOrder,
      category: category,
      productCode: productCode,
      specifications: specifications,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
