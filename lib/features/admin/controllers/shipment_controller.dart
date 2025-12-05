import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/shipment_service.dart';

/// Shipment state
class ShipmentState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> shipments;
  final Map<String, dynamic>? selectedShipment;

  const ShipmentState({
    this.isLoading = false,
    this.error,
    this.shipments = const [],
    this.selectedShipment,
  });

  ShipmentState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? shipments,
    Map<String, dynamic>? selectedShipment,
  }) {
    return ShipmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      shipments: shipments ?? this.shipments,
      selectedShipment: selectedShipment ?? this.selectedShipment,
    );
  }
}

/// Shipment controller for managing shipment operations
class ShipmentController extends Notifier<ShipmentState> {
  @override
  ShipmentState build() => const ShipmentState();

  /// Get all shipments
  Future<void> getShipments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final shipments = await ShipmentService.getShipments();
      state = state.copyWith(isLoading: false, shipments: shipments);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Get shipment by ID
  Future<void> getShipmentById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final shipment = await ShipmentService.getShipmentById(id);

      if (shipment != null) {
        state = state.copyWith(isLoading: false, selectedShipment: shipment);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Shipment tidak ditemukan',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Filter shipments by status
  List<Map<String, dynamic>> filterByStatus(String status) {
    if (status.isEmpty || status == 'All Shipments') {
      return state.shipments;
    }

    return state.shipments.where((shipment) {
      final shipmentStatus = shipment['status']?.toString() ?? '';
      return shipmentStatus == status;
    }).toList();
  }

  /// Search shipments
  List<Map<String, dynamic>> searchShipments(String query) {
    if (query.isEmpty) return state.shipments;

    return state.shipments.where((shipment) {
      final shipmentNumber =
          shipment['shipmentNumber']?.toString().toLowerCase() ?? '';
      final driver = shipment['driver']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return shipmentNumber.contains(searchLower) ||
          driver.contains(searchLower);
    }).toList();
  }

  /// Reset state
  void reset() {
    state = const ShipmentState();
  }
}

/// Shipment controller provider
final shipmentControllerProvider =
    NotifierProvider<ShipmentController, ShipmentState>(() {
      return ShipmentController();
    });
