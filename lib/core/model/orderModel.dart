import 'package:equatable/equatable.dart';

enum OrderStatus { pending, cooking, ready, pickedUp, delivered, cancelled }

class OrderModel extends Equatable {
  final String id;
  final String customerName;
  final String restaurantName;
  final String deliveryAddress;
  final double totalAmount;
  final List<String> items; // In a real app, this might be List<OrderItem>
  final OrderStatus status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.restaurantName,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  // Backend teams love this: clearly defined JSON parsing
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      restaurantName: json['restaurantName'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: List<String>.from(json['items']),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerName,
    restaurantName,
    totalAmount,
    status,
  ];
}
