/// Order model for delivery app
class Order {
  final String id;
  final String status;
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

  Order copyWith({
    String? id,
    String? status,
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

class OrderRecipient {
  final String name;
  final String phone;
  final String? avatar;

  const OrderRecipient({
    required this.name,
    required this.phone,
    this.avatar,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

class OrderSender {
  final String name;
  final String phone;
  final String? avatar;

  const OrderSender({
    required this.name,
    required this.phone,
    this.avatar,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

class OrderCreator {
  final String name;
  final String phone;
  final String? note;

  const OrderCreator({
    required this.name,
    required this.phone,
    this.note,
  });
}

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
}

/// Initial mock orders data
List<Order> getInitialMockOrders() => [
  Order(
    id: '22LNP88J',
    status: 'Đang tìm',
    distance: 21.07,
    price: 48000,
    cod: 350000,
    serviceName: 'Siêu Tốc',
    pickupAddress: '171/74 Đoàn Thị Điểm, Phường An Bình, Dĩ An, tỉnh Bình Dương, Việt Nam',
    dropoffAddress: '1 Thủ Dầu Một, Hiệp Thành, Thủ Dầu Một, Bình Dương',
    recipient: const OrderRecipient(name: 'Nguyễn Văn B', phone: '0909123456'),
    sender: const OrderSender(name: 'Anh Minh', phone: '0909111222'),
    creator: const OrderCreator(
      name: 'Nguyễn Văn A',
      phone: '0909123456',
      note: 'Giao hàng cẩn thận.',
    ),
    deliveryTime: '16:50',
    pickupTime: '16:12',
    paymentInfo: const PaymentInfo(
      totalAmount: 501000,
      productAmount: 480000,
      shippingFee: 21000,
      paymentMethod: 'Tiền mặt',
    ),
    totalFee: 108182,
    cashToReceive: 109000,
    advanceAmount: 450000,
  ),
  Order(
    id: '22RI7JQP',
    status: 'Đang tìm',
    distance: 3.79,
    price: 23000,
    cod: 380000,
    serviceName: 'Siêu Tốc',
    pickupAddress: '37 Ngõ Thịnh Quang, Thịnh Quang',
    dropoffAddress: '429/39 Kim Mã, Ngọc Khánh',
    recipient: const OrderRecipient(name: 'Trần Thị C', phone: '0912345678'),
    sender: const OrderSender(name: 'Chị Hoa', phone: '0912222333'),
    creator: const OrderCreator(
      name: 'Lê Văn D',
      phone: '0923456789',
      note: 'Gọi trước khi giao.',
    ),
    deliveryTime: '17:30',
    pickupTime: '17:00',
    paymentInfo: const PaymentInfo(
      totalAmount: 403000,
      productAmount: 380000,
      shippingFee: 23000,
      paymentMethod: 'Tiền mặt',
    ),
    totalFee: 85000,
    cashToReceive: 95000,
    advanceAmount: 200000,
  ),
  Order(
    id: '22RI7JQR',
    status: 'Đang tìm',
    distance: 3.86,
    price: 23000,
    cod: 150000,
    serviceName: 'Siêu Tốc',
    pickupAddress: '37 Ngõ Thịnh Quang, Thịnh Quang',
    dropoffAddress: 'CHUNG CƯ IMPERIAL PLAZA',
    recipient: const OrderRecipient(name: 'Phạm Văn E', phone: '0934567890'),
    sender: const OrderSender(name: 'Anh Tuấn', phone: '0934444555'),
    creator: const OrderCreator(
      name: 'Hoàng Thị F',
      phone: '0945678901',
    ),
    deliveryTime: '18:00',
    pickupTime: '17:30',
    paymentInfo: const PaymentInfo(
      totalAmount: 173000,
      productAmount: 150000,
      shippingFee: 23000,
      paymentMethod: 'Chuyển khoản',
    ),
    totalFee: 45000,
    cashToReceive: 55000,
    advanceAmount: 100000,
  ),
];
