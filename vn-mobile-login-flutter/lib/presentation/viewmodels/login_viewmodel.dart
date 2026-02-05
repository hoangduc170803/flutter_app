import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/pnm_config.dart';
import '../../data/services/pnm_service.dart';

/// State for Login screen
class LoginState {
  final String phoneNumber;
  final String maskedNumber;
  final String? subid;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const LoginState({
    this.phoneNumber = '',
    this.maskedNumber = '',
    this.subid,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  LoginState copyWith({
    String? phoneNumber,
    String? maskedNumber,
    String? subid,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      subid: subid ?? this.subid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

/// ViewModel for Login screen - Riverpod 3.x Notifier
class LoginViewModel extends Notifier<LoginState> {
  late final PnmService _pnmService;

  @override
  LoginState build() {
    _pnmService = PnmService();
    return const LoginState();
  }

  void updatePhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone, error: null);
  }

  /// Submit số điện thoại - gọi PNM API để lấy masked number
  /// View sẽ listen state changes để xử lý navigation/snackbar
  Future<void> submitPhoneNumber(String phoneNumber) async {
    // Validation local
    if (phoneNumber.trim().isEmpty) {
      state = state.copyWith(error: 'Vui lòng nhập số điện thoại');
      return;
    }

    // Clean phone number (remove spaces)
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    // Bắt đầu loading
    state = state.copyWith(
      phoneNumber: cleanPhone,
      isLoading: true,
      error: null,
      isSuccess: false,
    );

    try {
      // Gọi PNM API để tạo binding và lấy masked number
      print('[LoginViewModel] Calling PNM API for phone: $cleanPhone');
      
      final response = await _pnmService.createBinding(
        telA: cleanPhone,
        areacode: '010',
        expiration: '360',
        anucode: ',,0',
      );

      if (response.isSuccess && response.telX != null) {
        // API thành công - lấy được masked number
        print('[LoginViewModel] PNM API success, telX: ${response.telX}, subid: ${response.subid}');
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          maskedNumber: response.telX!,
          subid: response.subid,
        );
      } else {
        // API thất bại - dùng default masked number
        print('[LoginViewModel] PNM API failed: ${response.message}, using default');
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          maskedNumber: PnmConfig.defaultMaskedNumber,
        );
      }
    } catch (e) {
      // Lỗi - dùng default masked number và vẫn cho navigate
      print('[LoginViewModel] Error calling PNM API: $e, using default');
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        maskedNumber: PnmConfig.defaultMaskedNumber,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LoginState();
  }
}
