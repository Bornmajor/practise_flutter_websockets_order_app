import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/close_order_socket_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/create_order_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/subscribe_to_order_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/watch_order_updates_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_event.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final SubscribeToOrderUseCase subscribeToOrderUseCase;
  final WatchOrderUpdatesUseCase watchOrderUpdatesUseCase;
  final CloseOrderSocketUseCase closeOrderSocketUseCase;
  StreamSubscription? _orderUpdatesSubscription;

  OrderBloc({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.subscribeToOrderUseCase,
    required this.watchOrderUpdatesUseCase,
    required this.closeOrderSocketUseCase,
  })
    : super(const OrderInitialState()) {
    on<CreateOrderEvent>(_onPlaceOrder, transformer: droppable());
    on<FetchOrdersEvent>(_fetchOrders, transformer: restartable());
    on<OrderStatusUpdatedEvent>(_onStatusUpdated);
    on<OrderSocketErrorEvent>(_onSocketError);
    // Start listening to order updates via WebSocket
    _listenToOrderUpdates();
  }

Future<void> _onPlaceOrder(
  CreateOrderEvent event,
  Emitter<OrderState> emit,
) async {
  // Get the existing orders from current state
  final existingOrders = state.listOrderItems;

  // Execute use case to create order
  final result = await createOrderUseCase(event.mealId);

  result.fold(
    (failure) => emit(OrderErrorState(message: failure.message)),
    (newOrder) {
      // Append new order to existing list
      final updatedList = [...existingOrders, newOrder];
      
      // Emit success notification
      emit(OrderNotificationState(message: 'Order placed successfully!'));
      
      // Emit updated list
      emit(OrderLoadedState(listOrderItems: updatedList));

      //Initiate background socket subscription without blocking
      unawaited(_subscribeToOrder(newOrder.orderId));
    },
  );
}

  Future<void> _fetchOrders(
    FetchOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    // Capture existing orders
    final existingOrders = state.listOrderItems;

    //emit loading state
    emit(OrderLoadingState(listOrderItems: existingOrders));

    final result = await getOrdersUseCase();

    result.fold(
      (failure) => emit(OrderErrorState(message: failure.message)), 
      (orderItems) {
        emit(OrderLoadedState(listOrderItems: orderItems));
        for (final order in orderItems) {
          unawaited(_subscribeToOrder(order.orderId));
        }
      },
       );
  }

  /// Listens to real-time updates for orders via WebSocket and dispatches corresponding events.
  void _listenToOrderUpdates() {
    // receives the WebSocket stream from the repository/data source.
    _orderUpdatesSubscription = watchOrderUpdatesUseCase().listen((result) {
      result.fold(
        (failure) => add(OrderSocketErrorEvent(message: failure.message)),
        (order) => add(OrderStatusUpdatedEvent(order: order)),
      );
    });
  }

  Future<void> _subscribeToOrder(String orderId) async {
    final result = await subscribeToOrderUseCase(orderId);
    result.fold(
      (failure) => add(OrderSocketErrorEvent(message: failure.message)),
      (_) {},
    );
  }

 /// Handles the event when the status of an order is updated.
  void _onStatusUpdated(
    OrderStatusUpdatedEvent event,
    Emitter<OrderState> emit,
  ) {
    final existingOrders = state.listOrderItems;
    if (!existingOrders.any((order) => order.orderId == event.order.orderId)) {
      return;
    }
    
    // Update the existing orders list with the new status of the order.
    final updatedOrders = existingOrders
        .map(
          (order) => order.orderId == event.order.orderId ? event.order : order,
        )
        .toList();

    // Emit the updated list of orders to reflect the new status.
    emit(OrderLoadedState(listOrderItems: updatedOrders));
  }

  void _onSocketError(OrderSocketErrorEvent event, Emitter<OrderState> emit) {
    emit(
      OrderErrorState(
        message: event.message,
        listOrderItems: state.listOrderItems,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _orderUpdatesSubscription?.cancel();
    await closeOrderSocketUseCase();
    return super.close();
  }
}
