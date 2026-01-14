import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../providers/providers.dart';

/// Navigation event for contact detail
enum ContactDetailNavigationEvent { 
  none, 
  goBack, 
  showCallModal,  // Show masking modal first
  makeCall,       // Actually dial after modal
  sendMessage, 
  sendEmail, 
  videoCall 
}

/// State for Contact Detail screen
class ContactDetailState {
  final ContactDetail? contact;
  final String? phoneNumber;
  final String? virtualNumber;  // Masking number
  final bool isLoading;
  final bool isCallModalVisible;
  final String? error;
  final ContactDetailNavigationEvent navigationEvent;

  const ContactDetailState({
    this.contact,
    this.phoneNumber,
    this.virtualNumber,
    this.isLoading = false,
    this.isCallModalVisible = false,
    this.error,
    this.navigationEvent = ContactDetailNavigationEvent.none,
  });

  ContactDetailState copyWith({
    ContactDetail? contact,
    String? phoneNumber,
    String? virtualNumber,
    bool? isLoading,
    bool? isCallModalVisible,
    String? error,
    ContactDetailNavigationEvent? navigationEvent,
  }) {
    return ContactDetailState(
      contact: contact ?? this.contact,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      virtualNumber: virtualNumber ?? this.virtualNumber,
      isLoading: isLoading ?? this.isLoading,
      isCallModalVisible: isCallModalVisible ?? this.isCallModalVisible,
      error: error,
      navigationEvent: navigationEvent ?? this.navigationEvent,
    );
  }
}

/// ViewModel for Contact Detail screen - Riverpod 3.x Notifier
class ContactDetailViewModel extends Notifier<ContactDetailState> {
  @override
  ContactDetailState build() => const ContactDetailState();

  ContactRepository get _repository => ref.read(contactRepositoryProvider);

  void setPhoneNumber(String? phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  Future<void> loadContactDetail(String contactId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contact = await _repository.getContactDetail(contactId);
      state = state.copyWith(contact: contact, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải thông tin liên hệ',
      );
    }
  }

  void onBackPressed() {
    state = state.copyWith(navigationEvent: ContactDetailNavigationEvent.goBack);
  }

  /// When call button is pressed, show masking modal first
  void onCallPressed() {
    // Generate virtual masking number
    final virtualNum = _generateVirtualNumber();
    state = state.copyWith(
      virtualNumber: virtualNum,
      isCallModalVisible: true,
      navigationEvent: ContactDetailNavigationEvent.showCallModal,
    );
  }

  /// After modal shows, user confirms to make the actual call
  void confirmCall() {
    state = state.copyWith(
      isCallModalVisible: false,
      navigationEvent: ContactDetailNavigationEvent.makeCall,
    );
  }

  /// User dismisses the call modal
  void dismissCallModal() {
    state = state.copyWith(
      isCallModalVisible: false,
      navigationEvent: ContactDetailNavigationEvent.none,
    );
  }

  void onMessagePressed() {
    state = state.copyWith(navigationEvent: ContactDetailNavigationEvent.sendMessage);
  }

  void onVideoPressed() {
    state = state.copyWith(navigationEvent: ContactDetailNavigationEvent.videoCall);
  }

  void onEmailPressed() {
    state = state.copyWith(navigationEvent: ContactDetailNavigationEvent.sendEmail);
  }

  void clearNavigationEvent() {
    state = state.copyWith(navigationEvent: ContactDetailNavigationEvent.none);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ContactDetailState();
  }

  /// Generate a mock virtual number for masking
  String _generateVirtualNumber() {
    // In real app, this would come from API
    return '1900636999';
  }
}
