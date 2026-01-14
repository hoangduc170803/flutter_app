import 'package:flutter/material.dart';
import '../models/contact.dart';

/// Repository for contact data operations
abstract class ContactRepository {
  Future<List<ContactGroup>> getContactGroups();
  Future<List<ContactGroup>> searchContacts(String query);
  Future<ContactDetail?> getContactDetail(String contactId);
}

/// Implementation with mock data
class ContactRepositoryImpl implements ContactRepository {
  // Local asset paths for avatars
  static const String _avatarAlice = 'assets/images/avatars/alice.jpg';
  static const String _avatarAria = 'assets/images/avatars/aria.jpg';
  static const String _avatarBen = 'assets/images/avatars/ben.jpg';
  static const String _avatarCarla = 'assets/images/avatars/carla.jpg';
  static const String _avatarDiana = 'assets/images/avatars/diana.jpg';

  // Mock contact groups data with category assigned to each contact
  static final List<ContactGroup> _mockContactGroups = [
    ContactGroup(
      id: 'g1',
      title: 'Thu hồi nợ',
      contacts: [
        Contact(
          id: 'c1',
          name: 'Alice Anderson',
          company: 'TechFlow Solutions',
          avatarAsset: _avatarAlice,
          category: 'Thu hồi nợ',
        ),
        Contact(
          id: 'c2',
          name: 'Arthur Dent',
          company: 'Sirius Cybernetics',
          initials: 'AD',
          initialsBgColor: const Color(0xFFF97316),
          initialsTextColor: Colors.white,
          category: 'Thu hồi nợ',
        ),
      ],
    ),
    ContactGroup(
      id: 'g2',
      title: 'Khách hàng mới',
      contacts: [
        Contact(
          id: 'c3',
          name: 'Aria Stark',
          company: 'Winterfell Security',
          avatarAsset: _avatarAria,
          category: 'Khách hàng mới',
        ),
        Contact(
          id: 'c4',
          name: 'Bob Barker',
          company: 'Price Right Inc.',
          initials: 'BB',
          initialsBgColor: const Color(0xFFDBEAFE),
          initialsTextColor: const Color(0xFF2563EB),
          category: 'Khách hàng mới',
        ),
      ],
    ),
    ContactGroup(
      id: 'g3',
      title: 'Quá hạn',
      contacts: [
        Contact(
          id: 'c5',
          name: 'Ben Stone',
          company: 'Stone & Associates',
          avatarAsset: _avatarBen,
          category: 'Quá hạn',
        ),
        Contact(
          id: 'c6',
          name: 'Carla Bruni',
          company: 'Elysee Design',
          avatarAsset: _avatarCarla,
          category: 'Quá hạn',
        ),
      ],
    ),
    ContactGroup(
      id: 'g4',
      title: 'Đã giải quyết',
      contacts: [
        Contact(
          id: 'c7',
          name: 'Charlie Kane',
          company: 'Xanadu Publishing',
          initials: 'CK',
          initialsBgColor: const Color(0xFFF3E8FF),
          initialsTextColor: const Color(0xFF9333EA),
          category: 'Đã giải quyết',
        ),
        Contact(
          id: 'c8',
          name: 'Diana Prince',
          company: 'Themyscira Corp.',
          avatarAsset: _avatarDiana,
          category: 'Đã giải quyết',
        ),
      ],
    ),
  ];

  // Mock contact details - full data for each contact
  static final Map<String, ContactDetail> _mockContactDetails = {
    'c1': const ContactDetail(
      id: 'c1',
      firstName: 'Alice',
      lastName: 'Anderson',
      jobTitle: 'Sales Executive',
      company: 'TechFlow Solutions',
      email: 'alice.anderson@techflow.com',
      phone: '0901234567',
      address: Address(
        street: '123 Tech Street',
        city: 'Ho Chi Minh',
        state: '',
        zip: '70000',
        country: 'Vietnam',
      ),
      avatarAsset: _avatarAlice,
      category: 'Thu hồi nợ',
    ),
    'c2': const ContactDetail(
      id: 'c2',
      firstName: 'Arthur',
      lastName: 'Dent',
      jobTitle: 'Software Engineer',
      company: 'Sirius Cybernetics',
      email: 'arthur.dent@sirius.com',
      phone: '0902345678',
      address: Address(
        street: '42 Galaxy Way',
        city: 'Da Nang',
        state: '',
        zip: '50000',
        country: 'Vietnam',
      ),
      initials: 'AD',
      initialsBgColor: Color(0xFFF97316),
      initialsTextColor: Colors.white,
      category: 'Thu hồi nợ',
    ),
    'c3': const ContactDetail(
      id: 'c3',
      firstName: 'Aria',
      lastName: 'Stark',
      jobTitle: 'Security Analyst',
      company: 'Winterfell Security',
      email: 'aria.stark@winterfell.com',
      phone: '0903456789',
      address: Address(
        street: '1 Winter Road',
        city: 'Ha Noi',
        state: '',
        zip: '10000',
        country: 'Vietnam',
      ),
      avatarAsset: _avatarAria,
      category: 'Khách hàng mới',
    ),
    'c4': const ContactDetail(
      id: 'c4',
      firstName: 'Bob',
      lastName: 'Barker',
      jobTitle: 'Account Manager',
      company: 'Price Right Inc.',
      email: 'bob.barker@priceright.com',
      phone: '0904567890',
      address: Address(
        street: '88 Price Avenue',
        city: 'Ho Chi Minh',
        state: '',
        zip: '70000',
        country: 'Vietnam',
      ),
      initials: 'BB',
      initialsBgColor: Color(0xFFDBEAFE),
      initialsTextColor: Color(0xFF2563EB),
      category: 'Khách hàng mới',
    ),
    'c5': const ContactDetail(
      id: 'c5',
      firstName: 'Ben',
      lastName: 'Stone',
      jobTitle: 'Lawyer',
      company: 'Stone & Associates',
      email: 'ben.stone@stonelaw.com',
      phone: '0905678901',
      address: Address(
        street: '200 Legal Street',
        city: 'Ha Noi',
        state: '',
        zip: '10000',
        country: 'Vietnam',
      ),
      avatarAsset: _avatarBen,
      category: 'Quá hạn',
    ),
    'c6': const ContactDetail(
      id: 'c6',
      firstName: 'Carla',
      lastName: 'Bruni',
      jobTitle: 'Designer',
      company: 'Elysee Design',
      email: 'carla.bruni@elysee.com',
      phone: '0906789012',
      address: Address(
        street: '15 Fashion Blvd',
        city: 'Ho Chi Minh',
        state: '',
        zip: '70000',
        country: 'Vietnam',
      ),
      avatarAsset: _avatarCarla,
      category: 'Quá hạn',
    ),
    'c7': const ContactDetail(
      id: 'c7',
      firstName: 'Charlie',
      lastName: 'Kane',
      jobTitle: 'Publisher',
      company: 'Xanadu Publishing',
      email: 'charlie.kane@xanadu.com',
      phone: '0907890123',
      address: Address(
        street: '999 Media Tower',
        city: 'Da Nang',
        state: '',
        zip: '50000',
        country: 'Vietnam',
      ),
      initials: 'CK',
      initialsBgColor: Color(0xFFF3E8FF),
      initialsTextColor: Color(0xFF9333EA),
      category: 'Đã giải quyết',
    ),
    'c8': const ContactDetail(
      id: 'c8',
      firstName: 'Diana',
      lastName: 'Prince',
      jobTitle: 'CEO',
      company: 'Themyscira Corp.',
      email: 'diana.prince@themyscira.com',
      phone: '0908901234',
      address: Address(
        street: '1 Paradise Island',
        city: 'Ha Noi',
        state: '',
        zip: '10000',
        country: 'Vietnam',
      ),
      avatarAsset: _avatarDiana,
      category: 'Đã giải quyết',
    ),
  };

  @override
  Future<List<ContactGroup>> getContactGroups() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockContactGroups;
  }

  @override
  Future<List<ContactGroup>> searchContacts(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (query.trim().isEmpty) return _mockContactGroups;

    final lowerQuery = query.toLowerCase();
    
    return _mockContactGroups
        .map((group) => group.copyWith(
              contacts: group.contacts
                  .where((c) =>
                      c.name.toLowerCase().contains(lowerQuery) ||
                      c.company.toLowerCase().contains(lowerQuery))
                  .toList(),
            ))
        .where((group) => group.contacts.isNotEmpty)
        .toList();
  }

  @override
  Future<ContactDetail?> getContactDetail(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockContactDetails[contactId];
  }
}
