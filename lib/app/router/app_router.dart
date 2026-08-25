import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:practise_flutter_websockets_order_app/app/router/route_names.dart';
import 'package:practise_flutter_websockets_order_app/app/router/scaffold_with_navbar.dart';
import 'package:practise_flutter_websockets_order_app/core/di/injection_container.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_events.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/pages/menu_screen.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/pages/order_screen.dart';

// Key for the root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.menu.path,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        //Wrap entire shell with OrderBloc
        return BlocProvider<OrderBloc>(
          create:(_) => sl<OrderBloc>(),
          child:  ScaffoldWithNavbar(navigationShell: navigationShell)
          );
      },
      branches: [
        //Menu branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.menu.path,
              name: AppRoutes.menu.name,
              builder: (context, state) => BlocProvider<MenuBloc>(
                create: (_) => sl<MenuBloc>()..add(FetchMenuItemsEvent()),
                child: const MenuScreen(),
              ) ,
            ),
          ],
        ),
        //Order branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.order.path,
              name: AppRoutes.order.name,
              builder: (context, state) => const OrderScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
