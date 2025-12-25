import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/get_assigned_deliveries.dart';
import '../../domain/usecases/get_today_deliveries.dart';
import '../../domain/usecases/mark_delivery_as_delivered.dart';
import '../../domain/usecases/mark_delivery_as_picked_up.dart';
import '../../domain/usecases/update_delivery_status.dart';
import '../../domain/usecases/upload_proof_of_delivery.dart';
import 'driver_state.dart';

/// Notifier for managing driver delivery state and operations
class DriverNotifier extends Notifier<DriverState> {
  late final GetAssignedDeliveries _getAssignedDeliveries;
  late final GetTodayDeliveries _getTodayDeliveries;
  late final UpdateDeliveryStatus _updateDeliveryStatus;
  late final MarkDeliveryAsPickedUp _markDeliveryAsPickedUp;
  late final MarkDeliveryAsDelivered _markDeliveryAsDelivered;
  late final UploadProofOfDelivery _uploadProofOfDelivery;

  @override
  DriverState build() {
    // Initialize use cases from dependency injection
    _getAssignedDeliveries = ref.read(getAssignedDeliveriesUseCaseProvider);
    _getTodayDeliveries = ref.read(getTodayDeliveriesUseCaseProvider);
    _updateDeliveryStatus = ref.read(updateDeliveryStatusUseCaseProvider);
    _markDeliveryAsPickedUp = ref.read(markDeliveryAsPickedUpUseCaseProvider);
    _markDeliveryAsDelivered = ref.read(markDeliveryAsDeliveredUseCaseProvider);
    _uploadProofOfDelivery = ref.read(uploadProofOfDeliveryUseCaseProvider);

    return const DriverState();
  }

  /// Load all assigned deliveries for a driver
  Future<void> loadAssignedDeliveries(String driverId, {String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAssignedDeliveries(
      GetAssignedDeliveriesParams(driverId: driverId),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (deliveries) => state = state.copyWith(
        isLoading: false,
        deliveries: deliveries,
        clearError: true,
      ),
    );
  }

  /// Load today's deliveries for a driver
  Future<void> loadTodayDeliveries(String driverId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getTodayDeliveries(driverId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (deliveries) => state = state.copyWith(
        isLoading: false,
        deliveries: deliveries,
        clearError: true,
      ),
    );
  }

  /// Mark delivery as picked up
  Future<bool> markPickedUp({
    required String deliveryId,
    required String driverId,
    DateTime? pickupDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _markDeliveryAsPickedUp(deliveryId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (delivery) {
        state = state.copyWith(
          isLoading: false,
          selectedDelivery: delivery,
          successMessage: 'Barang berhasil diambil',
          clearError: true,
        );
        // Refresh list
        loadAssignedDeliveries(driverId);
        return true;
      },
    );
  }

  /// Mark delivery as delivered
  Future<bool> markDelivered({
    required String deliveryId,
    required String driverId,
    DateTime? deliveryDate,
    String? recipientName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _markDeliveryAsDelivered(
      MarkDeliveryAsDeliveredParams(
        shipmentId: deliveryId,
        notes: recipientName != null ? 'Received by: $recipientName' : null,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (delivery) {
        state = state.copyWith(
          isLoading: false,
          selectedDelivery: delivery,
          successMessage: 'Barang berhasil dikirim',
          clearError: true,
        );
        // Refresh list
        loadAssignedDeliveries(driverId);
        return true;
      },
    );
  }

  /// Update delivery status
  Future<bool> updateStatus({
    required String deliveryId,
    required String driverId,
    required String status,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateDeliveryStatus(
      UpdateDeliveryStatusParams(shipmentId: deliveryId, status: status),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (delivery) {
        state = state.copyWith(
          isLoading: false,
          selectedDelivery: delivery,
          successMessage: 'Status berhasil diupdate',
          clearError: true,
        );
        // Refresh list
        loadAssignedDeliveries(driverId);
        return true;
      },
    );
  }

  /// Upload proof of delivery
  Future<bool> uploadProof({
    required String deliveryId,
    required String driverId,
    required String proofUrl,
    String? recipientSignature,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _uploadProofOfDelivery(
      UploadProofOfDeliveryParams(shipmentId: deliveryId, imagePath: proofUrl),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (imageUrl) {
        // uploadProofOfDelivery returns String (image URL), not Shipment
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Bukti pengiriman berhasil diupload',
          clearError: true,
        );
        // Refresh list
        loadAssignedDeliveries(driverId);
        return true;
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Clear selected delivery
  void clearSelected() {
    state = state.copyWith(clearSelected: true);
  }
}
