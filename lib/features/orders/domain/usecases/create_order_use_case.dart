
import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';

/// This class represents the use case for creating an order.
/// [OrderRepository] - The repository that provides the data for creating an order.
class CreateOrderUseCase {
  final OrderRepository orderRepository;

  CreateOrderUseCase({required this.orderRepository});

   /// Places an order for a meal with the given [mealId].
  Future<Either<Failure,OrderItem>> call(String mealId) async {
    return await orderRepository.placeOrder(mealId);
  }
}