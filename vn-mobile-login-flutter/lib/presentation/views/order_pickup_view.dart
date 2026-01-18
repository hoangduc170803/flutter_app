import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/order.dart';
import '../../routes/app_router.dart';
import '../providers/providers.dart';
import '../widgets/call_masking_modal.dart';

class OrderPickupView extends ConsumerStatefulWidget {
  const OrderPickupView({super.key});

  @override
  ConsumerState<OrderPickupView> createState() => _OrderPickupViewState();
}

class _OrderPickupViewState extends ConsumerState<OrderPickupView> {
  Order? _order;
  bool _paymentExpanded = false;
  bool _creatorExpanded = false;
  String? _virtualNumber;

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

  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showCallMaskingModal(String contactName) {
    _virtualNumber = '1900636999';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CallMaskingModal(
        contactName: contactName,
        virtualNumber: _virtualNumber!,
        onConfirm: () {
          Navigator.pop(context);
          _makePhoneCall(_virtualNumber!);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _sendSms(String phone) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phone);
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      // Handle error
    }
  }

  void _onPickedUp() {
    if (_order == null) return;
    
    // Update order status to "Đang giao hàng" (delivering)
    final updatedOrder = _order!.copyWith(status: OrderStatus.delivering);
    
    // Update the order in the state
    ref.read(orderViewModelProvider.notifier).updateOrderStatus(_order!.id, OrderStatus.delivering);
    
    // Navigate to order detail
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.orderDetail,
      arguments: updatedOrder,
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
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPickupLocation(),
                    _buildPickupTime(),
                    _buildSenderInfo(),
                    _buildPaymentInfo(),
                    _buildCreatorInfo(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            _buildPickedUpButton(),
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
                  'Di chuyển đến điểm nhận hàng',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryAmber,
                  ),
                ),
              ],
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
    );
  }

  Widget _buildPickupLocation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.chevron_left,
              color: AppColors.gray400,
              size: 20.sp,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                children: [
                  Text(
                    _order!.pickupAddress?.split(',').first ?? 'Điểm lấy hàng',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _order!.pickupAddress ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.gray500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.gray600,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTime() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300, width: 2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.access_time,
              color: AppColors.gray500,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.gray700,
              ),
              children: [
                const TextSpan(text: 'Lấy hàng trước '),
                TextSpan(
                  text: _order!.pickupTime ?? '16:12',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderInfo() {
    final sender = _order!.sender ?? _order!.creator;
    if (sender == null) return const SizedBox.shrink();

    final senderName = sender is OrderSender ? sender.name : (sender as OrderCreator).name;
    final senderPhone = sender is OrderSender ? sender.phone : (sender as OrderCreator).phone;
    final senderInitial = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'A';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin người gửi',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 28.sp,
                    color: AppColors.gray400,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderInitial,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Người gửi',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showCallMaskingModal(senderName),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          color: AppColors.gray700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Gọi điện',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _sendSms(senderPhone),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message,
                          color: AppColors.gray700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Nhắn tin',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
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

  Widget _buildPaymentInfo() {
    final advanceAmount = _order!.advanceAmount ?? _order!.cod ?? 0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _paymentExpanded = !_paymentExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _paymentExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryBlue,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.red100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: AppColors.red500,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Số tiền cần ứng',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
              Text(
                '- ${_formatCurrency(advanceAmount)} đ',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hình thức thanh toán',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray500,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.green500,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _order!.paymentInfo?.paymentMethod ?? 'Tiền mặt',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorInfo() {
    final creator = _order!.creator;
    if (creator == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _creatorExpanded = !_creatorExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thông tin người tạo đơn',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                AnimatedRotation(
                  turns: _creatorExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.gray500,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Container(
                  height: 1,
                  color: AppColors.gray100,
                ),
                SizedBox(height: 16.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.gray600,
                    ),
                    children: [
                      const TextSpan(text: 'Người tạo: '),
                      TextSpan(
                        text: creator.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.gray600,
                    ),
                    children: [
                      const TextSpan(text: 'SĐT: '),
                      TextSpan(
                        text: creator.phone,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (creator.note != null) ...[
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.gray600,
                      ),
                      children: [
                        const TextSpan(text: 'Ghi chú: '),
                        TextSpan(
                          text: creator.note,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            crossFadeState: _creatorExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildPickedUpButton() {
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
        onTap: _onPickedUp,
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
            'Đã lấy hàng',
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

