import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/shipment.dart';
import '../../shared/repositories/shipment_repository.dart';

// Repository provider
final shipmentRepositoryProvider = Provider<ShipmentRepository>((ref) {
  return ShipmentRepository();
});

// Photo upload state
class PhotoUploadState {
  final bool isUploading;
  final String? error;
  final String? url;

  const PhotoUploadState({this.isUploading = false, this.error, this.url});

  PhotoUploadState copyWith({bool? isUploading, String? error, String? url}) {
    return PhotoUploadState(
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
      url: url ?? this.url,
    );
  }
}

// Simple future providers untuk shipments
final driverShipmentsProvider = FutureProvider<List<Shipment>>((ref) async {
  ref.watch(shipmentRepositoryProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;

  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  // For now, return empty list until repository method is implemented
  return <Shipment>[];
});

// Active shipments provider
final activeShipmentsProvider = Provider<AsyncValue<List<Shipment>>>((ref) {
  final shipmentsAsyncValue = ref.watch(driverShipmentsProvider);

  return shipmentsAsyncValue.when(
    data: (shipments) {
      final activeShipments = shipments
          .where((s) => s.status == 'pending' || s.status == 'in_transit')
          .toList();
      return AsyncValue.data(activeShipments);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Shipment stats provider
final shipmentStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  ref.watch(shipmentRepositoryProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;

  if (currentUser == null) {
    return {'total': 0, 'pending': 0, 'in_transit': 0, 'completed': 0};
  }

  try {
    // For now, return default stats until repository method is implemented
    return {'total': 0, 'pending': 0, 'in_transit': 0, 'completed': 0};
  } catch (e) {
    log('Error loading shipment stats: $e');
    return {'total': 0, 'pending': 0, 'in_transit': 0, 'completed': 0};
  }
});

// Individual shipment provider
final shipmentProvider = FutureProvider.family<Shipment?, String>((
  ref,
  shipmentId,
) async {
  ref.watch(shipmentRepositoryProvider);
  // For now, return null until repository method is implemented
  return null;
});

// Photo upload notifier
class PhotoUploadNotifier extends Notifier<PhotoUploadState> {
  @override
  PhotoUploadState build() => const PhotoUploadState();

  Future<String?> uploadPhoto(XFile photo) async {
    state = state.copyWith(isUploading: true, error: null);

    try {
      final file = File(photo.path);
      final fileName =
          'delivery_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('delivery-proofs')
          .upload(fileName, file);

      final url = Supabase.instance.client.storage
          .from('delivery-proofs')
          .getPublicUrl(fileName);

      state = state.copyWith(isUploading: false, url: url);
      return url;
    } catch (e) {
      log('Error uploading photo: $e');
      state = state.copyWith(isUploading: false, error: e.toString());
      return null;
    }
  }

  void clearState() {
    state = const PhotoUploadState();
  }
}

// Photo upload provider
final photoUploadProvider =
    NotifierProvider<PhotoUploadNotifier, PhotoUploadState>(() {
      return PhotoUploadNotifier();
    });
