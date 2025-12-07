import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom App Bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? const Color(0xFF1B5E20),
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: titleColor ?? Colors.white,
                size: 24.sp,
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.white,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

/// Bottom Navigation Bar untuk Admin
class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Dashboard
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
              ),
              // Orders
              _buildNavItem(
                index: 1,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                label: 'Orders',
              ),
              // Spacer for center FAB
              SizedBox(width: 60.w),
              // Products
              _buildNavItem(
                index: 3,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Products',
              ),
              // Settings
              _buildNavItem(
                index: 4,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
              ),
            ],
          ),
          // Center FAB for Shipments
          Positioned(
            left: 0,
            right: 0,
            top: -20.h,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    currentIndex == 2
                        ? Icons.local_shipping
                        : Icons.local_shipping_outlined,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFF6B7280),
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom Navigation Bar untuk Driver
class DriverBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DriverBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined, size: 24.sp),
            activeIcon: Icon(Icons.assignment, size: 24.sp),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined, size: 24.sp),
            activeIcon: Icon(Icons.location_on, size: 24.sp),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24.sp),
            activeIcon: Icon(Icons.person, size: 24.sp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Tab Header yang bisa di-scroll
class TabHeader extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isScrollable;

  const TabHeader({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1B5E20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFFD1D5DB),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
