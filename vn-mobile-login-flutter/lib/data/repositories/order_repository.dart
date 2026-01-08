import '../models/order.dart';

/// Repository for order data operations
abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String id);
}

/// Implementation of OrderRepository with mock data
class OrderRepositoryImpl implements OrderRepository {
  // Mock data
  static const List<Order> _mockOrders = [
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

  @override
  Future<List<Order>> getOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockOrders;
  }

  @override
  Future<Order?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockOrders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
}

