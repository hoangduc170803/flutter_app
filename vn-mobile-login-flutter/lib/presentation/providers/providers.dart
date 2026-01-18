import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';

// ============================================================================
// ViewModel Providers - Riverpod 3.x NotifierProvider
// ============================================================================

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);

final orderStateProvider =
    NotifierProvider<OrderViewModel, OrderState>(OrderViewModel.new);
