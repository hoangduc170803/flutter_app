import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../providers/providers.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _phoneFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.removeListener(_onFocusChange);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  /// Handler cho nút Hoàn tất - chỉ gọi submit, không xử lý navigation
  void _onComplete() {
    FocusScope.of(context).unfocus();
    ref.read(loginViewModelProvider.notifier).submitPhoneNumber(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    // Listen để xử lý side effects (navigation, snackbar)
    ref.listen(loginViewModelProvider, (previous, current) {
      // Xử lý navigation khi success
      if (current.isSuccess && !(previous?.isSuccess ?? false)) {
        Navigator.pushNamed(
          context,
          '/orders',
          arguments: current.phoneNumber,
        );
        // Reset state sau khi navigate
        ref.read(loginViewModelProvider.notifier).reset();
      }

      // Xử lý hiển thị error
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.04,
            ),
            child: Column(
              children: [
                _buildStepIndicator(),
                _buildHeader(size, isSmallScreen),
                SizedBox(height: size.height * 0.05),
                _buildPhoneInput(state.isLoading),
                SizedBox(height: size.height * 0.03),
                _buildActionButton(state.isLoading),
                SizedBox(height: size.height * 0.03),
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
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Bước 1/5 • Nhập số điện thoại',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    final iconSize = (size.width * 0.2).clamp(60.0, 100.0);

    return Column(
      children: [
        SizedBox(height: size.height * 0.03),
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(iconSize * 0.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.smartphone,
            size: iconSize * 0.45,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Text(
          'Chào mừng bạn',
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          'Nhập số điện thoại để bắt đầu phiên',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: _isFocused ? AppColors.surface : AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppColors.primaryBlue : AppColors.gray200,
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
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Icon(
              Icons.phone,
              size: 20,
              color: _isFocused ? AppColors.primaryBlue : AppColors.gray400,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              enabled: !isLoading,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
              decoration: const InputDecoration(
                hintText: '090 123 4567',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray400,
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
          AnimatedOpacity(
            opacity: _isFocused ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VN +84',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isLoading) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : _onComplete,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [AppColors.gray400, AppColors.gray500]
                  : [AppColors.amber500, AppColors.amber600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isLoading
                ? null
                : [
                    BoxShadow(
                      color: AppColors.amber500.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Đang xử lý...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Hoàn tất',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                ],
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
          style: TextStyle(fontSize: 12, color: AppColors.gray400, height: 1.5),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTap: () => debugPrint('Terms tapped'),
          child: const Text(
            'Điều khoản dịch vụ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray400,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.gray400,
            ),
          ),
        ),
      ],
    );
  }
}
