class Merchant {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String avatarUrl;
  final bool isOnline;
  final String storeHours;
  final String responseTime;

  const Merchant({
    required this.id,
    required this.name,
    this.category = '',
    this.rating = 0.0,
    required this.avatarUrl,
    this.isOnline = false,
    this.storeHours = '',
    this.responseTime = '',
  });
}

// Mock data
const Merchant mockMerchant = Merchant(
  id: 'm123',
  name: 'Nguyen Van A',
  category: 'Fashion Store',
  rating: 4.8,
  avatarUrl: 'https://picsum.photos/200/200',
  isOnline: true,
  storeHours: 'Open today from 8:00 AM to 9:00 PM.',
  responseTime: 'Within 5 minutes',
);

const Merchant mockMerchantSimple = Merchant(
  id: '1',
  name: 'Người bán 1',
  avatarUrl: 'https://picsum.photos/200/200',
);

