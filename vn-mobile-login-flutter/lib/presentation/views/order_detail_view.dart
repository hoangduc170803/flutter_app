import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/order.dart';
import '../../data/services/pnm_config.dart';
import '../providers/providers.dart';
import '../widgets/call_masking_modal.dart';

class OrderDetailView extends ConsumerStatefulWidget {
  const OrderDetailView({super.key});

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> {
  Order? _order;
  bool _paymentExpanded = false;
  bool _creatorExpanded = false;
  String _axbMaskedNumber = PnmConfig.defaultAxbMaskedNumber;
  String? _subid;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _order = args['order'] as Order?;
      _axbMaskedNumber = args['axbMaskedNumber'] as String? ?? PnmConfig.defaultAxbMaskedNumber;
      _subid = args['subid'] as String?;
    } else if (args is Order) {
      // Backward compatibility
      _order = args;
    }
  }

  /// Handle delivery completion (success or failure)
  Future<void> _onDeliveryComplete({required bool isSuccess}) async {
    if (_order == null || _isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Unbind with recipient to release masked number
      if (_subid != null && _subid!.isNotEmpty) {
        print('[OrderDetail] Unbinding on delivery ${isSuccess ? 'success' : 'failure'}: $_subid');
        final pnmService = ref.read(pnmServiceProvider);
        await pnmService.unbindAxb(subid: _subid!);
      } else {
        print('[OrderDetail] No subid to unbind');
      }
    } catch (e) {
      print('[OrderDetail] Error unbinding: $e');
    }
    
    setState(() => _isLoading = false);
    
    // Update order status
    if (isSuccess) {
      ref.read(orderViewModelProvider.notifier).updateOrderStatus(_order!.id, OrderStatus.delivered);
    } else {
      ref.read(orderViewModelProvider.notifier).updateOrderStatus(_order!.id, OrderStatus.cancelled);
    }
    
    // Show feedback and navigate back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuccess ? 'Giao hàng thành công!' : 'Giao hàng thất bại'),
          backgroundColor: isSuccess ? AppColors.green500 : AppColors.red500,
        ),
      );
      Navigator.pop(context);
    }
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  /// Check if order is in a final state (completed)
  bool get _isOrderCompleted {
    return _order?.status == OrderStatus.delivered ||
           _order?.status == OrderStatus.cancelled;
  }

  /// Get status display text based on order status
  String get _statusText {
    switch (_order?.status) {
      case OrderStatus.delivered:
        return 'Giao hàng thành công';
      case OrderStatus.cancelled:
        return 'Giao hàng thất bại';
      case OrderStatus.delivering:
        return 'Đang giao hàng';
      default:
        return _order?.status?.displayName ?? 'Đang giao hàng';
    }
  }

  /// Get status color based on order status
  Color get _statusColor {
    switch (_order?.status) {
      case OrderStatus.delivered:
        return AppColors.green500;
      case OrderStatus.cancelled:
        return AppColors.red500;
      default:
        return AppColors.gray300;
    }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CallMaskingModal(
        contactName: contactName,
        virtualNumber: _axbMaskedNumber,
        onConfirm: () {
          Navigator.pop(context);
          _makePhoneCall(_axbMaskedNumber);
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
                    _buildDeliveryLocation(),
                    _buildTimeInfo(),
                    _buildRecipientInfo(),
                    _buildPaymentInfo(),
                    _buildCreatorInfo(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            // Only show action buttons if order is not completed
            if (!_isOrderCompleted) _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.slate800,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  margin: EdgeInsets.only(left: 0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
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
                    _statusText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _isOrderCompleted ? _statusColor : AppColors.gray300,
                      fontWeight: _isOrderCompleted ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
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

  Widget _buildDeliveryLocation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryAmber,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Điểm giao hàng (1/1)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Danh sách điểm giao',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryAmber,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.gray400,
                  size: 24.sp,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    children: [
                      Text(
                        _order!.dropoffAddress?.split(',').first ?? 'Địa chỉ giao hàng',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _order!.dropoffAddress ?? '',
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
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.gray600,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.access_time_filled,
              color: AppColors.gray400,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
              children: [
                const TextSpan(text: 'Giao hàng trước '),
                TextSpan(
                  text: _order!.deliveryTime ?? '16:50',
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

  Widget _buildRecipientInfo() {
    final recipient = _order!.recipient;
    if (recipient == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin người nhận',
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
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Text(
                    recipient.initials,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Người nhận',
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
          // Hide call/message buttons when order is completed
          if (!_isOrderCompleted)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCallMaskingModal(recipient.name),
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
                    onTap: () => _sendSms(recipient.phone),
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
    final payment = _order!.paymentInfo;
    if (payment == null) return const SizedBox.shrink();

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
                        color: AppColors.primaryAmber,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _paymentExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryAmber,
                        size: 16.sp,
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
                      color: AppColors.green100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.green600,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Số tiền cần thu',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
              Text(
                '+ ₫${_formatCurrency(payment.totalAmount)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 1,
            color: AppColors.gray100,
          ),
          SizedBox(height: 12.h),
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
                    payment.paymentMethod,
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
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  height: 1,
                  color: AppColors.gray100,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiền hàng',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.gray500,
                      ),
                    ),
                    Text(
                      '₫${_formatCurrency(payment.productAmount)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phí vận chuyển',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.gray500,
                      ),
                    ),
                    Text(
                      '₫${_formatCurrency(payment.shippingFee)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            crossFadeState: _paymentExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
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

  Widget _buildFooterActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isLoading ? null : () => _onDeliveryComplete(isSuccess: false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _isLoading ? AppColors.gray100 : AppColors.gray200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gray500,
                        ),
                      )
                    : Text(
                        'Thất bại',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray800,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isLoading ? null : () => _onDeliveryComplete(isSuccess: true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAmber.withValues(alpha: 0.2),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Text(
                  'Thành công',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

