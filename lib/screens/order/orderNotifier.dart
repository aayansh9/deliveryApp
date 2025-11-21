import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/model/orderModel.dart';
// You might need to add 'uuid' to pubspec.yaml or use a simple random string generator

// 1. The State Notifier acts as your Database
class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]) {
    // Initialize with some mock data so the app isn't empty
    _loadMockData();
  }

  void _loadMockData() {
    state = [
      OrderModel(
        id: 'ORD-8852',
        customerName: 'John Doe',
        restaurantName: 'Burger King',
        deliveryAddress: '123 Maple Street',
        totalAmount: 24.50,
        items: ['Double Whopper Meal', 'Onion Rings'],
        status: OrderStatus.cooking,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      OrderModel(
        id: 'ORD-9941',
        customerName: 'Jane Smith',
        restaurantName: 'Pizza Hut',
        deliveryAddress: '45 Broadway Ave',
        totalAmount: 32.00,
        items: ['Large Pepperoni', 'Garlic Bread'],
        status: OrderStatus.pending, // Waiting for restaurant
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  // FEATURE: Customer places an order
  void placeOrder(OrderModel order) {
    state = [...state, order];
  }

  // FEATURE: Restaurant/Delivery updates status
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          OrderModel(
            id: order.id,
            customerName: order.customerName,
            restaurantName: order.restaurantName,
            deliveryAddress: order.deliveryAddress,
            totalAmount: order.totalAmount,
            items: order.items,
            status: newStatus, // Update status
            createdAt: order.createdAt,
          )
        else
          order,
    ];
  }
}

// 2. The Provider to access this logic anywhere
final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((
  ref,
) {
  return OrderNotifier();
});

// 3. Helper Providers (Selectors) to filter data for specific roles
final pendingOrdersProvider = Provider((ref) {
  final orders = ref.watch(orderProvider);
  return orders.where((o) => o.status == OrderStatus.pending).toList();
});

final activeOrdersProvider = Provider((ref) {
  final orders = ref.watch(orderProvider);
  return orders
      .where(
        (o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled,
      )
      .toList();
});

final readyForPickupProvider = Provider((ref) {
  final orders = ref.watch(orderProvider);
  return orders.where((o) => o.status == OrderStatus.ready).toList();
});
