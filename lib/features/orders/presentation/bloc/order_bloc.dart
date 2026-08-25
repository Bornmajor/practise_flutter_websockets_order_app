import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/create_order_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_event.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;

  OrderBloc({required this.createOrderUseCase, required this.getOrdersUseCase})
    : super(const OrderInitialState()) {
    on<CreateOrderEvent>(_onPlaceOrder, transformer: droppable());
    on<FetchOrdersEvent>(_fetchOrders, transformer: restartable());
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
      (orderItems) => emit(OrderLoadedState(listOrderItems: orderItems)),
       );
  }
}
