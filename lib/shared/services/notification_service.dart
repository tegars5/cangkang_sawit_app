import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk mengelola notifikasi
class NotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Send notification to driver when assigned to a shipment
  static Future<void> sendDriverAssignmentNotification({
    required String driverId,
    required String shipmentId,
    required String orderNumber,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': driverId,
        'title': 'Pengiriman Baru Ditugaskan',
        'message':
            'Anda telah ditugaskan untuk pengiriman order $orderNumber. Silakan cek detail pengiriman.',
        'category': 'shipment_assignment',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Send notification when shipment status changes
  static Future<void> sendShipmentStatusNotification({
    required String userId,
    required String shipmentId,
    required String orderNumber,
    required String status,
  }) async {
    try {
      String title = '';
      String message = '';

      switch (status) {
        case 'in_transit':
          title = 'Pengiriman Dimulai';
          message = 'Pengiriman order $orderNumber sedang dalam perjalanan.';
          break;
        case 'arrived':
          title = 'Pengiriman Tiba';
          message = 'Pengiriman order $orderNumber telah tiba di tujuan.';
          break;
        case 'completed':
          title = 'Pengiriman Selesai';
          message = 'Pengiriman order $orderNumber telah selesai.';
          break;
        case 'cancelled':
          title = 'Pengiriman Dibatalkan';
          message = 'Pengiriman order $orderNumber telah dibatalkan.';
          break;
        default:
          title = 'Update Pengiriman';
          message = 'Status pengiriman order $orderNumber telah diupdate.';
      }

      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'category': 'shipment_status',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  /// Get unread notifications count for a user
  static Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  static Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }
}
