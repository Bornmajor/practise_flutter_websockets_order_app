import 'package:dio/dio.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/models/order_item_model.dart';

abstract class OrderRemoteDataSource {
  /// Places an order for a meal with the given mealId
  /// Returns an OrderItemModel representing the placed order
  /// [mealId] The ID of the meal to be ordered
  Future<OrderItemModel> placeOrder(String mealId);

  /// Fetches a list of orders from the remote API
  /// Returns a list of OrderItemModel representing the orders
  Future<List<OrderItemModel>> getOrders();
}

/// Implementation of OrderRemoteDataSource that uses Dio for making HTTP requests
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderItemModel> placeOrder(String mealId) async {
    final response = await dio.post('/orders', data: {'meal_id': mealId});

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final orderJson = data['order'] ?? data;
      return OrderItemModel.fromJson(orderJson as Map<String, dynamic>);
    }

    if (data is List) {
      return OrderItemModel.fromJson(data.first as Map<String, dynamic>);
    }

    throw Exception('Unexpected order response format');
  }

  @override
  Future<List<OrderItemModel>> getOrders() async {
    final response = await dio.get('/admin/orders');

    final data = response.data;

    if (data is List) {
      return data
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final rawList = data['data'] ?? data['orders'] ?? [];
      return (rawList as List)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
