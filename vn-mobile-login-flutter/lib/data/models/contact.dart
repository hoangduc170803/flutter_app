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
  final String? avatarUrl;
  final String? initials;
  final Color? initialsBgColor;
  final Color? initialsTextColor;
  final String? category; // Category like "Thu hồi nợ", "Khách hàng mới", etc.

  const Contact({
    required this.id,
    required this.name,
    required this.company,
    this.avatarUrl,
    this.initials,
    this.initialsBgColor,
    this.initialsTextColor,
    this.category,
  });

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
    String? avatarUrl,
    String? initials,
    Color? initialsBgColor,
    Color? initialsTextColor,
    String? category,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
  final String? avatarUrl; // Changed to nullable for initials fallback
  final String? posterUrl;
  final String? notes;
  final String? category; // Added category field
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
    this.avatarUrl,
    this.posterUrl,
    this.notes,
    this.category,
    this.initials,
    this.initialsBgColor,
    this.initialsTextColor,
  });

  String get fullName => '$firstName $lastName';

  /// Get initials from name if not provided
  String get displayInitials {
    if (initials != null) return initials!;
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  /// Create from Contact model
  factory ContactDetail.fromContact(Contact contact, {String? category}) {
    final nameParts = contact.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    return ContactDetail(
      id: contact.id,
      firstName: firstName,
      lastName: lastName,
      jobTitle: 'Contact', // Default job title
      company: contact.company,
      email: '${firstName.toLowerCase()}_${lastName.toLowerCase()}@company.com',
      avatarUrl: contact.avatarUrl,
      posterUrl: contact.avatarUrl,
      address: const Address(
        street: 'Address not available',
        city: '',
        state: '',
        zip: '',
        country: '',
      ),
      category: category ?? contact.category,
      initials: contact.initials,
      initialsBgColor: contact.initialsBgColor,
      initialsTextColor: contact.initialsTextColor,
    );
  }
}
