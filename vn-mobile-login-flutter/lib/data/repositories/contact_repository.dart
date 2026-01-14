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
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuDPALnPTx6lMKM3caEx3VgpIouG_f9mDtCQHIHL8MKruxN14OYrduANRmtoaipFV1w1RNumMTIcRFvHIq9UfIsQt0dwMEGfIpCxv-nOuKKgNEsEKxscv8kndNsc9NHvkxcYGdnysamJrDmLmi7q1cIJyd6QR2SWrwyKyjYSNgmFmKNxful5NMqWcjsMJm6JaHL_dqGQP923OzHLrp2rG9qoPaqbD5_V47fFEJYufr4IMY3Mjvqb7efYBdbqFhfVmuvww3fbngNsZT',
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
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVI1LUjcO4jlqywAa4Vk9MR4y-qNNR6eAVrhEKBHPgi5H2OKj7GqcgH41uKPe2NDNPmBJgcjnzrx1LvRX4pp3PdV0HvzQOaShbLe1bDh1bAWEEpuXKxbvYcskpslnV-SX9Ui0dCRTzbRH8DzqmlFobkuRn2G9fnIezaW-SHZaO3_96SHX50AWHxUkh4odcASScjnKZWOflxR5RDX6HtTTr2FaGUeeC5n0-5X7EaQEKat-iQ1B7rxKixDZ92fioYBLUU642sEygTcNl',
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
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApXmZ-FxKMYcRU3vdSwxq1gNpTSMD3EW5RKe3yJZMZJSSqJes-PxepfoHz5qCe7y5xq_HzKuXfNX_YyzyQl3fsO-T3aWwEE5HrccNtMdYPfpm5UrZ9mYm1_Bxm5bV78Dgf8xp_nhgbB5RnrYcXzs5ak5mAvITPJUc2g32MycCibJEcSJ1tb7zWnP1337wTygBIy6EN0cTTKM2lBx62c2s9ZF5RdvvFxfQC5Bq_L1QQogQ9hpqf0kuflfKRGIPUTZxVQ6IfkCUBQlpr',
          category: 'Quá hạn',
        ),
        Contact(
          id: 'c6',
          name: 'Carla Bruni',
          company: 'Elysee Design',
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5dfJTOGRnYO87qpEUMOTXTnvbZ8z13GGCg7GN6mYKZbW1vGW-QSajJxNkHrIEMFtN-xFzGnwXhSHy7cVZOofS8DMoENizBv2Bk_yhaV5FyexujE2KFLBrQc-2D2D7FQYeD4aePkMjGLJ8QDPw0o7Kp8DZWOz7gzX4yQfb8rD5OitiKMzmyfUhRUm16k3fV8u_Kl9zdtjeTUDZem3rtlWaDJbt869RKHLbVJY3r143p-76ky-A8tiLphNJFcmRMTBJ10LE2XNEakQZ',
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
          avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDugvaLTuFGskF9GfEOiYoip89r7yGK9OtKK_3dnsvzWweMhUA-4dkYEeSu_vU96mfNunB0Lilubm66W75n_WebnC8S6zketJa0VE9hiyC40hKE5LoRTRnsCOdBbHKMfMF2kkD1Mts7n7dqm0TqoBD4R1EC99r1i7Zxk3IOvCfg0_awV4u8lp_A7dRJhuutivFHzcgvE_h43K0oc6mWEFURDBUmxjKsij1val3G7yidOzj9yEtaAqSCJTKrnQ289QWg5m4qRM-DpWUn',
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
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuDPALnPTx6lMKM3caEx3VgpIouG_f9mDtCQHIHL8MKruxN14OYrduANRmtoaipFV1w1RNumMTIcRFvHIq9UfIsQt0dwMEGfIpCxv-nOuKKgNEsEKxscv8kndNsc9NHvkxcYGdnysamJrDmLmi7q1cIJyd6QR2SWrwyKyjYSNgmFmKNxful5NMqWcjsMJm6JaHL_dqGQP923OzHLrp2rG9qoPaqbD5_V47fFEJYufr4IMY3Mjvqb7efYBdbqFhfVmuvww3fbngNsZT',
      posterUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuDPALnPTx6lMKM3caEx3VgpIouG_f9mDtCQHIHL8MKruxN14OYrduANRmtoaipFV1w1RNumMTIcRFvHIq9UfIsQt0dwMEGfIpCxv-nOuKKgNEsEKxscv8kndNsc9NHvkxcYGdnysamJrDmLmi7q1cIJyd6QR2SWrwyKyjYSNgmFmKNxful5NMqWcjsMJm6JaHL_dqGQP923OzHLrp2rG9qoPaqbD5_V47fFEJYufr4IMY3Mjvqb7efYBdbqFhfVmuvww3fbngNsZT',
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
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVI1LUjcO4jlqywAa4Vk9MR4y-qNNR6eAVrhEKBHPgi5H2OKj7GqcgH41uKPe2NDNPmBJgcjnzrx1LvRX4pp3PdV0HvzQOaShbLe1bDh1bAWEEpuXKxbvYcskpslnV-SX9Ui0dCRTzbRH8DzqmlFobkuRn2G9fnIezaW-SHZaO3_96SHX50AWHxUkh4odcASScjnKZWOflxR5RDX6HtTTr2FaGUeeC5n0-5X7EaQEKat-iQ1B7rxKixDZ92fioYBLUU642sEygTcNl',
      posterUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVI1LUjcO4jlqywAa4Vk9MR4y-qNNR6eAVrhEKBHPgi5H2OKj7GqcgH41uKPe2NDNPmBJgcjnzrx1LvRX4pp3PdV0HvzQOaShbLe1bDh1bAWEEpuXKxbvYcskpslnV-SX9Ui0dCRTzbRH8DzqmlFobkuRn2G9fnIezaW-SHZaO3_96SHX50AWHxUkh4odcASScjnKZWOflxR5RDX6HtTTr2FaGUeeC5n0-5X7EaQEKat-iQ1B7rxKixDZ92fioYBLUU642sEygTcNl',
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
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApXmZ-FxKMYcRU3vdSwxq1gNpTSMD3EW5RKe3yJZMZJSSqJes-PxepfoHz5qCe7y5xq_HzKuXfNX_YyzyQl3fsO-T3aWwEE5HrccNtMdYPfpm5UrZ9mYm1_Bxm5bV78Dgf8xp_nhgbB5RnrYcXzs5ak5mAvITPJUc2g32MycCibJEcSJ1tb7zWnP1337wTygBIy6EN0cTTKM2lBx62c2s9ZF5RdvvFxfQC5Bq_L1QQogQ9hpqf0kuflfKRGIPUTZxVQ6IfkCUBQlpr',
      posterUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApXmZ-FxKMYcRU3vdSwxq1gNpTSMD3EW5RKe3yJZMZJSSqJes-PxepfoHz5qCe7y5xq_HzKuXfNX_YyzyQl3fsO-T3aWwEE5HrccNtMdYPfpm5UrZ9mYm1_Bxm5bV78Dgf8xp_nhgbB5RnrYcXzs5ak5mAvITPJUc2g32MycCibJEcSJ1tb7zWnP1337wTygBIy6EN0cTTKM2lBx62c2s9ZF5RdvvFxfQC5Bq_L1QQogQ9hpqf0kuflfKRGIPUTZxVQ6IfkCUBQlpr',
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
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5dfJTOGRnYO87qpEUMOTXTnvbZ8z13GGCg7GN6mYKZbW1vGW-QSajJxNkHrIEMFtN-xFzGnwXhSHy7cVZOofS8DMoENizBv2Bk_yhaV5FyexujE2KFLBrQc-2D2D7FQYeD4aePkMjGLJ8QDPw0o7Kp8DZWOz7gzX4yQfb8rD5OitiKMzmyfUhRUm16k3fV8u_Kl9zdtjeTUDZem3rtlWaDJbt869RKHLbVJY3r143p-76ky-A8tiLphNJFcmRMTBJ10LE2XNEakQZ',
      posterUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5dfJTOGRnYO87qpEUMOTXTnvbZ8z13GGCg7GN6mYKZbW1vGW-QSajJxNkHrIEMFtN-xFzGnwXhSHy7cVZOofS8DMoENizBv2Bk_yhaV5FyexujE2KFLBrQc-2D2D7FQYeD4aePkMjGLJ8QDPw0o7Kp8DZWOz7gzX4yQfb8rD5OitiKMzmyfUhRUm16k3fV8u_Kl9zdtjeTUDZem3rtlWaDJbt869RKHLbVJY3r143p-76ky-A8tiLphNJFcmRMTBJ10LE2XNEakQZ',
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
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDugvaLTuFGskF9GfEOiYoip89r7yGK9OtKK_3dnsvzWweMhUA-4dkYEeSu_vU96mfNunB0Lilubm66W75n_WebnC8S6zketJa0VE9hiyC40hKE5LoRTRnsCOdBbHKMfMF2kkD1Mts7n7dqm0TqoBD4R1EC99r1i7Zxk3IOvCfg0_awV4u8lp_A7dRJhuutivFHzcgvE_h43K0oc6mWEFURDBUmxjKsij1val3G7yidOzj9yEtaAqSCJTKrnQ289QWg5m4qRM-DpWUn',
      posterUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDugvaLTuFGskF9GfEOiYoip89r7yGK9OtKK_3dnsvzWweMhUA-4dkYEeSu_vU96mfNunB0Lilubm66W75n_WebnC8S6zketJa0VE9hiyC40hKE5LoRTRnsCOdBbHKMfMF2kkD1Mts7n7dqm0TqoBD4R1EC99r1i7Zxk3IOvCfg0_awV4u8lp_A7dRJhuutivFHzcgvE_h43K0oc6mWEFURDBUmxjKsij1val3G7yidOzj9yEtaAqSCJTKrnQ289QWg5m4qRM-DpWUn',
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
