import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/order_repository.dart';
import '../../data/services/pnm_service.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';

// ============================================================================
// Service Providers
// ============================================================================

/// PNM Service provider for API calls
final pnmServiceProvider = Provider<PnmService>((ref) {
  return PnmService();
});

/// Simple store for driver phone number (set after login)
class DriverPhoneStore {
  static String _driverPhone = '';
  
  static String get phone => _driverPhone;
  static void setPhone(String phone) => _driverPhone = phone;
}

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
