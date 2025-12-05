import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/driver_service.dart';

/// Driver task state
class DriverTaskState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic>? selectedTask;
  final Map<String, dynamic>? dashboardStats;

  const DriverTaskState({
    this.isLoading = false,
    this.error,
    this.tasks = const [],
    this.selectedTask,
    this.dashboardStats,
  });

  DriverTaskState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? tasks,
    Map<String, dynamic>? selectedTask,
    Map<String, dynamic>? dashboardStats,
  }) {
    return DriverTaskState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      dashboardStats: dashboardStats ?? this.dashboardStats,
    );
  }
}

/// Driver task controller for managing driver tasks/shipments
class DriverTaskController extends Notifier<DriverTaskState> {
  @override
  DriverTaskState build() => const DriverTaskState();

  /// Get dashboard stats for driver
  Future<void> getDashboardStats(String driverId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await DriverService.getDriverDashboardStats(driverId);
      state = state.copyWith(isLoading: false, dashboardStats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Get tasks for driver
  Future<void> getTasks(
    String driverId, {
    String? status,
    DateTime? date,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tasks = await DriverService.getTasks(
        driverId,
        status: status,
        date: date,
      );
      state = state.copyWith(isLoading: false, tasks: tasks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Terjadi kesalahan: $e');
    }
  }

  /// Filter tasks by status
  List<Map<String, dynamic>> filterByStatus(String status) {
    if (status == 'Active') {
      return state.tasks.where((task) {
        final taskStatus = task['status']?.toString() ?? '';
        return taskStatus == 'In Progress' || taskStatus == 'Ready';
      }).toList();
    } else if (status == 'Scheduled') {
      return state.tasks.where((task) {
        final taskStatus = task['status']?.toString() ?? '';
        return taskStatus == 'Scheduled';
      }).toList();
    } else if (status == 'Completed') {
      return state.tasks.where((task) {
        final taskStatus = task['status']?.toString() ?? '';
        return taskStatus == 'Completed';
      }).toList();
    }
    return state.tasks;
  }

  /// Search tasks
  List<Map<String, dynamic>> searchTasks(String query) {
    if (query.isEmpty) return state.tasks;

    return state.tasks.where((task) {
      final taskNumber = task['task_number']?.toString().toLowerCase() ?? '';
      final customerName =
          task['customer_name']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();

      return taskNumber.contains(searchLower) ||
          customerName.contains(searchLower);
    }).toList();
  }

  /// Reset state
  void reset() {
    state = const DriverTaskState();
  }
}

/// Driver task controller provider
final driverTaskControllerProvider =
    NotifierProvider<DriverTaskController, DriverTaskState>(() {
      return DriverTaskController();
    });
