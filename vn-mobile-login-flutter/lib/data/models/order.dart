/// Order status enum with display names
enum OrderStatus {
  searching('Đang tìm'),
  picking('Đang lấy hàng'),
  delivering('Đang giao'),
  delivered('Đã giao'),
  cancelled('Đã hủy');

  final String displayName;
  const OrderStatus(this.displayName);

  /// Parse from string (for API compatibility)
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.displayName == value || status.name == value,
      orElse: () => OrderStatus.searching,
    );
  }
}

/// Base mixin for order participants (Recipient, Sender)
mixin OrderParticipantMixin {
  String get name;
  String get phone;
  String? get avatar;

  /// Get initials from name with proper null safety
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

/// Order recipient model
class OrderRecipient with OrderParticipantMixin {
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? avatar;

  const OrderRecipient({
    required this.name,
    required this.phone,
    this.avatar,
  });

  factory OrderRecipient.fromJson(Map<String, dynamic> json) {
    return OrderRecipient(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (avatar != null) 'avatar': avatar,
      };

  OrderRecipient copyWith({
    String? name,
    String? phone,
    String? avatar,
  }) {
    return OrderRecipient(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
    );
  }
}

/// Order sender model
class OrderSender with OrderParticipantMixin {
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? avatar;

  const OrderSender({
    required this.name,
    required this.phone,
    this.avatar,
  });

  factory OrderSender.fromJson(Map<String, dynamic> json) {
    return OrderSender(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (avatar != null) 'avatar': avatar,
      };

  OrderSender copyWith({
    String? name,
    String? phone,
    String? avatar,
  }) {
    return OrderSender(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
    );
  }
}

/// Order creator model
class OrderCreator {
  final String name;
  final String phone;
  final String? note;

  const OrderCreator({
    required this.name,
    required this.phone,
    this.note,
  });

  factory OrderCreator.fromJson(Map<String, dynamic> json) {
    return OrderCreator(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (note != null) 'note': note,
      };

  OrderCreator copyWith({
    String? name,
    String? phone,
    String? note,
  }) {
    return OrderCreator(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
    );
  }
}

/// Payment information model
class PaymentInfo {
  final int totalAmount;
  final int productAmount;
  final int shippingFee;
  final String paymentMethod;

  const PaymentInfo({
    required this.totalAmount,
    required this.productAmount,
    required this.shippingFee,
    required this.paymentMethod,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      totalAmount: json['totalAmount'] as int? ?? 0,
      productAmount: json['productAmount'] as int? ?? 0,
      shippingFee: json['shippingFee'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'totalAmount': totalAmount,
        'productAmount': productAmount,
        'shippingFee': shippingFee,
        'paymentMethod': paymentMethod,
      };

  PaymentInfo copyWith({
    int? totalAmount,
    int? productAmount,
    int? shippingFee,
    String? paymentMethod,
  }) {
    return PaymentInfo(
      totalAmount: totalAmount ?? this.totalAmount,
      productAmount: productAmount ?? this.productAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

/// Order model for delivery app
class Order {
  final String id;
  final OrderStatus status;
  final double distance;
  final int price;
  final int? cod;
  final String serviceName;
  final String? pickupAddress;
  final String? dropoffAddress;
  final bool isSpecial;
  final OrderRecipient? recipient;
  final OrderSender? sender;
  final OrderCreator? creator;
  final String? deliveryTime;
  final String? pickupTime;
  final PaymentInfo? paymentInfo;
  final int? totalFee;
  final int? cashToReceive;
  final int? advanceAmount;

  const Order({
    required this.id,
    required this.status,
    required this.distance,
    required this.price,
    this.cod,
    required this.serviceName,
    this.pickupAddress,
    this.dropoffAddress,
    this.isSpecial = false,
    this.recipient,
    this.sender,
    this.creator,
    this.deliveryTime,
    this.pickupTime,
    this.paymentInfo,
    this.totalFee,
    this.cashToReceive,
    this.advanceAmount,
  });

  /// Get status display name for UI
  String get statusDisplayName => status.displayName;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String? ?? ''),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      price: json['price'] as int? ?? 0,
      cod: json['cod'] as int?,
      serviceName: json['serviceName'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String?,
      dropoffAddress: json['dropoffAddress'] as String?,
      isSpecial: json['isSpecial'] as bool? ?? false,
      recipient: json['recipient'] != null
          ? OrderRecipient.fromJson(json['recipient'] as Map<String, dynamic>)
          : null,
      sender: json['sender'] != null
          ? OrderSender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] != null
          ? OrderCreator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      deliveryTime: json['deliveryTime'] as String?,
      pickupTime: json['pickupTime'] as String?,
      paymentInfo: json['paymentInfo'] != null
          ? PaymentInfo.fromJson(json['paymentInfo'] as Map<String, dynamic>)
          : null,
      totalFee: json['totalFee'] as int?,
      cashToReceive: json['cashToReceive'] as int?,
      advanceAmount: json['advanceAmount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.displayName,
        'distance': distance,
        'price': price,
        if (cod != null) 'cod': cod,
        'serviceName': serviceName,
        if (pickupAddress != null) 'pickupAddress': pickupAddress,
        if (dropoffAddress != null) 'dropoffAddress': dropoffAddress,
        'isSpecial': isSpecial,
        if (recipient != null) 'recipient': recipient!.toJson(),
        if (sender != null) 'sender': sender!.toJson(),
        if (creator != null) 'creator': creator!.toJson(),
        if (deliveryTime != null) 'deliveryTime': deliveryTime,
        if (pickupTime != null) 'pickupTime': pickupTime,
        if (paymentInfo != null) 'paymentInfo': paymentInfo!.toJson(),
        if (totalFee != null) 'totalFee': totalFee,
        if (cashToReceive != null) 'cashToReceive': cashToReceive,
        if (advanceAmount != null) 'advanceAmount': advanceAmount,
      };

  Order copyWith({
    String? id,
    OrderStatus? status,
    double? distance,
    int? price,
    int? cod,
    String? serviceName,
    String? pickupAddress,
    String? dropoffAddress,
    bool? isSpecial,
    OrderRecipient? recipient,
    OrderSender? sender,
    OrderCreator? creator,
    String? deliveryTime,
    String? pickupTime,
    PaymentInfo? paymentInfo,
    int? totalFee,
    int? cashToReceive,
    int? advanceAmount,
  }) {
    return Order(
      id: id ?? this.id,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      cod: cod ?? this.cod,
      serviceName: serviceName ?? this.serviceName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      isSpecial: isSpecial ?? this.isSpecial,
      recipient: recipient ?? this.recipient,
      sender: sender ?? this.sender,
      creator: creator ?? this.creator,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      pickupTime: pickupTime ?? this.pickupTime,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      totalFee: totalFee ?? this.totalFee,
      cashToReceive: cashToReceive ?? this.cashToReceive,
      advanceAmount: advanceAmount ?? this.advanceAmount,
    );
  }
}
