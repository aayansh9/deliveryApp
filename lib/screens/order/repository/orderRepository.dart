import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescueeats/core/model/orderModel.dart';
import 'package:rescueeats/core/services/api_service.dart';

// 1. Define the Interface (Contract)
// 1. Define the Interface (Contract)
abstract class IOrderRepository {
  Future<List<OrderModel>> fetchOrders();
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> placeOrder(OrderModel order);
}

// 2. Implement the Real Repository
class OrderRepository implements IOrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  @override
  Future<List<OrderModel>> fetchOrders() async {
    return await _apiService.getOrders();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _apiService.updateOrderStatus(orderId, status);
  }

  @override
  Future<void> placeOrder(OrderModel order) async {
    await _apiService.createOrder(order);
  }
}

// 3. Providers
final apiServiceProvider = Provider((ref) => ApiService());

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return OrderRepository(api);
});
