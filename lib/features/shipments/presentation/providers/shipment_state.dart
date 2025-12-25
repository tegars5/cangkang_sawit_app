import 'package:equatable/equatable.dart';
import '../../domain/entities/shipment.dart';

/// State for shipment operations
class ShipmentState extends Equatable {
  final List<Shipment> shipments;
  final Shipment? selectedShipment;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ShipmentState({
    this.shipments = const [],
    this.selectedShipment,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
    shipments,
    selectedShipment,
    isLoading,
    error,
    successMessage,
  ];

  ShipmentState copyWith({
    List<Shipment>? shipments,
    Shipment? selectedShipment,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return ShipmentState(
      shipments: shipments ?? this.shipments,
      selectedShipment: clearSelected
          ? null
          : (selectedShipment ?? this.selectedShipment),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
      successMessage: clearSuccess ? null : successMessage,
    );
  }
}
