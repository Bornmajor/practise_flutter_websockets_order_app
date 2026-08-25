import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practise_flutter_websockets_order_app/core/constants/ui_constants.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_event.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_state.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/pages/components/list_orders_widget.dart';
import 'package:practise_flutter_websockets_order_app/core/utils/snackbar_utils.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch orders only once when screen initializes
    context.read<OrderBloc>().add(const FetchOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Padding(
        padding: UIConstants.paddingHorizontalMedium,
        child: BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderNotificationState) {
              context.showSnackBar(state.message);
            }
          },
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is OrderErrorState) {
                return Center(child: Text(state.message));
              }

              if (state is OrderLoadedState) {
                if (state.listOrderItems.isEmpty) {
                  return const Center(child: Text('No orders.'));
                }
                return ListOrdersWidget(orders: state.listOrderItems);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}