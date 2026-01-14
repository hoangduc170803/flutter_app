import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/contact_repository.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/contact_list_viewmodel.dart';
import '../viewmodels/contact_detail_viewmodel.dart';

// ============================================================================
// Repository Providers
// ============================================================================

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepositoryImpl();
});

// ============================================================================
// ViewModel Providers - Riverpod 3.x NotifierProvider
// ============================================================================

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);

final contactListViewModelProvider =
    NotifierProvider<ContactListViewModel, ContactListState>(ContactListViewModel.new);

final contactDetailViewModelProvider =
    NotifierProvider<ContactDetailViewModel, ContactDetailState>(ContactDetailViewModel.new);
