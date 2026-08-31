import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';

/// Use case for watching real-time updates to orders.
/// 
/// This use case interacts with the [OrderRepository] to watch for real-time
/// updates to orders. It returns a [Stream] that emits [Either] containing a [Failure]
/// on the left side or an [OrderItem] on the right side.
class WatchOrderUpdatesUseCase {
  WatchOrderUpdatesUseCase({required this.orderRepository});

  final OrderRepository orderRepository;

  Stream<Either<Failure, OrderItem>> call() {
    return orderRepository.watchOrderUpdates();
  }
}