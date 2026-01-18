import '../models/order.dart';
import '../mock/mock_orders.dart';

/// Abstract repository interface for order operations
abstract class OrderRepository {
  /// Get all orders
  Future<List<Order>> getOrders();

  /// Get order by ID
  Future<Order?> getOrderById(String orderId);

  /// Update order status
  Future<Order?> updateOrderStatus(String orderId, OrderStatus newStatus);

  /// Search orders by query
  Future<List<Order>> searchOrders(String query);
}

/// Implementation with mock data
class OrderRepositoryImpl implements OrderRepository {
  // In-memory cache of orders (simulating a database)
  List<Order>? _cachedOrders;

  /// Initialize or get cached orders
  List<Order> get _orders {
    _cachedOrders ??= MockOrders.getInitialOrders();
    return _cachedOrders!;
  }

  @override
  Future<List<Order>> getOrders() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_orders);
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Order?> updateOrderStatus(
      String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return null;

    final updatedOrder = _orders[index].copyWith(status: newStatus);
    _cachedOrders![index] = updatedOrder;
    return updatedOrder;
  }

  @override
  Future<List<Order>> searchOrders(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (query.trim().isEmpty) return List.unmodifiable(_orders);

    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.id.toLowerCase().contains(lowerQuery) ||
          order.recipient?.name.toLowerCase().contains(lowerQuery) == true ||
          order.sender?.name.toLowerCase().contains(lowerQuery) == true ||
          order.pickupAddress?.toLowerCase().contains(lowerQuery) == true ||
          order.dropoffAddress?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  /// Reset cache (for testing or refresh)
  void resetCache() {
    _cachedOrders = null;
  }
}

