/// Order status enum
enum OrderStatus {
  completed,
  inTransit,
  processing,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Icon type for order display
enum IconType { box, truck, dots, cancel }

/// Order model representing a customer order
class Order {
  final String id;
  final String orderNumber;
  final String date;
  final String time;
  final OrderStatus status;
  final double total;
  final IconType iconType;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.time,
    required this.status,
    required this.total,
    required this.iconType,
  });

  Order copyWith({
    String? id,
    String? orderNumber,
    String? date,
    String? time,
    OrderStatus? status,
    double? total,
    IconType? iconType,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      total: total ?? this.total,
      iconType: iconType ?? this.iconType,
    );
  }
}

