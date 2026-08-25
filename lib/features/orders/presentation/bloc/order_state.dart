import 'package:equatable/equatable.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';

abstract class OrderState extends Equatable {
  const OrderState(
    {this.listOrderItems = const []}
  );

  final List<OrderItem> listOrderItems;

  @override
  List<Object?> get props => [listOrderItems];

}

// Initial state of the OrderState
class OrderInitialState extends OrderState {
  const OrderInitialState() : super(listOrderItems: const []);
}

/// -- SIDE EFFECT STATES --

/// Loading 
class OrderLoadingState extends OrderState {
  const OrderLoadingState({super.listOrderItems});
}



/// Order Data
class OrderLoadedState extends OrderState {
  const OrderLoadedState({required super.listOrderItems});
}

/// Success state
class OrderNotificationState extends OrderState {
  final String message;

  const OrderNotificationState({
    required this.message,
    super.listOrderItems = const [],
  });

  @override
  List<Object?> get props => [message, listOrderItems];
}

/// Error state
class OrderErrorState extends OrderState {
  final String message; 

  const OrderErrorState({
    required this.message,
    super.listOrderItems,
    });

  @override
  List<Object?> get props => [message,listOrderItems];
}