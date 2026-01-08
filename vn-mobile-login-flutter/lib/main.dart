import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/merchant_contact_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PNM Demo - Phone Number Masking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Bắt đầu từ màn hình Login (Bước 1)
      home: const LoginScreen(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/orders':
            page = const MyOrdersScreen();
            break;
          case '/merchant-contact':
            page = const MerchantContactScreen();
            break;
          default:
            page = const LoginScreen();
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }
}
