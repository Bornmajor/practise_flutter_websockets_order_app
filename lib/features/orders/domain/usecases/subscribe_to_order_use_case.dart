import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';

/// Use case for subscribing to updates for a specific order by its [orderId].
/// 
/// This use case interacts with the [OrderRepository] to subscribe to real-time
/// updates for a specific order. It returns a [Future] that resolves to an [Either]
/// containing a [Failure] on the left side or void on the right side.
class SubscribeToOrderUseCase {
  SubscribeToOrderUseCase({required this.orderRepository});

  final OrderRepository orderRepository;

  Future<Either<Failure, void>> call(String orderId) {
    return orderRepository.subscribeToOrder(orderId);
  }
}