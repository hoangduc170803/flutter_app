import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../providers/providers.dart';
import '../viewmodels/login_viewmodel.dart';

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

  void _onComplete() {
    FocusScope.of(context).unfocus();
    ref.read(loginViewModelProvider.notifier).submitPhoneNumber(_phoneController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    ref.listen<LoginState>(loginViewModelProvider, (previous, current) {
      if (current.isSuccess && !(previous?.isSuccess ?? false)) {
        Navigator.pushNamed(
          context,
          '/orders',
          arguments: current.phoneNumber,
        );
        ref.read(loginViewModelProvider.notifier).reset();
      }

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
              horizontal: 30.w,
              vertical: 32.h,
            ),
            child: Column(
              children: [
                _buildStepIndicator(),
                _buildHeader(),
                SizedBox(height: 40.h),
                _buildPhoneInput(state.isLoading),
                SizedBox(height: 24.h),
                _buildActionButton(state.isLoading),
                SizedBox(height: 24.h),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'Bước 1/5 • Nhập số điện thoại',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 24.h),
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: AppColors.blue50,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Icon(
            Icons.smartphone,
            size: 36.sp,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Chào mừng bạn',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Nhập số điện thoại để bắt đầu phiên',
          style: TextStyle(
            fontSize: 14.sp,
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _isFocused ? AppColors.primaryBlue : AppColors.gray200,
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Icon(
              Icons.phone,
              size: 20.sp,
              color: _isFocused ? AppColors.primaryBlue : AppColors.gray400,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              enabled: !isLoading,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
              decoration: InputDecoration(
                hintText: '090 123 4567',
                hintStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 20.h,
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
              margin: EdgeInsets.only(right: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'VN +84',
                style: TextStyle(
                  fontSize: 12.sp,
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
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [AppColors.gray400, AppColors.gray500]
                  : [AppColors.amber500, AppColors.amber600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isLoading
                ? null
                : [
                    BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.3),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Đang xử lý...',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Hoàn tất',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 20.sp, color: Colors.white),
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
        Text(
          'Bằng việc tiếp tục, bạn đồng ý với',
          style: TextStyle(fontSize: 12.sp, color: AppColors.gray400, height: 1.5),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTap: () => debugPrint('Terms tapped'),
          child: Text(
            'Điều khoản dịch vụ',
            style: TextStyle(
              fontSize: 12.sp,
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
