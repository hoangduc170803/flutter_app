import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../providers/providers.dart';
import '../widgets/order_card.dart';

class OrdersView extends ConsumerStatefulWidget {
  const OrdersView({super.key});

  @override
  ConsumerState<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends ConsumerState<OrdersView> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
        ref.read(ordersViewModelProvider.notifier).setPhoneNumber(phoneNumber);
        ref.read(ordersViewModelProvider.notifier).loadOrders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersViewModelProvider);
    final size = MediaQuery.of(context).size;

    // ✅ Listen để xử lý side effects
    ref.listen(ordersViewModelProvider, (previous, current) {
      // Navigation khi select order
      if (current.selectedOrder != null && 
          current.selectedOrder != previous?.selectedOrder) {
        Navigator.pushNamed(
          context,
          '/merchant-contact',
          arguments: {
            'order': current.selectedOrder,
            'phoneNumber': current.phoneNumber,
          },
        );
        // Clear sau khi navigate
        ref.read(ordersViewModelProvider.notifier).clearSelectedOrder();
      }

      // Show error snackbar
      if (current.error != null && current.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            backgroundColor: AppColors.primaryRed,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                ref.read(ordersViewModelProvider.notifier).loadOrders();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state.phoneNumber, size),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildOrdersList(state, size),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(state, Size size) {
    if (state.error != null && state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(state.error!, style: const TextStyle(color: AppColors.gray500)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(ordersViewModelProvider.notifier).loadOrders(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return OrderCard(
          order: order,
          // Chỉ trigger action, không navigate trực tiếp
          onTap: () => ref.read(ordersViewModelProvider.notifier).selectOrder(order),
        );
      },
    );
  }

  Widget _buildHeader(String? phoneNumber, Size size) {
    final isSmallScreen = size.height < 600;

    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.05,
        size.height * 0.02,
        size.width * 0.05,
        size.height * 0.015,
      ),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bước 2/5 • Chọn đơn hàng',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.015),
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
                        color: AppColors.gray900,
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
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNotificationButton(),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          _buildHintCard(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              size: 24,
              color: AppColors.gray600,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amber100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app, size: 20, color: AppColors.amber700),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nhấn vào đơn hàng để xem thông tin merchant',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.amber700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
