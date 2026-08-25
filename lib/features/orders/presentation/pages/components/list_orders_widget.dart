import 'package:flutter/material.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/pages/components/order_item_widget.dart';

class ListOrdersWidget extends StatelessWidget {
  const ListOrdersWidget({super.key, required this.orders});

  final List<OrderItem> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_,_) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderItemWidget(orderItem: order);
      },
    );
  }
}