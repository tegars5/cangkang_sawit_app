import 'package:equatable/equatable.dart';
import '../../../shipments/domain/entities/shipment.dart';

/// State for driver delivery operations
class DriverState extends Equatable {
  final List<Shipment> deliveries;
  final Shipment? selectedDelivery;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const DriverState({
    this.deliveries = const [],
    this.selectedDelivery,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
    deliveries,
    selectedDelivery,
    isLoading,
    error,
    successMessage,
  ];

  /// Get today's deliveries
  List<Shipment> get todayDeliveries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return deliveries.where((d) {
      final deliveryDate = d.scheduledDeliveryDate;
      if (deliveryDate == null) return false;
      final dateOnly = DateTime(
        deliveryDate.year,
        deliveryDate.month,
        deliveryDate.day,
      );
      return dateOnly == today;
    }).toList();
  }

  /// Get pending deliveries (not picked up)
  List<Shipment> get pendingDeliveries {
    return deliveries
        .where((d) => d.status == 'pending' || d.status == 'assigned')
        .toList();
  }

  /// Get active deliveries (picked up but not delivered)
  List<Shipment> get activeDeliveries {
    return deliveries
        .where((d) => d.status == 'picked_up' || d.status == 'in_transit')
        .toList();
  }

  /// Get completed deliveries
  List<Shipment> get completedDeliveries {
    return deliveries.where((d) => d.status == 'delivered').toList();
  }

  /// Get overdue deliveries
  List<Shipment> get overdueDeliveries {
    final now = DateTime.now();
    return deliveries.where((d) {
      final scheduledDate = d.scheduledDeliveryDate;
      if (scheduledDate == null || d.status == 'delivered') return false;
      return scheduledDate.isBefore(now);
    }).toList();
  }

  /// Get priority deliveries
  List<Shipment> get priorityDeliveries {
    return deliveries
        .where((d) => d.priority == 'high' || d.priority == 'urgent')
        .toList();
  }

  DriverState copyWith({
    List<Shipment>? deliveries,
    Shipment? selectedDelivery,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return DriverState(
      deliveries: deliveries ?? this.deliveries,
      selectedDelivery: clearSelected
          ? null
          : (selectedDelivery ?? this.selectedDelivery),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error,
      successMessage: clearSuccess ? null : successMessage,
    );
  }
}
