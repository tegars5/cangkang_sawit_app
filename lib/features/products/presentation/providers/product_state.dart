import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

/// State for Products feature
class ProductState extends Equatable {
  final List<Product> products;
  final Product? selectedProduct;
  final bool isLoading;
  final String? errorMessage;
  final String? searchQuery;

  const ProductState({
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery,
  });

  /// Initial state
  const ProductState.initial()
    : products = const [],
      selectedProduct = null,
      isLoading = false,
      errorMessage = null,
      searchQuery = null;

  /// Loading state
  const ProductState.loading()
    : products = const [],
      selectedProduct = null,
      isLoading = true,
      errorMessage = null,
      searchQuery = null;

  /// Success state with products
  const ProductState.success(List<Product> products)
    : products = products,
      selectedProduct = null,
      isLoading = false,
      errorMessage = null,
      searchQuery = null;

  /// Error state
  const ProductState.error(String message)
    : products = const [],
      selectedProduct = null,
      isLoading = false,
      errorMessage = message,
      searchQuery = null;

  ProductState copyWith({
    List<Product>? products,
    Product? selectedProduct,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    bool clearSelectedProduct = false,
    bool clearError = false,
    bool clearSearchQuery = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      selectedProduct: clearSelectedProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
    products,
    selectedProduct,
    isLoading,
    errorMessage,
    searchQuery,
  ];
}
