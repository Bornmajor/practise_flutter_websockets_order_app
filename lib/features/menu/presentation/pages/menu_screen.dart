import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/core/constants/ui_constants.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_state.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/pages/components/menu_grid_widget.dart';

/// This widget represents the Menu Screen of the application.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: Padding(
        padding: UIConstants.paddingHorizontalMedium,
        child: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoadingState) {
              return Center(child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ));
            }

            if (state is MenuLoadedState) {
              if(state.menuItems.isEmpty) {
                return Center(child: Text(
                  'No menu items available.',
                  style: Theme.of(context).textTheme.titleMedium,
                  ));
              }
              return MenuGridWidget(menuItems: state.menuItems);
            }
            if (state is MenuErrorState) {
              return Center(child: Text(
                state.message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                ));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
