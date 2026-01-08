import 'package:flutter/material.dart';
import '../models/order.dart';

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
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                // Top Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Icon
                        Container(
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
                        ),
                        const SizedBox(width: 12),
                        // Order Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.orderNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.date} • ${order.time}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Status Badge
                    Container(
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
                    ),
                  ],
                ),
                
                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 1,
                  color: const Color(0xFFF3F4F6),
                ),
                
                // Bottom Section
                Row(
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
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    // Action Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            'Xem Merchant',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
        return const Color(0xFFDBEAFE); // blue-100
      case IconType.truck:
        return const Color(0xFFF3E8FF); // purple-100
      case IconType.dots:
        return const Color(0xFFFEF3C7); // yellow-100
      case IconType.cancel:
        return const Color(0xFFFEE2E2); // red-100
    }
  }

  Color _getIconColor() {
    switch (order.iconType) {
      case IconType.box:
        return const Color(0xFF2563EB); // blue-600
      case IconType.truck:
        return const Color(0xFF9333EA); // purple-600
      case IconType.dots:
        return const Color(0xFFCA8A04); // yellow-600
      case IconType.cancel:
        return const Color(0xFFDC2626); // red-600
    }
  }

  Color _getStatusBgColor() {
    switch (order.status) {
      case OrderStatus.completed:
        return const Color(0xFFDCFCE7); // green-100
      case OrderStatus.inTransit:
        return const Color(0xFFDBEAFE); // blue-100
      case OrderStatus.processing:
        return const Color(0xFFFEF3C7); // yellow-100
      case OrderStatus.cancelled:
        return const Color(0xFFFEE2E2); // red-100
    }
  }

  Color _getStatusTextColor() {
    switch (order.status) {
      case OrderStatus.completed:
        return const Color(0xFF166534); // green-800
      case OrderStatus.inTransit:
        return const Color(0xFF1E40AF); // blue-800
      case OrderStatus.processing:
        return const Color(0xFF854D0E); // yellow-800
      case OrderStatus.cancelled:
        return const Color(0xFF991B1B); // red-800
    }
  }
}
