import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/contact.dart';
import '../providers/providers.dart';
import '../viewmodels/contact_detail_viewmodel.dart';
import '../widgets/call_masking_modal.dart';

class ContactDetailView extends ConsumerStatefulWidget {
  const ContactDetailView({super.key});

  @override
  ConsumerState<ContactDetailView> createState() => _ContactDetailViewState();
}

class _ContactDetailViewState extends ConsumerState<ContactDetailView> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          final contactId = args['contactId'] as String?;
          final phoneNumber = args['phoneNumber'] as String?;
          ref.read(contactDetailViewModelProvider.notifier).setPhoneNumber(phoneNumber);
          if (contactId != null) {
            ref.read(contactDetailViewModelProvider.notifier).loadContactDetail(contactId);
          }
        }
      });
    }
  }

  Future<void> _launchUrl(String scheme, String path) async {
    final Uri uri = Uri(scheme: scheme, path: path);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $scheme')),
        );
      }
    }
  }

  void _showCallMaskingModal(ContactDetailState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CallMaskingModal(
        contactName: state.contact?.fullName,
        virtualNumber: state.virtualNumber ?? '1900636999',
        onConfirm: () {
          Navigator.pop(context);
          ref.read(contactDetailViewModelProvider.notifier).confirmCall();
        },
        onCancel: () {
          Navigator.pop(context);
          ref.read(contactDetailViewModelProvider.notifier).dismissCallModal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactDetailViewModelProvider);

    ref.listen<ContactDetailState>(contactDetailViewModelProvider, (previous, current) {
      if (current.navigationEvent != ContactDetailNavigationEvent.none &&
          current.navigationEvent != previous?.navigationEvent) {
        switch (current.navigationEvent) {
          case ContactDetailNavigationEvent.goBack:
            Navigator.pop(context);
            break;
          case ContactDetailNavigationEvent.showCallModal:
            _showCallMaskingModal(current);
            ref.read(contactDetailViewModelProvider.notifier).clearNavigationEvent();
            break;
          case ContactDetailNavigationEvent.makeCall:
            _launchUrl('tel', current.virtualNumber ?? '1900636999');
            break;
          case ContactDetailNavigationEvent.sendMessage:
            _launchUrl('sms', current.contact?.phone ?? '');
            break;
          case ContactDetailNavigationEvent.sendEmail:
            _launchUrl('mailto', current.contact?.email ?? '');
            break;
          case ContactDetailNavigationEvent.videoCall:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video call not available')),
            );
            break;
          case ContactDetailNavigationEvent.none:
            break;
        }
        if (current.navigationEvent != ContactDetailNavigationEvent.showCallModal) {
          ref.read(contactDetailViewModelProvider.notifier).clearNavigationEvent();
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

    if (state.isLoading && state.contact == null) {
      return const Scaffold(
        backgroundColor: AppColors.detailBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.detailPrimary),
        ),
      );
    }

    final contact = state.contact;
    if (contact == null) {
      return Scaffold(
        backgroundColor: AppColors.detailBackground,
        body: Center(
          child: Text(
            'Contact not found',
            style: TextStyle(color: AppColors.detailTextWhite, fontSize: 16.sp),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.detailBackground,
      body: Stack(
        children: [
          // Background
          Container(color: AppColors.detailBackground),
          SafeArea(
            child: Column(
              children: [
                _buildNavBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        _buildProfileSection(contact),
                        SizedBox(height: 32.h),
                        _buildActionButtons(),
                        SizedBox(height: 32.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            children: [
                              _buildPhotoCard(contact),
                              SizedBox(height: 16.h),
                              _buildDetailsCard(contact),
                              SizedBox(height: 16.h),
                              _buildNotesCard(contact),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom home indicator
          Positioned(
            bottom: 8.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 128.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => ref.read(contactDetailViewModelProvider.notifier).onBackPressed(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4.r,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.detailPrimary,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4.r,
                      ),
                    ],
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.detailPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ContactDetail contact) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Profile image
          Container(
            width: 192.w,
            height: 192.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(96.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 4,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(92.r),
              child: Container(
                color: Colors.white.withValues(alpha: 0.2),
                child: contact.hasAvatar
                    ? Image.asset(
                        contact.avatarAsset!,
                        fit: BoxFit.cover,
                      )
                    : _buildInitialsAvatar(contact),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Job title
          Text(
            contact.jobTitle.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.detailTextWhite70,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Full name
          Text(
            contact.fullName,
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.detailTextWhite,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(ContactDetail contact) {
    return Container(
      color: contact.initialsBgColor ?? const Color(0xFF94A3B8),
      child: Center(
        child: Text(
          contact.displayInitials,
          style: TextStyle(
            fontSize: 64.sp,
            fontWeight: FontWeight.w700,
            color: contact.initialsTextColor ?? AppColors.detailTextWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            icon: Icons.chat_bubble,
            onTap: () => ref.read(contactDetailViewModelProvider.notifier).onMessagePressed(),
          ),
          SizedBox(width: 16.w),
          _ActionButton(
            icon: Icons.call,
            onTap: () => ref.read(contactDetailViewModelProvider.notifier).onCallPressed(),
          ),
          SizedBox(width: 16.w),
          _ActionButton(
            icon: Icons.videocam,
            onTap: () => ref.read(contactDetailViewModelProvider.notifier).onVideoPressed(),
          ),
          SizedBox(width: 16.w),
          _ActionButton(
            icon: Icons.mail,
            onTap: () => ref.read(contactDetailViewModelProvider.notifier).onEmailPressed(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(ContactDetail contact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.detailCardBackground,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.detailDivider),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19.r),
                  child: contact.hasAvatar
                      ? Image.asset(
                          contact.avatarAsset!,
                          fit: BoxFit.cover,
                        )
                      : _buildSmallInitialsAvatar(contact),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Contact Photo & Poster',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.detailTextWhite,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24.sp,
                color: AppColors.detailTextWhite50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInitialsAvatar(ContactDetail contact) {
    return Container(
      color: contact.initialsBgColor ?? const Color(0xFF94A3B8),
      child: Center(
        child: Text(
          contact.displayInitials,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: contact.initialsTextColor ?? AppColors.detailTextWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ContactDetail contact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.detailCardBackground,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (contact.category != null) ...[
                _InfoRow(label: 'Category', value: contact.category!),
                Container(height: 1, color: AppColors.detailDivider),
              ],
              _InfoRow(label: 'Company', value: contact.company),
              Container(height: 1, color: AppColors.detailDivider),
              _InfoRow(label: 'email', value: contact.email),
              Container(height: 1, color: AppColors.detailDivider),
              _AddressRow(address: contact.address),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard(ContactDetail contact) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.detailCardBackground,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.detailTextWhite70,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                contact.notes ?? 'Add notes about this business contact...',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontStyle: FontStyle.italic,
                  color: AppColors.detailTextWhite.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Helper Widgets
// ===========================================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 64.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.detailCardBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: AppColors.detailTextWhite,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.detailTextWhite70,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.detailTextWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final Address address;

  const _AddressRow({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Address',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.detailTextWhite70,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            address.street,
            style: TextStyle(
              fontSize: 17.sp,
              color: AppColors.detailTextWhite,
              height: 1.3,
            ),
          ),
          if (address.city.isNotEmpty)
            Text(
              '${address.city} ${address.state} ${address.zip}'.trim(),
              style: TextStyle(
                fontSize: 17.sp,
                color: AppColors.detailTextWhite,
                height: 1.3,
              ),
            ),
          if (address.country.isNotEmpty)
            Text(
              address.country,
              style: TextStyle(
                fontSize: 17.sp,
                color: AppColors.detailTextWhite,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
