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
}

