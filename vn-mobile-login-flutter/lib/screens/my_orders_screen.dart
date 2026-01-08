import 'package:flutter/material.dart';
import '../models/order.dart';
import '../widgets/order_card.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy số điện thoại từ màn hình trước (nếu có)
    final phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // gray-50
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, phoneNumber, size),
            
            // Orders List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05, // 5% padding
                  vertical: size.height * 0.02, // 2% padding
                ),
                itemCount: mockOrders.length,
                itemBuilder: (context, index) {
                  return OrderCard(
                    order: mockOrders[index],
                    onTap: () {
                      // Bước 2 -> 3: Click vào order để xem thông tin merchant
                      Navigator.pushNamed(
                        context,
                        '/merchant-contact',
                        arguments: {
                          'order': mockOrders[index],
                          'phoneNumber': phoneNumber,
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? phoneNumber, Size size) {
    final isSmallScreen = size.height < 600;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.05, // 5% left
        size.height * 0.02, // 2% top
        size.width * 0.05, // 5% right
        size.height * 0.015, // 1.5% bottom
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bước 2/5 • Chọn đơn hàng',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9333EA),
              ),
            ),
          ),
          
          SizedBox(height: size.height * 0.015), // 1.5% spacing
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827), // gray-900
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber != null 
                          ? 'SĐT: $phoneNumber' 
                          : 'Chọn đơn hàng để liên hệ merchant',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280), // gray-500
                      ),
                    ),
                  ],
                ),
              ),
              // Bell Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        size: 24,
                        color: Color(0xFF4B5563), // gray-600
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444), // red-500
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: size.height * 0.01), // 1% spacing
          
          // Hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app, size: 20, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhấn vào đơn hàng để xem thông tin merchant',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
