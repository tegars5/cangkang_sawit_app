import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_widgets.dart';
import 'admin_users_page.dart';

/// Dashboard Admin - Clean Architecture Implementation
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(weeklyOrderDataProvider);
          ref.invalidate(recentOrdersProvider);
          ref.invalidate(recentActivitiesProvider);
        },
        child: CustomScrollView(
          slivers: [
            _DashboardHeader(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _StatsSection(),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            _QuickActionsSection(),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            _WeeklyChartSection(),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            _RecentOrdersSection(),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            _ActivitySection(),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}

/// Dashboard Header Widget
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard Admin',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Cangkang Sawit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 4.h,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.white70, size: 14.sp),
                    SizedBox(width: 6.w),
                    Text(
                      '${timeFormat.format(now)} WIB',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      dateFormat.format(now),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats Section Widget
class _StatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: statsAsync.when(
        data: (stats) => SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.4,
          ),
          delegate: SliverChildListDelegate([
            AdminStatCard(
              title: 'Total Pesanan',
              value: stats?.totalOrders.toString() ?? '0',
              subtitle: 'Bulan ini',
              icon: Icons.shopping_cart,
              color: const Color(0xFF2196F3),
              trend: stats?.ordersTrend ?? 0.0,
            ),
            AdminStatCard(
              title: 'Pengiriman',
              value: stats?.activeShipments.toString() ?? '0',
              subtitle: 'Aktif',
              icon: Icons.local_shipping,
              color: const Color(0xFFFF9800),
              trend: stats?.shipmentsTrend ?? 0.0,
            ),
            AdminStatCard(
              title: 'Mitra Aktif',
              value: stats?.activePartners.toString() ?? '0',
              subtitle: 'Total',
              icon: Icons.people,
              color: const Color(0xFF9C27B0),
              trend: stats?.partnersTrend ?? 0.0,
            ),
            AdminStatCard(
              title: 'Pendapatan',
              value: currencyFormat.format(stats?.monthlyRevenue ?? 0),
              subtitle: 'Bulan ini',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF4CAF50),
              trend: stats?.revenueTrend ?? 0.0,
              compactValue: true,
            ),
          ]),
        ),
        loading: () => _buildLoadingGrid(),
        error: (_, __) => SliverToBoxAdapter(
          child: AdminErrorWidget(
            message: 'Gagal memuat statistik',
            onRetry: () => ref.invalidate(dashboardStatsProvider),
          ),
        ),
      ),
    );
  }

  SliverGrid _buildLoadingGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.4,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, __) => const AdminLoadingCard(),
        childCount: 4,
      ),
    );
  }
}

/// Quick Actions Section Widget
class _QuickActionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(title: 'Aksi Cepat', padding: EdgeInsets.zero),
            SizedBox(height: 12.h),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    _buildQuickAction(
                      icon: Icons.add_shopping_cart,
                      label: 'Pesanan',
                      color: const Color(0xFF2196F3),
                      onTap: () =>
                          ref.read(adminTabIndexProvider.notifier).state = 1,
                    ),
                    SizedBox(width: 8.w),
                    _buildQuickAction(
                      icon: Icons.inventory_2,
                      label: 'Produk',
                      color: const Color(0xFF4CAF50),
                      onTap: () =>
                          ref.read(adminTabIndexProvider.notifier).state = 3,
                    ),
                    SizedBox(width: 8.w),
                    _buildQuickAction(
                      icon: Icons.local_shipping,
                      label: 'Tracking',
                      color: const Color(0xFFFF9800),
                      onTap: () =>
                          ref.read(adminTabIndexProvider.notifier).state = 2,
                    ),
                    SizedBox(width: 8.w),
                    _buildQuickAction(
                      icon: Icons.people,
                      label: 'Users',
                      color: const Color(0xFF9C27B0),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersPage(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekly Chart Section Widget
class _WeeklyChartSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartDataAsync = ref.watch(weeklyOrderDataProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'Statistik Pesanan',
              padding: EdgeInsets.zero,
            ),
            SizedBox(height: 12.h),
            chartDataAsync.when(
              data: (data) => _WeeklyChartCard(data: data),
              loading: () => const AdminLoadingWidget(),
              error: (_, __) => AdminErrorWidget(
                message: 'Gagal memuat chart',
                onRetry: () => ref.invalidate(weeklyOrderDataProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weekly Chart Card Widget
class _WeeklyChartCard extends StatelessWidget {
  final List<WeeklyOrderData> data;

  const _WeeklyChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final values = data.map((e) => e.orders).toList();
    final labels = data.map((e) => e.day).toList();
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).toDouble();
    final total = values.fold(0, (sum, value) => sum + value);

    return AdminCardContainer(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Minggu Ini',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Total: $total',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 120.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final value = values[index];
                final height = maxValue > 0 ? (value / maxValue) * 70.h : 0.0;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: double.infinity,
                          height: height,
                          constraints: BoxConstraints(minHeight: 4.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: const Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent Orders Section Widget
class _RecentOrdersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(recentOrdersProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'Pesanan Terbaru',
              actionText: 'Lihat Semua',
              onActionTap: () =>
                  ref.read(adminTabIndexProvider.notifier).state = 1,
              padding: EdgeInsets.zero,
            ),
            SizedBox(height: 12.h),
            ordersAsync.when(
              data: (orders) => orders.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.inbox_outlined,
                      message: 'Belum ada pesanan',
                    )
                  : _RecentOrdersList(orders: orders),
              loading: () => const AdminLoadingWidget(),
              error: (_, __) => AdminErrorWidget(
                message: 'Gagal memuat pesanan',
                onRetry: () => ref.invalidate(recentOrdersProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent Orders List Widget
class _RecentOrdersList extends StatelessWidget {
  final List<dynamic> orders;

  const _RecentOrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return AdminCardContainer(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final order = orders[index];
          final statusColor = _getStatusColor(order.status);
          final customerName =
              order.customer?.fullName ??
              order.customer?.email?.split('@').first ??
              'Customer #${order.orderNumber.split('-').last}';

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: statusColor,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        customerName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF757575),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          StatusBadge(
                            status: _getStatusText(order.status),
                            color: statusColor,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              _getTimeAgo(order.createdAt),
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: const Color(0xFF9E9E9E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  currencyFormat.format(order.totalAmount ?? 0),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF2196F3);
      case 'confirmed':
        return const Color(0xFFFF9800);
      case 'in_transit':
        return const Color(0xFF9C27B0);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'in_transit':
        return 'Pengiriman';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Batal';
      default:
        return status;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}h lalu';
    if (diff.inHours > 0) return '${diff.inHours}j lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m lalu';
    return 'Baru saja';
  }
}

/// Activity Section Widget
class _ActivitySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminSectionHeader(
              title: 'Aktivitas Terkini',
              padding: EdgeInsets.zero,
            ),
            SizedBox(height: 12.h),
            activitiesAsync.when(
              data: (activities) => activities.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.history,
                      message: 'Belum ada aktivitas',
                    )
                  : _ActivityTimeline(activities: activities),
              loading: () => const AdminLoadingWidget(),
              error: (_, __) => AdminErrorWidget(
                message: 'Gagal memuat aktivitas',
                onRetry: () => ref.invalidate(recentActivitiesProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Timeline Widget
class _ActivityTimeline extends StatelessWidget {
  final List<dynamic> activities;

  const _ActivityTimeline({required this.activities});

  @override
  Widget build(BuildContext context) {
    return AdminCardContainer(
      padding: EdgeInsets.all(12.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final activity = activities[index];
          final isLast = index == activities.length - 1;
          final color = _getColor(activity.colorType);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(activity.iconType),
                        color: color,
                        size: 16.sp,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2.w,
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          color: Colors.grey[300],
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        activity.subtitle,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF757575),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        activity.time,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'new_order':
        return Icons.add_shopping_cart;
      case 'shipment':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      case 'new_partner':
        return Icons.person_add;
      default:
        return Icons.info;
    }
  }

  Color _getColor(String colorType) {
    switch (colorType) {
      case 'blue':
        return const Color(0xFF2196F3);
      case 'orange':
        return const Color(0xFFFF9800);
      case 'green':
        return const Color(0xFF4CAF50);
      case 'purple':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF757575);
    }
  }
}
