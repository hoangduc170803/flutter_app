import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/order.dart';
import '../../data/services/pnm_config.dart';
import '../../routes/app_router.dart';
import '../providers/providers.dart';

/// Navigation tabs enum
enum NavTab { orders, history, notifications, stats, more }

class OrderListView extends ConsumerStatefulWidget {
  const OrderListView({super.key});

  @override
  ConsumerState<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends ConsumerState<OrderListView> {
  NavTab _activeTab = NavTab.orders;
  bool _isOnline = true;
  // ignore: unused_field - Used for future features
  String? _phoneNumber;
  String _maskedNumber = PnmConfig.defaultMaskedNumber;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _phoneNumber = args['phoneNumber'] as String?;
      _maskedNumber = args['maskedNumber'] as String? ?? PnmConfig.defaultMaskedNumber;
    }
    
    // Load orders when view is first displayed
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(orderViewModelProvider.notifier).loadOrders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _activeTab == NavTab.orders
                  ? _buildOrderList()
                  : _buildPlaceholder(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.slate800,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hàng 1: Avatar và Filter
              Row(
                children: [
                  // Avatar button
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.gray600.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: AppColors.gray400.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.gray200,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Filter button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: AppColors.gray300,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAmber,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Tất cả',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h), // Khoảng cách giữa 2 dòng

              // Hàng 2: Box Số điện thoại
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.gray700.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: AppColors.gray600.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        Icons.phone_in_talk,
                        size: 12.sp,
                        color: AppColors.primaryAmber
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Masking: $_maskedNumber',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.gray200,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Text(
                'Trực tuyến',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray100,
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => setState(() => _isOnline = !_isOnline),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.green500 : AppColors.gray500,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment:
                    _isOnline ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    final orderState = ref.watch(orderViewModelProvider);
    final orders = orderState.orders;
    
    // Show loading indicator
    if (orderState.isLoading && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAmber),
      );
    }
    
    // Show empty state
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64.sp, color: AppColors.gray400),
            SizedBox(height: 16.h),
            Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _OrderCard(
            order: order,
            onTap: () {
              if (!order.isSpecial) {
                // If order is in "Đang tìm" status, show accept view first
                if (order.status == OrderStatus.searching) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderAccept,
                    arguments: order,
                  );
                } else if (order.status == OrderStatus.picking) {
                  // If already accepted, go to pickup view
                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderPickup,
                    arguments: order,
                  );
                } else {
                  // If in delivery or other status, go to detail view
                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderDetail,
                    arguments: order,
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Center(
              child: Text(
                '🚧',
                style: TextStyle(fontSize: 30.sp, color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Tính năng đang phát triển',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final navItems = [
      (NavTab.orders, 'Đơn hàng', Icons.checklist),
      (NavTab.history, 'Lịch sử', Icons.history),
      (NavTab.notifications, 'Thông báo', Icons.notifications_outlined),
      (NavTab.stats, 'Thống kê', Icons.bar_chart),
      (NavTab.more, 'Thêm', Icons.grid_view),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = _activeTab == item.$1;
              return GestureDetector(
                onTap: () => setState(() => _activeTab = item.$1),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 60.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.$3,
                        size: 24.sp,
                        color: isActive ? AppColors.primaryAmber : AppColors.gray400,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.primaryAmber : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Order Card Widget
// ============================================================================

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const _OrderCard({
    required this.order,
    this.onTap,
  });

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    if (order.isSpecial) {
      return _buildSpecialCard(context);
    }
    return _buildNormalCard(context);
  }

  Widget _buildSpecialCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4.r,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    order.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                Text(
                  '${order.distance}km • ₫${_formatCurrency(order.price)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Giao Gần',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4.r,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    order.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                    children: [
                      TextSpan(text: '${order.distance}km • '),
                      TextSpan(
                        text: '₫${_formatCurrency(order.price)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // COD info
            if (order.cod != null) ...[
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.gray500,
                    ),
                    children: [
                      const TextSpan(text: 'Tổng COD: '),
                      TextSpan(
                        text: '₫${_formatCurrency(order.cod!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
            // Main Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.blue100),
                  ),
                  child: Center(
                    child: Text(
                      '🚀',
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Route Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Route with dots
                      _buildRouteInfo(),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  size: 24.sp,
                  color: AppColors.gray300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dots and line
        SizedBox(
          width: 12.w,
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Container(
                width: 2.w,
                height: 24.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 2.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 2.h),
                          color: AppColors.gray300,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: AppColors.gray400, width: 2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Addresses
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.pickupAddress ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 24.h),
              Text(
                order.dropoffAddress ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.gray500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

