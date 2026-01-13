import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/merchant_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/phone_session_repository.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/orders_viewmodel.dart';
import '../viewmodels/merchant_contact_viewmodel.dart';

// ============================================================================
// Repository Providers
// ============================================================================

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepositoryImpl();
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

final phoneSessionRepositoryProvider = Provider<PhoneSessionRepository>((ref) {
  return PhoneSessionRepositoryImpl();
});

// ============================================================================
// ViewModel Providers
// ============================================================================

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel();
});

final ordersViewModelProvider =
    StateNotifierProvider<OrdersViewModel, OrdersState>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersViewModel(repository);
});

final merchantContactViewModelProvider =
    StateNotifierProvider<MerchantContactViewModel, MerchantContactState>((ref) {
  final merchantRepo = ref.watch(merchantRepositoryProvider);
  final phoneRepo = ref.watch(phoneSessionRepositoryProvider);
  return MerchantContactViewModel(merchantRepo, phoneRepo);
});

