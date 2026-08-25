import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/core/constants/ui_constants.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/entities/menu_item.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/pages/components/menu_item_card.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_event.dart';

class MenuGridWidget extends StatelessWidget {
  const MenuGridWidget({super.key, required this.menuItems});

  final List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: UIConstants.spacingSmall,
        crossAxisSpacing: UIConstants.spacingSmall,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return MenuItemCard(
          item: item,
          onTap: () {
            // Handle item tap
            context.read<OrderBloc>().add(CreateOrderEvent(mealId: item.id));
          },
        );
      },
    );
  }
}
