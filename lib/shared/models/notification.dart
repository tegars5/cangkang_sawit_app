import 'user_profile.dart';

/// Model untuk Notification (Notifikasi) - notifications table
class Notification {
  final String id; // UUID primary key
  final String? userId; // Foreign key to profiles
  final String title;
  final String message;
  final String type; // info, warning, error, success
  final String? relatedTable;
  final String? relatedId; // UUID of related record
  final bool isRead;
  final DateTime createdAt;

  // Relasi
  final UserProfile? user;

  const Notification({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    this.type = 'info',
    this.relatedTable,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
    this.user,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      relatedTable: json['related_table'] as String?,
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_table': relatedTable,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper method untuk cek apakah notifikasi adalah info
  bool get isInfo => type == 'info';

  /// Helper method untuk cek apakah notifikasi adalah warning
  bool get isWarning => type == 'warning';

  /// Helper method untuk cek apakah notifikasi adalah error
  bool get isError => type == 'error';

  /// Helper method untuk cek apakah notifikasi adalah success
  bool get isSuccess => type == 'success';

  /// Helper method untuk format waktu created
  String get formattedCreatedAt {
    return _formatDateTime(createdAt);
  }

  /// Helper method untuk format waktu relatif (e.g., "2 jam yang lalu")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return _formatDateTime(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year $hour:$minute';
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedTable,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
    UserProfile? user,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedTable: relatedTable ?? this.relatedTable,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
