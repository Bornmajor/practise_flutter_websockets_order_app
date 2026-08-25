import 'package:flutter/material.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_status.dart';

class OrderItemWidget extends StatelessWidget {
  const OrderItemWidget({super.key, required this.orderItem});

  final OrderItem orderItem;

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromString(orderItem.status);

    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              orderItem.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        title: Text(orderItem.meal),
        subtitle: Text(orderItem.createdAt),
        trailing: Text(
          status.displayTitle,
          style: TextStyle(color: status.color(context)),
        ),
      ),
    );
  }
}