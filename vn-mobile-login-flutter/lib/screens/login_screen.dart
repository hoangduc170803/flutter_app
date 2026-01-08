import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onComplete() {
    // Bước 1: Hoàn tất nhập số điện thoại -> Chuyển đến màn Orders
    if (_phoneController.text.isNotEmpty) {
      Navigator.pushNamed(
        context, 
        '/orders',
        arguments: _phoneController.text,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số điện thoại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08, // 8% padding
              vertical: size.height * 0.04, // 4% padding
            ),
            child: Column(
              children: [
                // Step indicator
                _buildStepIndicator(),
                
                // Header Section
                _buildHeader(size, isSmallScreen),
                
                SizedBox(height: size.height * 0.05), // 5% spacing
                
                // Phone Input
                _buildPhoneInput(),
                
                SizedBox(height: size.height * 0.03), // 3% spacing
                
                // Action Button
                _buildActionButton(),
                
                SizedBox(height: size.height * 0.03), // 3% spacing
                
                // Terms Text
                _buildTermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Bước 1/5 • Nhập số điện thoại',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    final iconSize = size.width * 0.2; // 20% of screen width
    final iconSizeConstrained = iconSize.clamp(60.0, 100.0);
    
    return Column(
      children: [
        SizedBox(height: size.height * 0.03), // 3% spacing
        
        // Icon Container
        Container(
          width: iconSizeConstrained,
          height: iconSizeConstrained,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // blue-50
            borderRadius: BorderRadius.circular(iconSizeConstrained * 0.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.smartphone,
            size: iconSizeConstrained * 0.45,
            color: const Color(0xFF2563EB), // blue-600
          ),
        ),
        
        SizedBox(height: size.height * 0.03), // 3% spacing
        
        // Welcome Text
        Text(
          'Chào mừng bạn',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827), // gray-900
            letterSpacing: -0.5,
          ),
        ),
        
        SizedBox(height: size.height * 0.01), // 1% spacing
        
        // Subtitle
        Text(
          'Nhập số điện thoại để bắt đầu phiên',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280), // gray-500
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : const Color(0xFFF9FAFB), // gray-50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused 
              ? const Color(0xFF2563EB) // blue-600
              : const Color(0xFFE5E7EB), // gray-200
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Phone Icon
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Icon(
              Icons.phone,
              size: 20,
              color: _isFocused 
                  ? const Color(0xFF2563EB) // blue-600
                  : const Color(0xFF9CA3AF), // gray-400
            ),
          ),
          
          // Text Input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827), // gray-900
              ),
              decoration: const InputDecoration(
                hintText: '090 123 4567',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF), // gray-400
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 20,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
              ],
            ),
          ),
          
          // Country Code Indicator
          AnimatedOpacity(
            opacity: _isFocused ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), // gray-100
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VN +84',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF), // gray-400
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onComplete,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF59E0B), // amber-500
                Color(0xFFD97706), // amber-600
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hoàn tất',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Column(
      children: [
        const Text(
          'Bằng việc tiếp tục, bạn đồng ý với',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF), // gray-400
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTap: () {
            debugPrint('Terms tapped');
          },
          child: const Text(
            'Điều khoản dịch vụ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF), // gray-400
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }
}
