import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';

/// State for Orders screen
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final String? phoneNumber;
  final Order? selectedOrder; // Thêm để track order được chọn

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.phoneNumber,
    this.selectedOrder,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    String? phoneNumber,
    Order? selectedOrder,
    bool clearSelectedOrder = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
    );
  }
}

/// ViewModel for Orders screen
class OrdersViewModel extends StateNotifier<OrdersState> {
  final OrderRepository _repository;

  OrdersViewModel(this._repository) : super(const OrdersState());

  void setPhoneNumber(String? phone) {
    state = state.copyWith(phoneNumber: phone);
  }

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

  /// Chọn order để navigate - View sẽ listen và navigate
  void selectOrder(Order order) {
    state = state.copyWith(selectedOrder: order);
  }

  /// Clear selected order sau khi navigate
  void clearSelectedOrder() {
    state = state.copyWith(clearSelectedOrder: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
