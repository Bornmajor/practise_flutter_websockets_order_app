import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String orderId;
  final String meal;
  final double price;
  final String imageUrl;
  final String status;
  final String createdAt;

  const OrderItem({
    required this.orderId,
    required this.meal,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [orderId, meal, price, imageUrl, status, createdAt];
}
