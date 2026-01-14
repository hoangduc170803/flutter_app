import 'package:flutter/material.dart';

import '../presentation/views/login_view.dart';
import '../presentation/views/contact_list_view.dart';
import '../presentation/views/contact_detail_view.dart';

/// Application route names
class AppRoutes {
  AppRoutes._();

  static const String login = '/';
  static const String contacts = '/contacts';
  static const String contactDetail = '/contact-detail';
  
  // Legacy routes (redirected)
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
      case AppRoutes.contacts:
      case AppRoutes.orders: // Legacy route redirects to contacts
        return _buildRoute(const ContactListView(), settings);
      case AppRoutes.contactDetail:
      case AppRoutes.merchantContact: // Legacy route redirects to contact detail
        return _buildRoute(const ContactDetailView(), settings);
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
