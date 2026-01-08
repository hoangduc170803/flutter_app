/// Merchant model representing a store/seller
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

  Merchant copyWith({
    String? id,
    String? name,
    String? category,
    double? rating,
    String? avatarUrl,
    bool? isOnline,
    String? storeHours,
    String? responseTime,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      storeHours: storeHours ?? this.storeHours,
      responseTime: responseTime ?? this.responseTime,
    );
  }
}

