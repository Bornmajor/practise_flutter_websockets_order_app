import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';

/// Use case for closing the WebSocket connection used for real-time order updates.
/// 
/// This use case interacts with the [OrderRepository] to close the WebSocket
/// connection that is used for receiving real-time updates about orders.
class CloseOrderSocketUseCase {
  CloseOrderSocketUseCase({required this.orderRepository});

  final OrderRepository orderRepository;

  Future<void> call() {
    return orderRepository.closeSocket();
  }
}