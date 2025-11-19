// Enum untuk status berbagai entities
enum StatusType {
  pending,
  approved,
  inProgress,
  completed,
  rejected,
  cancelled,
  assigned,
  delivered,
  urgent,
  confirmed,
}

extension StatusTypeExtension on StatusType {
  String get displayName {
    switch (this) {
      case StatusType.pending:
        return 'Pending';
      case StatusType.approved:
        return 'Approved';
      case StatusType.inProgress:
        return 'In Progress';
      case StatusType.completed:
        return 'Completed';
      case StatusType.rejected:
        return 'Rejected';
      case StatusType.cancelled:
        return 'Cancelled';
      case StatusType.assigned:
        return 'Assigned';
      case StatusType.delivered:
        return 'Delivered';
      case StatusType.urgent:
        return 'Urgent';
      case StatusType.confirmed:
        return 'Confirmed';
    }
  }
}
