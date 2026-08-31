import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/datasources/order_socket_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';

/// This class implements the OrderRepository interface and provides the actual
/// implementation for placing orders and fetching orders from a remote data source.
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource orderRemoteDataSource;
  final OrderSocketDataSource orderSocketDataSource;

  OrderRepositoryImpl({
    required this.orderRemoteDataSource,
    required this.orderSocketDataSource,
  });

  @override
  Future<Either<Failure,OrderItem>> placeOrder(String mealId) async{
    try{
      final orderItemResponse = await orderRemoteDataSource.placeOrder(mealId);
      return Right(orderItemResponse);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e){
      return Left(UnknownFailure(e.toString()));
    }
     
  }

  @override
  Future<Either<Failure, List<OrderItem>>> getOrders() async{
    try {
      final ordersResponse = await orderRemoteDataSource.getOrders();
      return Right(ordersResponse);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToOrder(String orderId) async {
    try {
      orderSocketDataSource.subscribe(orderId);
      return const Right(null);
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }

  @override
  Stream<Either<Failure, OrderItem>> watchOrderUpdates() async* {
    try {
      await for (final order in orderSocketDataSource.statusUpdates) {
        yield Right(order);
      }
    } catch (error) {
      yield Left(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<void> closeSocket() => orderSocketDataSource.close();
}