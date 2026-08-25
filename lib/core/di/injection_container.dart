import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:practise_flutter_websockets_order_app/core/config/app_config.dart';
import 'package:practise_flutter_websockets_order_app/core/network/dio_client.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/repositories/menu_repositories.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/usecases/get_menu_items_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/repositories/order_repository.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/create_order_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/orders/presentation/bloc/order_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Load configuration
  final appConfig = await AppConfig.loadFromAsset();
  sl.registerSingleton<AppConfig>(appConfig);

  // Register Dio client (Injecting AppConfig)
  sl.registerLazySingleton<Dio>(() => createDioClient(sl<AppConfig>()));

  // Register data sources (injecting Dio client)
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Register repositories (inject data sources)
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(menuRemoteDataSource: sl<MenuRemoteDataSource>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () =>
        OrderRepositoryImpl(orderRemoteDataSource: sl<OrderRemoteDataSource>()),
  );

  //Register use cases (inject repositories)
  sl.registerLazySingleton<GetMenuItemsUseCase>(
    () => GetMenuItemsUseCase(repository: sl<MenuRepository>()),
  );
  sl.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(orderRepository: sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(orderRepository: sl<OrderRepository>()),
  );

  // Blocs (inject use cases)
  sl.registerFactory(
    () => MenuBloc(getMenuItemsUseCase: sl<GetMenuItemsUseCase>()),
  );

  sl.registerFactory(
    () => OrderBloc(
      createOrderUseCase: sl<CreateOrderUseCase>(),
      getOrdersUseCase: sl<GetOrdersUseCase>(),
    ),
  );
}
