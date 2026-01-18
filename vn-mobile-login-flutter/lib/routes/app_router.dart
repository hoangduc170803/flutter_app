import 'package:flutter/material.dart';

import '../presentation/views/login_view.dart';
import '../presentation/views/order_list_view.dart';
import '../presentation/views/order_accept_view.dart';
import '../presentation/views/order_pickup_view.dart';
import '../presentation/views/order_detail_view.dart';

/// Application route names
class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String orders = '/orders';
  static const String orderAccept = '/order-accept';
  static const String orderPickup = '/order-pickup';
  static const String orderDetail = '/order-detail';
}

/// Application router
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _buildRoute(const LoginView(), settings);
      case AppRoutes.orders:
        return _buildRoute(const OrderListView(), settings);
      case AppRoutes.orderAccept:
        return _buildRoute(const OrderAcceptView(), settings);
      case AppRoutes.orderPickup:
        return _buildRoute(const OrderPickupView(), settings);
      case AppRoutes.orderDetail:
        return _buildRoute(const OrderDetailView(), settings);
      default:
        return _buildRoute(const LoginView(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }
}
