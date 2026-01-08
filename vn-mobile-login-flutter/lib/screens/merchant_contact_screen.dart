import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/merchant.dart';
import '../models/order.dart';

class MerchantContactScreen extends StatefulWidget {
  const MerchantContactScreen({super.key});

  @override
  State<MerchantContactScreen> createState() => _MerchantContactScreenState();
}

class _MerchantContactScreenState extends State<MerchantContactScreen> {
  bool _showConfirmModal = false;
  bool _showVirtualNumber = false;
  String? _phoneNumber;
  Order? _order;
  
  final String _virtualNumber = '1900636999'; // Số ảo được cấp

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phoneNumber = args['phoneNumber'] as String?;
      _order = args['order'] as Order?;
    }
  }

  void _onCallPressed() {
    // Bước 3: Khi nhấn Call, hiển thị modal xác nhận
    setState(() {
      _showConfirmModal = true;
    });
  }

  void _onConfirmYes() {
    // Bước 4: Xác nhận -> Hiển thị kết quả số ảo
    setState(() {
      _showConfirmModal = false;
      _showVirtualNumber = true;
    });
  }

  void _onConfirmNo() {
    setState(() {
      _showConfirmModal = false;
    });
  }

  Future<void> _makePhoneCall() async {
    // Bước 5: Mở app điện thoại mặc định với số ảo
    final Uri phoneUri = Uri(scheme: 'tel', path: _virtualNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback cho web - hiển thị thông báo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Đang gọi đến số ${_formatVirtualNumber(_virtualNumber)}...'),
                ],
              ),
              backgroundColor: const Color(0xFF22C55E),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.phone, color: Colors.white),
                const SizedBox(width: 12),
                Text('Gọi số: ${_formatVirtualNumber(_virtualNumber)}'),
              ],
            ),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    }
  }

  void _onClose() {
    // Quay về màn hình đầu
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  String _maskPhoneNumber(String? phone) {
    if (phone == null || phone.length < 4) return '098****232';
    final cleaned = phone.replaceAll(' ', '');
    if (cleaned.length >= 7) {
      return '${cleaned.substring(0, 3)}****${cleaned.substring(cleaned.length - 3)}';
    }
    return '098****232';
  }

  String _formatVirtualNumber(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            AnimatedOpacity(
              opacity: (_showConfirmModal || _showVirtualNumber) ? 0.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: _showConfirmModal || _showVirtualNumber,
                child: _buildMainContent(),
              ),
            ),
            
            // Confirm Modal (Bước 4)
            if (_showConfirmModal)
              _buildConfirmModal(),
            
            // Virtual Number Result + Call Button (Bước 5)
            if (_showVirtualNumber)
              _buildVirtualNumberModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileSection(),
                _buildActionGrid(),
                _buildOrderInfo(),
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
        size.width * 0.02, // 2% left
        size.height * 0.02, // 2% top
        size.width * 0.02, // 2% right
        size.height * 0.01, // 1% bottom
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC).withOpacity(0.8),
      ),
      child: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
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
          
          SizedBox(height: size.height * 0.01), // 1% spacing
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left, size: 24),
                color: const Color(0xFF374151),
              ),
              const Text(
                'Contact Merchant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
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

  Widget _buildProfileSection() {
    final size = MediaQuery.of(context).size;
    final avatarSize = (size.width * 0.25).clamp(80.0, 120.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06, // 6% padding
        vertical: size.height * 0.02, // 2% padding
      ),
      child: Column(
        children: [
          // Avatar
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
                      color: const Color(0xFF38B2AC).withOpacity(0.15),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2 - 4),
                  child: Image.network(
                    mockMerchant.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE5E7EB),
                        child: Icon(Icons.person, size: avatarSize * 0.4, color: const Color(0xFF9CA3AF)),
                      );
                    },
                  ),
                ),
              ),
              // Online Indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: size.height * 0.015), // 1.5% spacing
          
          // Name
          Text(
            mockMerchant.name,
            style: TextStyle(
              fontSize: size.width < 360 ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Rating & Category
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text(
                      mockMerchant.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${mockMerchant.category}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
          // Hint for Call button
          Container(
            margin: EdgeInsets.only(bottom: size.height * 0.015),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_in_talk, size: 20, color: Color(0xFF16A34A)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhấn nút Call để bắt đầu phiên gọi PNM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF166534),
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
                bgColor: const Color(0xFF22C55E),
                onTap: _onCallPressed,
                isPrimary: true,
                buttonSize: primaryButtonSize,
              ),
              _buildActionButton(
                icon: Icons.chat_bubble,
                label: 'Chat',
                bgColor: const Color(0xFF3B82F6),
                onTap: () {},
                buttonSize: buttonSize,
              ),
              _buildActionButton(
                icon: Icons.videocam,
                label: 'Video',
                bgColor: const Color(0xFF8B5CF6),
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
              boxShadow: isPrimary ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Icon(icon, size: buttonSize * 0.44, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              color: isPrimary ? bgColor : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    if (_order == null) return const SizedBox();
    
    final size = MediaQuery.of(context).size;
    
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
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ORDER INFO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${_order!.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '\$${_order!.total.toStringAsFixed(2)}',
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
              '${_order!.date} • ${_order!.time}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmModal() {
    final size = MediaQuery.of(context).size;
    final iconSize = (size.width * 0.18).clamp(56.0, 72.0);
    
    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.6),
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
                // Step indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bước 4/5 • Xác nhận số điện thoại',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.025),
                
                // Icon
                Stack(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(iconSize / 2),
                      ),
                      child: Icon(
                        Icons.smartphone,
                        size: iconSize * 0.44,
                        color: const Color(0xFF14B8A6),
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
                          color: Color(0xFF14B8A6),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: size.height * 0.025),
                
                // Title
                Text(
                  'Confirm Phone Number',
                  style: TextStyle(
                    fontSize: size.width < 360 ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                
                SizedBox(height: size.height * 0.012),
                
                // Description
                const Text(
                  'Please confirm if the following\nnumber is your phone number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: size.height * 0.025),
                
                // Phone Number
                Text(
                  _maskPhoneNumber(_phoneNumber),
                  style: TextStyle(
                    fontSize: size.width < 360 ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: 2,
                  ),
                ),
                
                SizedBox(height: size.height * 0.03),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _onConfirmNo,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Center(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
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
                        color: const Color(0xFF14B8A6),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _onConfirmYes,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Center(
                              child: Text(
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

  Widget _buildVirtualNumberModal() {
    final size = MediaQuery.of(context).size;
    final iconSize = (size.width * 0.18).clamp(56.0, 72.0);
    
    return Container(
      color: const Color(0xFF0F172A).withOpacity(0.6),
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
                // Step indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bước 5/5 • Thực hiện cuộc gọi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.02),
                
                // Success Icon
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(iconSize / 2),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: iconSize * 0.55,
                    color: const Color(0xFF22C55E),
                  ),
                ),
                
                SizedBox(height: size.height * 0.02),
                
                // Title
                Text(
                  'Phiên đã được thiết lập!',
                  style: TextStyle(
                    fontSize: size.width < 360 ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                
                SizedBox(height: size.height * 0.008),
                
                // Description
                const Text(
                  'Số điện thoại ảo của bạn:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                
                SizedBox(height: size.height * 0.012),
                
                // Virtual Number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                  ),
                  child: Text(
                    _formatVirtualNumber(_virtualNumber),
                    style: TextStyle(
                      fontSize: size.width < 360 ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                SizedBox(height: size.height * 0.012),
                
                // Info text
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield, size: 16, color: Color(0xFF22C55E)),
                    SizedBox(width: 6),
                    Text(
                      'Số thật của bạn được bảo mật',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: size.height * 0.02),
                
                // Call Button - Mở app điện thoại
                Material(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _makePhoneCall,
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
                
                // Hint
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 16, color: Color(0xFF64748B)),
                      SizedBox(width: 6),
                      Text(
                        'Nhấn để mở app điện thoại',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: size.height * 0.012),
                
                // Close button
                TextButton(
                  onPressed: _onClose,
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
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
