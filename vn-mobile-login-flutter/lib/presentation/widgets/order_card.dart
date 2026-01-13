import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTopSection(),
                _buildDivider(),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            _buildOrderInfo(),
          ],
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getIconBgColor(),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        _getIcon(),
        size: 24,
        color: _getIconColor(),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${order.orderNumber}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${order.date} • ${order.time}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusBgColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        order.status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusTextColor(),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: AppColors.gray100,
    );
  }

  Widget _buildBottomSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.gray400,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Text(
            'Xem Merchant',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            size: 14,
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (order.iconType) {
      case IconType.box:
        return Icons.inventory_2_outlined;
      case IconType.truck:
        return Icons.local_shipping_outlined;
      case IconType.dots:
        return Icons.more_horiz;
      case IconType.cancel:
        return Icons.cancel_outlined;
    }
  }

  Color _getIconBgColor() {
    switch (order.iconType) {
      case IconType.box:
        return AppColors.blue100;
      case IconType.truck:
        return AppColors.purple100;
      case IconType.dots:
        return AppColors.amber100;
      case IconType.cancel:
        return AppColors.red100;
    }
  }

  Color _getIconColor() {
    switch (order.iconType) {
      case IconType.box:
        return AppColors.primaryBlue;
      case IconType.truck:
        return AppColors.primaryPurple;
      case IconType.dots:
        return const Color(0xFFCA8A04);
      case IconType.cancel:
        return AppColors.red600;
    }
  }

  Color _getStatusBgColor() {
    switch (order.status) {
      case OrderStatus.completed:
        return AppColors.green100;
      case OrderStatus.inTransit:
        return AppColors.blue100;
      case OrderStatus.processing:
        return AppColors.amber100;
      case OrderStatus.cancelled:
        return AppColors.red100;
    }
  }

  Color _getStatusTextColor() {
    switch (order.status) {
      case OrderStatus.completed:
        return AppColors.green800;
      case OrderStatus.inTransit:
        return AppColors.blue800;
      case OrderStatus.processing:
        return const Color(0xFF854D0E);
      case OrderStatus.cancelled:
        return AppColors.red800;
    }
  }
}

