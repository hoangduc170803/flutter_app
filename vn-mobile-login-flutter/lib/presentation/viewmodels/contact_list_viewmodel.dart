import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';
import '../providers/providers.dart';

/// Navigation event for contact list
enum ContactListNavigationEvent { 
  none, 
  goToDetail, 
  showCallModal,  // Show masking modal first
  makeCall        // Actually dial after modal
}

/// State for Contact List screen
class ContactListState {
  final List<ContactGroup> groups;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final String? phoneNumber;
  final String? username;
  final String? virtualNumber;  // Masking number
  final Contact? selectedContact;
  final ContactListNavigationEvent navigationEvent;

  const ContactListState({
    this.groups = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.phoneNumber,
    this.username,
    this.virtualNumber,
    this.selectedContact,
    this.navigationEvent = ContactListNavigationEvent.none,
  });

  ContactListState copyWith({
    List<ContactGroup>? groups,
    String? searchQuery,
    bool? isLoading,
    String? error,
    String? phoneNumber,
    String? username,
    String? virtualNumber,
    Contact? selectedContact,
    ContactListNavigationEvent? navigationEvent,
    bool clearSelectedContact = false,
  }) {
    return ContactListState(
      groups: groups ?? this.groups,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      virtualNumber: virtualNumber ?? this.virtualNumber,
      selectedContact: clearSelectedContact ? null : (selectedContact ?? this.selectedContact),
      navigationEvent: navigationEvent ?? this.navigationEvent,
    );
  }
}

/// ViewModel for Contact List screen - Riverpod 3.x Notifier
class ContactListViewModel extends Notifier<ContactListState> {
  @override
  ContactListState build() => const ContactListState();

  ContactRepository get _repository => ref.read(contactRepositoryProvider);

  void setUserInfo({String? phoneNumber, String? username}) {
    state = state.copyWith(phoneNumber: phoneNumber, username: username);
  }

  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final groups = await _repository.getContactGroups();
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách liên hệ',
      );
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    try {
      final groups = await _repository.searchContacts(query);
      state = state.copyWith(groups: groups, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectContact(Contact contact) {
    state = state.copyWith(
      selectedContact: contact,
      navigationEvent: ContactListNavigationEvent.goToDetail,
    );
  }

  /// When call button is pressed, show masking modal first
  void callContact(Contact contact) {
    final virtualNum = _generateVirtualNumber();
    state = state.copyWith(
      selectedContact: contact,
      virtualNumber: virtualNum,
      navigationEvent: ContactListNavigationEvent.showCallModal,
    );
  }

  /// After modal shows, user confirms to make the actual call
  void confirmCall() {
    state = state.copyWith(
      navigationEvent: ContactListNavigationEvent.makeCall,
    );
  }

  /// User dismisses the call modal
  void dismissCallModal() {
    state = state.copyWith(
      navigationEvent: ContactListNavigationEvent.none,
      clearSelectedContact: true,
    );
  }

  void clearNavigationEvent() {
    state = state.copyWith(
      navigationEvent: ContactListNavigationEvent.none,
      clearSelectedContact: true,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Generate a mock virtual number for masking
  String _generateVirtualNumber() {
    // In real app, this would come from API
    return '1900636999';
  }
}
