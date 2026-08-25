import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository orderRepository;

  GetOrdersUseCase({required this.orderRepository});

  /// Fetches a list of orders.
  /// Returns a [Future] that resolves to an [Either] containing a [Failure] on the left side or a list of [OrderItem] on the right side.
  Future<Either<Failure, List<OrderItem>>> call() async {
    return await orderRepository.getOrders();
  }
}