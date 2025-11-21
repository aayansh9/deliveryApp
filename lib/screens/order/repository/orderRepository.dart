import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/model/orderModel.dart';
import 'package:rescueeats/features/widgets/apiClients.dart';

// 1. Define the Interface (Contract)
abstract class IOrderRepository {
  Future<List<OrderModel>> fetchOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> placeOrder(OrderModel order);
}

// 2. Implement the Real Repository
class OrderRepository implements IOrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  @override
  Future<List<OrderModel>> fetchOrders() async {
    final response = await _apiClient.get('/orders');
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _apiClient.patch('/orders/$orderId', data: {'status': status.name});
  }

  @override
  Future<void> placeOrder(OrderModel order) async {
    // Convert OrderModel to JSON if you have a toJson method, or manual map
    await _apiClient.post(
      '/orders',
      data: {
        'customerName': order.customerName,
        'totalAmount': order.totalAmount,
        'items': order.items,
      },
    );
  }
}

// 3. Providers
final apiClientProvider = Provider((ref) => ApiClient());

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return OrderRepository(api);
});
