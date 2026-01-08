import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/phone_utils.dart';
import '../../data/models/order.dart';
import '../providers/providers.dart';
import '../viewmodels/merchant_contact_viewmodel.dart';

class MerchantContactView extends ConsumerStatefulWidget {
  const MerchantContactView({super.key});

  @override
  ConsumerState<MerchantContactView> createState() => _MerchantContactViewState();
}

class _MerchantContactViewState extends ConsumerState<MerchantContactView> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          ref.read(merchantContactViewModelProvider.notifier).setArguments(
            order: args['order'] as Order?,
            phoneNumber: args['phoneNumber'] as String?,
          );
        }
        ref.read(merchantContactViewModelProvider.notifier).loadMerchant();
      });
    }
  }

  Future<void> _makePhoneCall(String virtualNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: virtualNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showCallSnackbar(virtualNumber);
      }
    } catch (e) {
      _showCallSnackbar(virtualNumber);
    }
  }

  void _showCallSnackbar(String virtualNumber) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.phone_in_talk, color: Colors.white),
              const SizedBox(width: 12),
              Text('Đang gọi đến số ${PhoneUtils.formatVirtualNumber(virtualNumber)}...'),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantContactViewModelProvider);

    // Listen để xử lý side effects
    ref.listen(merchantContactViewModelProvider, (previous, current) {
      // Xử lý navigation events
      if (current.navigationEvent != NavigationEvent.none &&
          current.navigationEvent != previous?.navigationEvent) {
        switch (current.navigationEvent) {
          case NavigationEvent.goHome:
            ref.read(merchantContactViewModelProvider.notifier).reset();
            Navigator.popUntil(context, (route) => route.isFirst);
            break;
          case NavigationEvent.makeCall:
            _makePhoneCall(current.virtualNumber);
            ref.read(merchantContactViewModelProvider.notifier).clearNavigationEvent();
            break;
          case NavigationEvent.none:
            break;
        }
      }

      // Show error snackbar
      if (current.error != null && current.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: state.modalState != ModalState.none ? 0.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: state.modalState != ModalState.none,
                child: _buildMainContent(state),
              ),
            ),
            if (state.modalState == ModalState.confirmPhone)
              _buildConfirmModal(state),
            if (state.modalState == ModalState.virtualNumber)
              _buildVirtualNumberModal(state),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(MerchantContactState state) {
    if (state.isLoading && state.merchant == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileSection(state),
                _buildActionGrid(),
                _buildOrderInfo(state),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.02,
        size.height * 0.02,
        size.width * 0.02,
        size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bước 3/5 • Liên hệ Merchant',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left, size: 24),
                color: AppColors.gray700,
              ),
              const Text(
                'Contact Merchant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(MerchantContactState state) {
    final size = MediaQuery.of(context).size;
    final avatarSize = (size.width * 0.25).clamp(80.0, 120.0);
    final merchant = state.merchant;

    if (merchant == null) return const SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.02,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal500.withOpacity(0.15),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2 - 4),
                  child: Image.network(
                    merchant.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.gray200,
                        child: Icon(
                          Icons.person,
                          size: avatarSize * 0.4,
                          color: AppColors.gray400,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            merchant.name,
            style: TextStyle(
              fontSize: size.width < 360 ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.amber700),
                    const SizedBox(width: 4),
                    Text(
                      merchant.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.amber700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${merchant.category}',
                style: const TextStyle(fontSize: 14, color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final size = MediaQuery.of(context).size;
    final buttonSize = (size.width * 0.16).clamp(56.0, 72.0);
    final primaryButtonSize = buttonSize * 1.12;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: size.height * 0.015),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.green100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_in_talk, size: 20, color: AppColors.green600),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhấn nút Call để bắt đầu phiên gọi PNM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.green700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.phone,
                label: 'Call',
                bgColor: AppColors.primaryGreen,
                // ✅ Chỉ trigger action
                onTap: () => ref.read(merchantContactViewModelProvider.notifier).onCallPressed(),
                isPrimary: true,
                buttonSize: primaryButtonSize,
              ),
              _buildActionButton(
                icon: Icons.chat_bubble,
                label: 'Chat',
                bgColor: AppColors.primaryBlue,
                onTap: () {},
                buttonSize: buttonSize,
              ),
              _buildActionButton(
                icon: Icons.videocam,
                label: 'Video',
                bgColor: AppColors.primaryPurple,
                onTap: () {},
                buttonSize: buttonSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
    bool isPrimary = false,
    required double buttonSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(buttonSize * 0.38),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: bgColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: buttonSize * 0.44, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              color: isPrimary ? bgColor : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(MerchantContactState state) {
    if (state.order == null) return const SizedBox();

    final size = MediaQuery.of(context).size;
    final order = state.order!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.06,
        size.height * 0.02,
        size.width * 0.06,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ORDER INFO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gray400,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.date} • ${order.time}',
              style: const TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmModal(MerchantContactState state) {
    final size = MediaQuery.of(context).size;
    final iconSize = (size.width * 0.18).clamp(56.0, 72.0);

    return Container(
      color: AppColors.slate900.withOpacity(0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            padding: EdgeInsets.all(size.width * 0.07),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.amber100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bước 4/5 • Xác nhận số điện thoại',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.amber700,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                Stack(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: AppColors.teal50,
                        borderRadius: BorderRadius.circular(iconSize / 2),
                      ),
                      child: Icon(
                        Icons.smartphone,
                        size: iconSize * 0.44,
                        color: AppColors.teal500,
                      ),
                    ),
                    Positioned(
                      top: iconSize * 0.22,
                      right: iconSize * 0.16,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 12,
                          color: AppColors.teal500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                Text(
                  'Confirm Phone Number',
                  style: TextStyle(
                    fontSize: size.width < 360 ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                const Text(
                  'Please confirm if the following\nnumber is your phone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate500,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                Text(
                  PhoneUtils.maskPhoneNumber(state.phoneNumber),
                  style: TextStyle(
                    fontSize: size.width < 360 ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          // ✅ Chỉ trigger action
                          onTap: () => ref.read(merchantContactViewModelProvider.notifier).onConfirmNo(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Center(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: AppColors.teal500,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          // ✅ Chỉ trigger action
                          onTap: state.isLoading 
                              ? null 
                              : () => ref.read(merchantContactViewModelProvider.notifier).onConfirmYes(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: state.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Yes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVirtualNumberModal(MerchantContactState state) {
    final size = MediaQuery.of(context).size;
    final iconSize = (size.width * 0.18).clamp(56.0, 72.0);

    return Container(
      color: AppColors.slate900.withOpacity(0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            padding: EdgeInsets.all(size.width * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bước 5/5 • Thực hiện cuộc gọi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green700,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(iconSize / 2),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: iconSize * 0.55,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Phiên đã được thiết lập!',
                  style: TextStyle(
                    fontSize: size.width < 360 ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                const Text(
                  'Số điện thoại ảo của bạn:',
                  style: TextStyle(fontSize: 14, color: AppColors.slate500),
                ),
                SizedBox(height: size.height * 0.012),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                  ),
                  child: Text(
                    PhoneUtils.formatVirtualNumber(state.virtualNumber),
                    style: TextStyle(
                      fontSize: size.width < 360 ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield, size: 16, color: AppColors.primaryGreen),
                    SizedBox(width: 6),
                    Text(
                      'Số thật của bạn được bảo mật',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Material(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    // ✅ Chỉ trigger action
                    onTap: () => ref.read(merchantContactViewModelProvider.notifier).onMakeCallPressed(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Gọi ngay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 16, color: AppColors.slate500),
                      SizedBox(width: 6),
                      Text(
                        'Nhấn để mở app điện thoại',
                        style: TextStyle(fontSize: 11, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                TextButton(
                  // ✅ Chỉ trigger action
                  onPressed: () => ref.read(merchantContactViewModelProvider.notifier).onClosePressed(),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
