import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for Login screen
class LoginState {
  final String phoneNumber;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const LoginState({
    this.phoneNumber = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  LoginState copyWith({
    String? phoneNumber,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

/// ViewModel for Login screen - Riverpod 3.x Notifier
class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void updatePhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone, error: null);
  }

  /// Submit số điện thoại - không return, chỉ update state
  /// View sẽ listen state changes để xử lý navigation/snackbar
  Future<void> submitPhoneNumber(String phoneNumber) async {
    // Validation local
    if (phoneNumber.trim().isEmpty) {
      state = state.copyWith(error: 'Vui lòng nhập số điện thoại');
      return;
    }

    // Bắt đầu loading
    state = state.copyWith(
      phoneNumber: phoneNumber,
      isLoading: true,
      error: null,
      isSuccess: false,
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // Thành công - View sẽ listen và navigate
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      // Lỗi - View sẽ listen và show snackbar
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
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
