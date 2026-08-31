import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';

/// This abstract class defines the contract for an OrderRepository
abstract class OrderRepository {
  /// Places an order for a meal with the given [mealId].
  /// Returns a [Future] that resolves to an [Either] containing a [Failure]
  /// on the left side or an [OrderItem] on the right side.
  Future<Either<Failure,OrderItem>> placeOrder(String mealId);

  /// Fetches a list of orders.
  /// Returns a [Future] that resolves to an [Either] containing a [Failure]
  /// on the left side or a list of [OrderItem]s on the right side
  Future<Either<Failure,List<OrderItem>>> getOrders();

  /// Subscribes to updates for a specific order by its [orderId].
  /// Returns a [Future] that resolves to an [Either] containing a [Failure]
  /// on the left side or void on the right side.
  Future<Either<Failure, void>> subscribeToOrder(String orderId);

  /// Watches for real-time updates to orders.
  /// Returns a [Stream] that emits [Either] containing a [Failure] on the left side
  /// or an [OrderItem] on the right side.
  Stream<Either<Failure, OrderItem>> watchOrderUpdates();

  /// Closes the underlying WebSocket connection used for real-time updates.
  Future<void> closeSocket();
}

