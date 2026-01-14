import 'package:flutter/material.dart';

/// Address model
class Address {
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  String get fullAddress => '$street\n$city $state $zip\n$country';
}

/// Contact model for list view (standalone-contact-manager)
class Contact {
  final String id;
  final String name;
  final String company;
  final String? avatarAsset; // Local asset path
  final String? initials;
  final Color? initialsBgColor;
  final Color? initialsTextColor;
  final String? category;

  const Contact({
    required this.id,
    required this.name,
    required this.company,
    this.avatarAsset,
    this.initials,
    this.initialsBgColor,
    this.initialsTextColor,
    this.category,
  });

  /// Check if has avatar
  bool get hasAvatar => avatarAsset != null && avatarAsset!.isNotEmpty;

  /// Get initials from name if not provided
  String get displayInitials {
    if (initials != null) return initials!;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Copy with method
  Contact copyWith({
    String? id,
    String? name,
    String? company,
    String? avatarAsset,
    String? initials,
    Color? initialsBgColor,
    Color? initialsTextColor,
    String? category,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      initials: initials ?? this.initials,
      initialsBgColor: initialsBgColor ?? this.initialsBgColor,
      initialsTextColor: initialsTextColor ?? this.initialsTextColor,
      category: category ?? this.category,
    );
  }
}

/// Contact group for sectioned list
class ContactGroup {
  final String id;
  final String title;
  final List<Contact> contacts;

  const ContactGroup({
    required this.id,
    required this.title,
    required this.contacts,
  });

  ContactGroup copyWith({
    String? id,
    String? title,
    List<Contact>? contacts,
  }) {
    return ContactGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      contacts: contacts ?? this.contacts,
    );
  }
}

/// Contact detail model for detail view (ios-contact-card)
class ContactDetail {
  final String id;
  final String firstName;
  final String lastName;
  final String jobTitle;
  final String company;
  final String email;
  final String? phone;
  final Address address;
  final String? avatarAsset; // Local asset path
  final String? notes;
  final String? category;
  final String? initials;
  final Color? initialsBgColor;
  final Color? initialsTextColor;

  const ContactDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.jobTitle,
    required this.company,
    required this.email,
    this.phone,
    required this.address,
    this.avatarAsset,
    this.notes,
    this.category,
    this.initials,
    this.initialsBgColor,
    this.initialsTextColor,
  });

  String get fullName => '$firstName $lastName';

  /// Check if has avatar
  bool get hasAvatar => avatarAsset != null && avatarAsset!.isNotEmpty;

  /// Get initials from name if not provided
  String get displayInitials {
    if (initials != null) return initials!;
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }
}
