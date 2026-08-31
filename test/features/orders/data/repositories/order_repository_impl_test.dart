import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/datasources/order_socket_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/models/order_item_model.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/repositories/order_repository_impl.dart';

void main() {
  late _FakeOrderSocketDataSource socketDataSource;
  late OrderRepositoryImpl repository;

  setUp(() {
    socketDataSource = _FakeOrderSocketDataSource();
    repository = OrderRepositoryImpl(
      orderRemoteDataSource: _FakeOrderRemoteDataSource(),
      orderSocketDataSource: socketDataSource,
    );
  });

  tearDown(() => socketDataSource.dispose());

  test('forwards socket models as Right order items', () async {
    final result = expectLater(
      repository.watchOrderUpdates(),
      emits(
        isA<Right<Failure, dynamic>>().having(
          (either) => either.value.orderId,
          'orderId',
          'ORD-1',
        ),
      ),
    );

    await Future<void>.delayed(Duration.zero);

    socketDataSource.emit(_orderModel());

    await result;
  });

  test('maps socket stream errors to Left failures', () async {
    final result = expectLater(
      repository.watchOrderUpdates(),
      emits(isA<Left<Failure, dynamic>>()),
    );

    await Future<void>.delayed(Duration.zero);

    socketDataSource.emitError(const FormatException('Malformed socket data'));

    await result;
  });

  test('delegates subscription and socket closure to the data source', () async {
    final subscribeResult = await repository.subscribeToOrder('ORD-1');
    await repository.closeSocket();

    expect(subscribeResult, const Right<Failure, void>(null));
    expect(socketDataSource.subscribedOrderIds, {'ORD-1'});
    expect(socketDataSource.isClosed, isTrue);
  });
}

OrderItemModel _orderModel() {
  return const OrderItemModel(
    orderId: 'ORD-1',
    meal: 'Burger',
    price: 12.5,
    imageUrl: 'https://example.com/burger.jpg',
    status: 'PREPARING',
    createdAt: '10:00 AM',
  );
}

class _FakeOrderRemoteDataSource implements OrderRemoteDataSource {
  @override
  Future<List<OrderItemModel>> getOrders() async => [];

  @override
  Future<OrderItemModel> placeOrder(String mealId) {
    throw UnimplementedError();
  }
}

class _FakeOrderSocketDataSource implements OrderSocketDataSource {
  final StreamController<OrderItemModel> _controller =
      StreamController<OrderItemModel>.broadcast();
  final Set<String> subscribedOrderIds = {};
  bool isClosed = false;

  @override
  Stream<OrderItemModel> get statusUpdates => _controller.stream;

  @override
  Future<void> close() async {
    isClosed = true;
  }

  void emit(OrderItemModel order) => _controller.add(order);

  void emitError(Object error) => _controller.addError(error);

  Future<void> dispose() => _controller.close();

  @override
  void subscribe(String orderId) {
    subscribedOrderIds.add(orderId);
  }
}