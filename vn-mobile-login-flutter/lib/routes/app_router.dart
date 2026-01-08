import 'package:flutter/material.dart';

import '../presentation/views/login_view.dart';
import '../presentation/views/orders_view.dart';
import '../presentation/views/merchant_contact_view.dart';

/// Application route names
class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String orders = '/orders';
  static const String merchantContact = '/merchant-contact';
}

/// Application router
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _buildRoute(const LoginView(), settings);
      case AppRoutes.orders:
        return _buildRoute(const OrdersView(), settings);
      case AppRoutes.merchantContact:
        return _buildRoute(const MerchantContactView(), settings);
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

