import '../models/order.dart';

/// Mock orders data for development and testing
class MockOrders {
  MockOrders._();

  /// Get initial mock orders list
  static List<Order> getInitialOrders() => [
        const Order(
          id: '22LNP88J',
          status: OrderStatus.searching,
          distance: 21.07,
          price: 48000,
          cod: 350000,
          serviceName: 'Siêu Tốc',
          pickupAddress:
              '171/74 Đoàn Thị Điểm, Phường An Bình, Dĩ An, tỉnh Bình Dương, Việt Nam',
          dropoffAddress:
              '1 Thủ Dầu Một, Hiệp Thành, Thủ Dầu Một, Bình Dương',
          recipient: OrderRecipient(name: 'Nguyễn Văn B', phone: '0909123456'),
          sender: OrderSender(name: 'Anh Minh', phone: '0909111222'),
          creator: OrderCreator(
            name: 'Nguyễn Văn A',
            phone: '0909123456',
            note: 'Giao hàng cẩn thận.',
          ),
          deliveryTime: '16:50',
          pickupTime: '16:12',
          paymentInfo: PaymentInfo(
            totalAmount: 501000,
            productAmount: 480000,
            shippingFee: 21000,
            paymentMethod: 'Tiền mặt',
          ),
          totalFee: 108182,
          cashToReceive: 109000,
          advanceAmount: 450000,
        ),
        const Order(
          id: '22RI7JQP',
          status: OrderStatus.searching,
          distance: 3.79,
          price: 23000,
          cod: 380000,
          serviceName: 'Siêu Tốc',
          pickupAddress: '37 Ngõ Thịnh Quang, Thịnh Quang',
          dropoffAddress: '429/39 Kim Mã, Ngọc Khánh',
          recipient: OrderRecipient(name: 'Trần Thị C', phone: '0912345678'),
          sender: OrderSender(name: 'Chị Hoa', phone: '0912222333'),
          creator: OrderCreator(
            name: 'Lê Văn D',
            phone: '0923456789',
            note: 'Gọi trước khi giao.',
          ),
          deliveryTime: '17:30',
          pickupTime: '17:00',
          paymentInfo: PaymentInfo(
            totalAmount: 403000,
            productAmount: 380000,
            shippingFee: 23000,
            paymentMethod: 'Tiền mặt',
          ),
          totalFee: 85000,
          cashToReceive: 95000,
          advanceAmount: 200000,
        ),
        const Order(
          id: '22RI7JQR',
          status: OrderStatus.searching,
          distance: 3.86,
          price: 23000,
          cod: 150000,
          serviceName: 'Siêu Tốc',
          pickupAddress: '37 Ngõ Thịnh Quang, Thịnh Quang',
          dropoffAddress: 'CHUNG CƯ IMPERIAL PLAZA',
          recipient: OrderRecipient(name: 'Phạm Văn E', phone: '0934567890'),
          sender: OrderSender(name: 'Anh Tuấn', phone: '0934444555'),
          creator: OrderCreator(
            name: 'Hoàng Thị F',
            phone: '0945678901',
          ),
          deliveryTime: '18:00',
          pickupTime: '17:30',
          paymentInfo: PaymentInfo(
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
}

