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

enum IconType { box, truck, dots, cancel }

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
}

// Mock data
const List<Order> mockOrders = [
  Order(
    id: '1',
    orderNumber: '2481',
    date: 'Mar 12, 2023',
    time: '10:30 AM',
    status: OrderStatus.completed,
    total: 124.50,
    iconType: IconType.box,
  ),
  Order(
    id: '2',
    orderNumber: '2482',
    date: 'Mar 14, 2023',
    time: '02:15 PM',
    status: OrderStatus.inTransit,
    total: 89.00,
    iconType: IconType.truck,
  ),
  Order(
    id: '3',
    orderNumber: '2483',
    date: 'Mar 15, 2023',
    time: '09:00 AM',
    status: OrderStatus.processing,
    total: 45.20,
    iconType: IconType.dots,
  ),
  Order(
    id: '4',
    orderNumber: '2484',
    date: 'Mar 16, 2023',
    time: '11:45 AM',
    status: OrderStatus.cancelled,
    total: 210.00,
    iconType: IconType.cancel,
  ),
  Order(
    id: '5',
    orderNumber: '2485',
    date: 'Mar 18, 2023',
    time: '10:15 AM',
    status: OrderStatus.completed,
    total: 55.00,
    iconType: IconType.box,
  ),
];

