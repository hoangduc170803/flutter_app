import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../providers/providers.dart';

/// State class for managing orders
class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// ViewModel for managing order state
class OrderViewModel extends Notifier<OrderState> {
  @override
  OrderState build() => const OrderState();

  /// Get repository instance
  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  /// Load all orders from repository
  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _repository.getOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách đơn hàng',
      );
    }
  }

  /// Search orders by query
  Future<void> searchOrders(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    try {
      final orders = await _repository.searchOrders(query);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Update order status by ID
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedOrder =
          await _repository.updateOrderStatus(orderId, newStatus);
      if (updatedOrder != null) {
        final updatedOrders = state.orders.map((order) {
          return order.id == orderId ? updatedOrder : order;
        }).toList();
        state = state.copyWith(orders: updatedOrders, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy đơn hàng',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể cập nhật trạng thái đơn hàng',
      );
    }
  }

  /// Get order by ID (from current state)
  Order? getOrderById(String orderId) {
    return state.orders.firstWhereOrNull((order) => order.id == orderId);
  }

  /// Reload orders (refresh from repository)
  Future<void> reloadOrders() async {
    await loadOrders();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
