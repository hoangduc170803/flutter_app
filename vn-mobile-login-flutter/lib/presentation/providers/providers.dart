import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/order_repository.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';

// ============================================================================
// Repository Providers
// ============================================================================

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

// ============================================================================
// ViewModel Providers - Riverpod 3.x NotifierProvider
// ============================================================================

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);

final orderViewModelProvider =
    NotifierProvider<OrderViewModel, OrderState>(OrderViewModel.new);
