import '../models/merchant.dart';

/// Repository for merchant data operations
abstract class MerchantRepository {
  Future<Merchant> getMerchantById(String id);
  Future<Merchant> getDefaultMerchant();
}

/// Implementation of MerchantRepository with mock data
class MerchantRepositoryImpl implements MerchantRepository {
  // Mock data
  static const _mockMerchant = Merchant(
    id: 'm123',
    name: 'Nguyen Van A',
    category: 'Fashion Store',
    rating: 4.8,
    avatarUrl: 'https://picsum.photos/200/200',
    isOnline: true,
    storeHours: 'Open today from 8:00 AM to 9:00 PM.',
    responseTime: 'Within 5 minutes',
  );

  @override
  Future<Merchant> getMerchantById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMerchant;
  }

  @override
  Future<Merchant> getDefaultMerchant() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMerchant;
  }
}

