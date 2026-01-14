import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/contact.dart';
import '../providers/providers.dart';
import '../viewmodels/contact_list_viewmodel.dart';
import '../widgets/call_masking_modal.dart';

class ContactListView extends ConsumerStatefulWidget {
  const ContactListView({super.key});

  @override
  ConsumerState<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends ConsumerState<ContactListView> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
        ref.read(contactListViewModelProvider.notifier).setUserInfo(
          phoneNumber: phoneNumber ?? '0989999999',
          username: 'ducnh40',
        );
        ref.read(contactListViewModelProvider.notifier).loadContacts();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showCallMaskingModal(ContactListState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CallMaskingModal(
        contactName: state.selectedContact?.name,
        virtualNumber: state.virtualNumber ?? '1900636999',
        onConfirm: () {
          Navigator.pop(context);
          ref.read(contactListViewModelProvider.notifier).confirmCall();
        },
        onCancel: () {
          Navigator.pop(context);
          ref.read(contactListViewModelProvider.notifier).dismissCallModal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactListViewModelProvider);

    ref.listen<ContactListState>(contactListViewModelProvider, (previous, current) {
      if (current.navigationEvent != ContactListNavigationEvent.none &&
          current.navigationEvent != previous?.navigationEvent) {
        switch (current.navigationEvent) {
          case ContactListNavigationEvent.goToDetail:
            if (current.selectedContact != null) {
              Navigator.pushNamed(
                context,
                '/contact-detail',
                arguments: {
                  'contactId': current.selectedContact!.id,
                  'phoneNumber': current.phoneNumber,
                },
              );
            }
            ref.read(contactListViewModelProvider.notifier).clearNavigationEvent();
            break;
          case ContactListNavigationEvent.showCallModal:
            _showCallMaskingModal(current);
            break;
          case ContactListNavigationEvent.makeCall:
            _makePhoneCall(current.virtualNumber ?? '1900636999');
            ref.read(contactListViewModelProvider.notifier).clearNavigationEvent();
            break;
          case ContactListNavigationEvent.none:
            break;
        }
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
        child: Column(
          children: [
            _buildHeader(state),
            Expanded(
              child: state.isLoading && state.groups.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
                  : _buildContactList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ContactListState state) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info badges
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                _buildBadge(Icons.person, state.username ?? 'User'),
                SizedBox(width: 8.w),
                _buildBadge(Icons.call, '0989999999'),
              ],
            ),
          ),
          
          // Title and Add button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: AppColors.gray900),
                    iconSize: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 8.w),
                    child: Icon(Icons.search, color: AppColors.gray400, size: 20.sp),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref.read(contactListViewModelProvider.notifier).search(value);
                      },
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search name or company...',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.primaryAmber.withValues(alpha: 0.8)),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryAmber.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList(ContactListState state) {
    if (state.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48.sp, color: AppColors.gray400),
            SizedBox(height: 16.h),
            Text(
              'No contacts found matching "${state.searchQuery}"',
              style: TextStyle(color: AppColors.gray500, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.groups.length,
      itemBuilder: (context, groupIndex) {
        final group = state.groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                border: const Border(
                  bottom: BorderSide(color: AppColors.gray100),
                ),
              ),
              child: Text(
                group.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryAmber,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Contact items
            ...group.contacts.map((contact) => _ContactItem(
              contact: contact,
              onTap: () => ref.read(contactListViewModelProvider.notifier).selectContact(contact),
              onCallTap: () => ref.read(contactListViewModelProvider.notifier).callContact(contact),
            )),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// Contact Item
// ===========================================================================

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onCallTap;

  const _ContactItem({
    required this.contact,
    required this.onTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    contact.company,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onCallTap,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.call,
                  size: 20.sp,
                  color: AppColors.primaryAmber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (contact.hasAvatar) {
      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.gray200),
          image: DecorationImage(
            image: AssetImage(contact.avatarAsset!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: contact.initialsBgColor ?? AppColors.gray100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: Text(
          contact.displayInitials,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: contact.initialsTextColor ?? AppColors.gray600,
          ),
        ),
      ),
    );
  }
}
