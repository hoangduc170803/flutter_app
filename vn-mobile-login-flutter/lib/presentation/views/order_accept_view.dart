import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/order.dart';
import '../../routes/app_router.dart';
import '../providers/providers.dart';

class OrderAcceptView extends ConsumerStatefulWidget {
  const OrderAcceptView({super.key});

  @override
  ConsumerState<OrderAcceptView> createState() => _OrderAcceptViewState();
}

class _OrderAcceptViewState extends ConsumerState<OrderAcceptView> {
  Order? _order;
  bool _priceExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Order) {
      _order = args;
    }
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  void _onAcceptOrder() {
    if (_order == null) return;
    
    // Update order status to "Đã nhận" in state
    ref.read(orderStateProvider.notifier).updateOrderStatus(_order!.id, 'Đã nhận');
    
    // Create a new order with updated status for navigation
    final acceptedOrder = _order!.copyWith(status: 'Đã nhận');
    
    // Navigate to order pickup (not detail yet)
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.orderPickup,
      arguments: acceptedOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        backgroundColor: AppColors.gray50,
        body: Center(
          child: Text(
            'Order not found',
            style: TextStyle(fontSize: 16.sp, color: AppColors.gray500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCashSection(),
                    _buildServiceSection(),
                    _buildRouteSection(),
                  ],
                ),
              ),
            ),
            _buildAcceptButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.slate800,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng #${_order!.id}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Đang giao hàng',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.gray300,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashSection() {
    final cashToReceive = _order!.cashToReceive ?? _order!.price;
    final totalFee = _order!.totalFee ?? _order!.price;
    final codAmount = _order!.cod ?? 0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nhận tiền mặt label
          Row(
            children: [
              Text(
                'Nhận tiền mặt',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.info_outline,
                size: 16.sp,
                color: AppColors.gray400,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Cash amount
          Text(
            '${_formatCurrency(cashToReceive)} đ',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryAmber,
            ),
          ),
          SizedBox(height: 16.h),
          // Fee details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng phí',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '${_formatCurrency(totalFee)} đ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryAmber,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng COD cần ứng',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray600,
                ),
              ),
              Text(
                '${_formatCurrency(codAmount)} đ',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryAmber,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Xem chi tiết giá
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _priceExpanded = !_priceExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem chi tiết giá',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right,
                    size: 18.sp,
                    color: AppColors.primaryAmber,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dịch vụ',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.gray600,
            ),
          ),
          Text(
            _order!.serviceName.toUpperCase(),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Lộ trình',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppColors.gray400,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${_order!.distance.toStringAsFixed(2).replaceAll('.', ',')}km',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
              // View route button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryAmber),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Xem lộ trình',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryAmber,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Pickup location
          _buildLocationItem(
            icon: Icons.location_on,
            iconColor: AppColors.primaryAmber,
            address: _order!.pickupAddress ?? 'Điểm lấy hàng',
            isPickup: true,
          ),
          SizedBox(height: 12.h),
          // Dropoff location
          _buildLocationItem(
            icon: Icons.circle_outlined,
            iconColor: AppColors.gray400,
            address: _order!.dropoffAddress ?? 'Điểm giao hàng',
            isPickup: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color iconColor,
    required String address,
    required bool isPickup,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              address,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.gray400,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _onAcceptOrder,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.primaryAmber,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAmber.withValues(alpha: 0.3),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Text(
            'TIẾP',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

