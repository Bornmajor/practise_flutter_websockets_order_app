import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/core/constants/ui_constants.dart';
import 'package:practise_flutter_websockets_order_app/core/utils/snackbar_utils.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_state.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/pages/components/menu_grid_widget.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_state.dart';

/// This widget represents the Menu Screen of the application.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, orderState) {
        if (orderState is OrderErrorState) {
          context.showSnackBar(orderState.message, isError: true);
        } else if (orderState is OrderNotificationState) {
          context.showSnackBar(orderState.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Menu')),
        body: Padding(
          padding: UIConstants.paddingHorizontalMedium,
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state is MenuLoadingState) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
              if (state is MenuErrorState) {
                return Center(
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }

              if (state is MenuLoadedState) {
                if (state.menuItems.isEmpty) {
                  return Center(
                    child: Text(
                      'No menu items available.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }
                return MenuGridWidget(menuItems: state.menuItems);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
