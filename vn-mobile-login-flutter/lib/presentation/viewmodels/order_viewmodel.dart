import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order.dart';

/// State class for managing orders
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
    required this.orders,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ViewModel for managing order state
class OrderViewModel extends Notifier<OrderState> {
  @override
  OrderState build() {
    return OrderState(orders: getInitialMockOrders());
  }

  /// Update order status by ID
  void updateOrderStatus(String orderId, String newStatus) {
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }

  /// Get order by ID
  Order? getOrderById(String orderId) {
    try {
      return state.orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Reload orders (reset to initial state)
  void reloadOrders() {
    state = OrderState(orders: getInitialMockOrders());
  }
}

