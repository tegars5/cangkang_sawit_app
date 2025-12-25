import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../shipments/domain/entities/shipment.dart';

/// Driver Dashboard Page - shows delivery tasks for the driver
class DriverDashboardPage extends ConsumerStatefulWidget {
  final String driverId;

  const DriverDashboardPage({super.key, required this.driverId});

  @override
  ConsumerState<DriverDashboardPage> createState() =>
      _DriverDashboardPageState();
}

class _DriverDashboardPageState extends ConsumerState<DriverDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load deliveries
    Future.microtask(() {
      ref
          .read(driverNotifierProvider.notifier)
          .loadAssignedDeliveries(widget.driverId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Pengiriman'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Hari Ini (${state.todayDeliveries.length})'),
            Tab(text: 'Belum Ambil (${state.pendingDeliveries.length})'),
            Tab(text: 'Aktif (${state.activeDeliveries.length})'),
            Tab(text: 'Selesai (${state.completedDeliveries.length})'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(driverNotifierProvider.notifier)
                          .loadAssignedDeliveries(widget.driverId);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(driverNotifierProvider.notifier)
                    .loadAssignedDeliveries(widget.driverId);
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeliveryList(state.todayDeliveries),
                  _buildDeliveryList(state.pendingDeliveries),
                  _buildDeliveryList(state.activeDeliveries),
                  _buildDeliveryList(state.completedDeliveries),
                ],
              ),
            ),
    );
  }

  Widget _buildDeliveryList(List<Shipment> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Tidak ada pengiriman'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _DeliveryTaskCard(task: task, driverId: widget.driverId);
      },
    );
  }
}

class _DeliveryTaskCard extends ConsumerWidget {
  final Shipment task;
  final String driverId;

  const _DeliveryTaskCard({required this.task, required this.driverId});

  static String _getActionText(String action) {
    switch (action) {
      case 'assign_driver':
        return 'Tugaskan Driver';
      case 'pickup':
        return 'Tandai Sudah Diambil';
      case 'deliver':
        return 'Tandai Sudah Dikirim';
      case 'cancel':
        return 'Batalkan';
      case 'track':
        return 'Lacak';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DeliveryDetailPage(deliveryId: task.id, driverId: driverId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.customerPhone,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      task.getStatusText(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.deliveryAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.scale, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${task.totalWeight} kg • ${task.totalQuantity} items',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (task.priority != null) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PRIORITAS',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (task.isDelayed()) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                  ],
                ],
              ),
              if (task.scheduledDeliveryDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Target: ${_formatDate(task.scheduledDeliveryDate!)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (task.getAvailableActions().isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleAction(context, ref),
                    child: Text(
                      _DeliveryTaskCard._getActionText(
                        task.getAvailableActions().first,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref) async {
    if (task.canPickup()) {
      final success = await ref
          .read(driverNotifierProvider.notifier)
          .markPickedUp(deliveryId: task.id, driverId: driverId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil diambil')),
        );
      }
    } else if (task.canDeliver()) {
      // Navigate to delivery confirmation page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DeliveryDetailPage(deliveryId: task.id, driverId: driverId),
        ),
      );
    }
  }
}

/// Delivery Detail Page
class DeliveryDetailPage extends ConsumerWidget {
  final String deliveryId;
  final String driverId;

  const DeliveryDetailPage({
    super.key,
    required this.deliveryId,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverNotifierProvider);
    final delivery = state.deliveries.firstWhere(
      (d) => d.id == deliveryId,
      orElse: () => state.selectedDelivery!,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengiriman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerCard(delivery),
            const SizedBox(height: 16),
            _buildLocationCard(delivery),
            const SizedBox(height: 16),
            _buildDetailsCard(delivery),
            const SizedBox(height: 16),
            _buildActionsCard(context, ref, delivery),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Shipment delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pelanggan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Nama', delivery.customerName),
            _buildDetailRow('Telepon', delivery.customerPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Shipment delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi Pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(delivery.deliveryAddress)),
              ],
            ),
            if (delivery.hasLocation()) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // Open maps
                },
                icon: const Icon(Icons.map),
                label: const Text('Buka Peta'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Shipment delivery) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Berat', '${delivery.totalWeight} kg'),
            _buildDetailRow('Jumlah', '${delivery.totalQuantity} items'),
            _buildDetailRow('Status', delivery.getStatusText()),
            if (delivery.scheduledDeliveryDate != null)
              _buildDetailRow(
                'Target Pengiriman',
                '${delivery.scheduledDeliveryDate}',
              ),
            if (delivery.pickupDate != null)
              _buildDetailRow('Tanggal Ambil', '${delivery.pickupDate}'),
            if (delivery.actualDeliveryDate != null)
              _buildDetailRow(
                'Tanggal Kirim',
                '${delivery.actualDeliveryDate}',
              ),
            if (delivery.notes != null && delivery.notes!.isNotEmpty)
              _buildDetailRow('Catatan', delivery.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    WidgetRef ref,
    Shipment delivery,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Aksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (delivery.canPickup())
              ElevatedButton(
                onPressed: () async {
                  final success = await ref
                      .read(driverNotifierProvider.notifier)
                      .markPickedUp(
                        deliveryId: delivery.id,
                        driverId: driverId,
                      );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Tandai Sudah Diambil'),
              ),
            if (delivery.canDeliver())
              ElevatedButton(
                onPressed: () async {
                  final recipientName = await _showRecipientDialog(context);
                  if (recipientName != null) {
                    final success = await ref
                        .read(driverNotifierProvider.notifier)
                        .markDelivered(
                          deliveryId: delivery.id,
                          driverId: driverId,
                          recipientName: recipientName,
                        );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Tandai Sudah Dikirim'),
              ),
            if (delivery.hasLocation())
              OutlinedButton.icon(
                onPressed: () {
                  // Open tracking
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Navigasi'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRecipientDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penerima'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Penerima',
            hintText: 'Masukkan nama penerima',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }
}
