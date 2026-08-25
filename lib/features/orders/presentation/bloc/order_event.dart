import 'package:equatable/equatable.dart';

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