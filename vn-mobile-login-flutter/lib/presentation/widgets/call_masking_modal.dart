import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/phone_utils.dart';

/// Reusable Call Masking Modal Widget
/// Used in both ContactListView and ContactDetailView
class CallMaskingModal extends StatelessWidget {
  final String? contactName;
  final String virtualNumber;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CallMaskingModal({
    super.key,
    this.contactName,
    required this.virtualNumber,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final formattedVirtual = PhoneUtils.formatVirtualNumber(virtualNumber);

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 40.r,
                    offset: Offset(0, 20.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 48.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    'Confirm Call',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.modalTextDark,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Bạn có muốn gọi thông qua số ảo này không?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Virtual number display
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    decoration: BoxDecoration(
                      color: AppColors.modalBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      formattedVirtual,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.modalTextDark,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Action buttons
                  Row(
                    children: [
                      // Call button
                      Expanded(
                        child: GestureDetector(
                          onTap: onConfirm,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: AppColors.modalPrimaryOrange,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.modalPrimaryOrange.withValues(alpha: 0.3),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.call, color: Colors.white, size: 22.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Gọi ngay',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: AppColors.modalBackground,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Security footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 14.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'SECURE CLOUD CONNECTION',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

