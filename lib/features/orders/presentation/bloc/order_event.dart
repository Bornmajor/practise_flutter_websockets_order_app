import 'package:equatable/equatable.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';

class OrderEvent extends Equatable{
  
  const OrderEvent();

  @override
  List<Object?> get props => [];

}

/// Event to create an order
class CreateOrderEvent extends OrderEvent{
  final String mealId;

  const CreateOrderEvent({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}


/// Event to fetch existing orders
class FetchOrdersEvent extends OrderEvent {

  const FetchOrdersEvent();
}

/// Event indicating that the status of an order has been updated.
class OrderStatusUpdatedEvent extends OrderEvent {
  const OrderStatusUpdatedEvent({required this.order});

  final OrderItem order;

  @override
  List<Object?> get props => [order];
}

/// Event indicating that there was an error with the order WebSocket connection.
class OrderSocketErrorEvent extends OrderEvent {
  const OrderSocketErrorEvent({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}