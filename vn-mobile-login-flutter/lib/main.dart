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
      home: const MobileFrame(child: LoginScreen()),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/orders':
            page = MobileFrame(
              child: const MyOrdersScreen(),
              arguments: settings.arguments,
            );
            break;
          case '/merchant-contact':
            page = MobileFrame(
              child: const MerchantContactScreen(),
              arguments: settings.arguments,
            );
            break;
          default:
            page = const MobileFrame(child: LoginScreen());
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }
}

/// Mobile frame container that simulates a phone device
class MobileFrame extends StatelessWidget {
  final Widget child;
  final Object? arguments;
  
  const MobileFrame({
    super.key, 
    required this.child,
    this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SafeArea(
        child: Column(
          children: [
            // Demo Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      size: 20,
                      color: Color(0xFF60A5FA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PNM Demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Phone Number Masking Flow',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Phone Frame
            Expanded(
              child: Center(
                child: Container(
                  width: 380,
                  height: 720,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: const Color(0xFF111827),
                      width: 8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        // Content
                        Column(
                          children: [
                            // Status Bar
                            _buildStatusBar(),
                            
                            // Screen Content
                            Expanded(child: child),
                            
                            // Home Indicator
                            _buildHomeIndicator(),
                          ],
                        ),
                        
                        // Notch
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF111827),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Flow Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: _FlowStep(step: '1', label: 'SĐT', isActive: true),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
                    Expanded(
                      child: _FlowStep(step: '2', label: 'Order'),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
                    Expanded(
                      child: _FlowStep(step: '3', label: 'Merchant'),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
                    Expanded(
                      child: _FlowStep(step: '4', label: 'Xác nhận'),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF64748B)),
                    Expanded(
                      child: _FlowStep(step: '5', label: 'Gọi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 44,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 16, color: Color(0xFF111827)),
              SizedBox(width: 6),
              Icon(Icons.wifi, size: 16, color: Color(0xFF111827)),
              SizedBox(width: 6),
              Icon(Icons.battery_full, size: 16, color: Color(0xFF111827)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Container(
      height: 28,
      color: Colors.white,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: 120,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String step;
  final String label;
  final bool isActive;

  const _FlowStep({
    required this.step,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF475569),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
