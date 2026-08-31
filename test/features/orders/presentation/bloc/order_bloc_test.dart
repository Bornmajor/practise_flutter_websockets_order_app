import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/close_order_socket_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/create_order_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/subscribe_to_order_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/watch_order_updates_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_event.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_state.dart';

void main() {
  late _FakeOrderRepository repository;
  late OrderBloc bloc;

  setUp(() {
    repository = _FakeOrderRepository();
    bloc = OrderBloc(
      createOrderUseCase: CreateOrderUseCase(orderRepository: repository),
      getOrdersUseCase: GetOrdersUseCase(orderRepository: repository),
      subscribeToOrderUseCase: SubscribeToOrderUseCase(
        orderRepository: repository,
      ),
      watchOrderUpdatesUseCase: WatchOrderUpdatesUseCase(
        orderRepository: repository,
      ),
      closeOrderSocketUseCase: CloseOrderSocketUseCase(
        orderRepository: repository,
      ),
    );
  });

  tearDown(() async {
    await bloc.close();
    await repository.dispose();
  });

  test('replaces only the order whose ID matches a status update', () async {
    final firstOrder = _order(orderId: 'ORD-1', status: 'ORDER_PLACED');
    final secondOrder = _order(orderId: 'ORD-2', status: 'ORDER_PLACED');
    repository.orders = [firstOrder, secondOrder];

    bloc.add(const FetchOrdersEvent());
    await _waitFor(() => bloc.state is OrderLoadedState);

    repository.emitUpdate(_order(orderId: 'ORD-1', status: 'PREPARING'));
    await _waitFor(
      () => bloc.state.listOrderItems.first.status == 'PREPARING',
    );

    expect(bloc.state.listOrderItems, [
      _order(orderId: 'ORD-1', status: 'PREPARING'),
      secondOrder,
    ]);
  });

  test('ignores a status update for an order not in the current list', () async {
    final existingOrder = _order(orderId: 'ORD-1', status: 'ORDER_PLACED');
    repository.orders = [existingOrder];

    bloc.add(const FetchOrdersEvent());
    await _waitFor(() => bloc.state is OrderLoadedState);

    repository.emitUpdate(_order(orderId: 'ORD-2', status: 'PREPARING'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.listOrderItems, [existingOrder]);
  });

  test('subscribes to every order returned by the initial fetch', () async {
    repository.orders = [
      _order(orderId: 'ORD-1', status: 'ORDER_PLACED'),
      _order(orderId: 'ORD-2', status: 'PREPARING'),
    ];

    bloc.add(const FetchOrdersEvent());
    await _waitFor(() => repository.subscribedOrderIds.length == 2);

    expect(repository.subscribedOrderIds, {'ORD-1', 'ORD-2'});
  });

  test('subscribes to an order created during the current session', () async {
    repository.newOrder = _order(orderId: 'ORD-3', status: 'ORDER_PLACED');

    bloc.add(const CreateOrderEvent(mealId: 'meal-1'));
    await _waitFor(() => repository.subscribedOrderIds.contains('ORD-3'));

    expect(repository.subscribedOrderIds, {'ORD-3'});
  });

  test('preserves orders when the socket stream emits a failure', () async {
    final existingOrder = _order(orderId: 'ORD-1', status: 'ORDER_PLACED');
    repository.orders = [existingOrder];

    bloc.add(const FetchOrdersEvent());
    await _waitFor(() => bloc.state is OrderLoadedState);
    repository.emitFailure(const NetworkFailure('Socket disconnected'));
    await _waitFor(() => bloc.state is OrderErrorState);

    final state = bloc.state as OrderErrorState;
    expect(state.message, 'Socket disconnected');
    expect(state.listOrderItems, [existingOrder]);
  });

  test('closes the order socket when the Bloc closes', () async {
    await bloc.close();

    expect(repository.socketClosed, isTrue);
  });

  test('cancels the order update stream when the Bloc closes', () async {
    await bloc.close();

    expect(repository.updatesSubscriptionCancelled, isTrue);
  });
}

OrderItem _order({required String orderId, required String status}) {
  return OrderItem(
    orderId: orderId,
    meal: 'Meal $orderId',
    price: 10,
    imageUrl: 'https://example.com/$orderId.jpg',
    status: status,
    createdAt: '10:00 AM',
  );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for expected Bloc state.');
}

class _FakeOrderRepository implements OrderRepository {
  final StreamController<Either<Failure, OrderItem>> _updatesController =
      StreamController<Either<Failure, OrderItem>>.broadcast();
  final Set<String> subscribedOrderIds = {};
  List<OrderItem> orders = [];
  OrderItem? newOrder;
  bool socketClosed = false;
  bool updatesSubscriptionCancelled = false;

  _FakeOrderRepository() {
    _updatesController.onCancel = () {
      updatesSubscriptionCancelled = true;
    };
  }

  @override
  Future<void> closeSocket() async {
    socketClosed = true;
  }

  @override
  Future<Either<Failure, List<OrderItem>>> getOrders() async => Right(orders);

  @override
  Future<Either<Failure, OrderItem>> placeOrder(String mealId) async {
    final order = newOrder;
    if (order != null) return Right(order);
    return Left(UnknownFailure('Not configured for this test: $mealId'));
  }

  @override
  Future<Either<Failure, void>> subscribeToOrder(String orderId) async {
    subscribedOrderIds.add(orderId);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, OrderItem>> watchOrderUpdates() {
    return _updatesController.stream;
  }

  void emitUpdate(OrderItem order) {
    _updatesController.add(Right(order));
  }

  void emitFailure(Failure failure) {
    _updatesController.add(Left(failure));
  }

  Future<void> dispose() => _updatesController.close();
}