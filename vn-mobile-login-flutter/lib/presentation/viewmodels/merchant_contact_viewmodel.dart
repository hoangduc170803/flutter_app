import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/merchant.dart';
import '../../data/models/order.dart';
import '../../data/repositories/merchant_repository.dart';
import '../../data/repositories/phone_session_repository.dart';

/// Modal state for merchant contact
enum ModalState { none, confirmPhone, virtualNumber }

/// Navigation event
enum NavigationEvent { none, goHome, makeCall }

/// State for Merchant Contact screen
class MerchantContactState {
  final Merchant? merchant;
  final Order? order;
  final String? phoneNumber;
  final String virtualNumber;
  final ModalState modalState;
  final bool isLoading;
  final String? error;
  final NavigationEvent navigationEvent;

  const MerchantContactState({
    this.merchant,
    this.order,
    this.phoneNumber,
    this.virtualNumber = '',
    this.modalState = ModalState.none,
    this.isLoading = false,
    this.error,
    this.navigationEvent = NavigationEvent.none,
  });

  MerchantContactState copyWith({
    Merchant? merchant,
    Order? order,
    String? phoneNumber,
    String? virtualNumber,
    ModalState? modalState,
    bool? isLoading,
    String? error,
    NavigationEvent? navigationEvent,
  }) {
    return MerchantContactState(
      merchant: merchant ?? this.merchant,
      order: order ?? this.order,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      virtualNumber: virtualNumber ?? this.virtualNumber,
      modalState: modalState ?? this.modalState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      navigationEvent: navigationEvent ?? this.navigationEvent,
    );
  }
}

/// ViewModel for Merchant Contact screen
class MerchantContactViewModel extends StateNotifier<MerchantContactState> {
  final MerchantRepository _merchantRepository;
  final PhoneSessionRepository _phoneSessionRepository;

  MerchantContactViewModel(
    this._merchantRepository,
    this._phoneSessionRepository,
  ) : super(const MerchantContactState());

  void setArguments({Order? order, String? phoneNumber}) {
    state = state.copyWith(order: order, phoneNumber: phoneNumber);
  }

  Future<void> loadMerchant() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final merchant = await _merchantRepository.getDefaultMerchant();
      state = state.copyWith(merchant: merchant, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải thông tin merchant',
      );
    }
  }

  /// Nhấn nút Call - hiển thị modal confirm
  void onCallPressed() {
    state = state.copyWith(modalState: ModalState.confirmPhone);
  }

  /// Xác nhận Yes - tạo session và lấy số ảo
  Future<void> onConfirmYes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessionId = await _phoneSessionRepository.createSession(
        state.phoneNumber ?? '',
      );
      final virtualNumber = await _phoneSessionRepository.getVirtualNumber(
        sessionId,
      );
      state = state.copyWith(
        virtualNumber: virtualNumber,
        modalState: ModalState.virtualNumber,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        modalState: ModalState.none,
        error: 'Không thể tạo phiên gọi',
      );
    }
  }

  /// Xác nhận No - đóng modal
  void onConfirmNo() {
    state = state.copyWith(modalState: ModalState.none);
  }

  /// Nhấn nút Gọi ngay - trigger event để View thực hiện
  void onMakeCallPressed() {
    state = state.copyWith(navigationEvent: NavigationEvent.makeCall);
  }

  /// Clear navigation event sau khi xử lý
  void clearNavigationEvent() {
    state = state.copyWith(navigationEvent: NavigationEvent.none);
  }

  /// Nhấn nút Đóng - về màn hình home
  void onClosePressed() {
    state = state.copyWith(
      modalState: ModalState.none,
      navigationEvent: NavigationEvent.goHome,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const MerchantContactState();
  }
}
