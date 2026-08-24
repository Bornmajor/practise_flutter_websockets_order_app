import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:practise_flutter_websockets_order_app/core/config/app_config.dart';
import 'package:practise_flutter_websockets_order_app/core/network/dio_client.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/repositories/menu_repositories.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/usecases/get_menu_items_use_case.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/presentation/bloc/menu_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Load configuration
  final appConfig = await AppConfig.loadFromAsset();
  sl.registerSingleton<AppConfig>(appConfig);

  // Register Dio client (Injecting AppConfig)
  sl.registerLazySingleton<Dio>(() => createDioClient(sl<AppConfig>()));

  // Register data sources
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  //Register repositories
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(menuRemoteDataSource: sl<MenuRemoteDataSource>()),
  );

  //Register use cases
  sl.registerLazySingleton<GetMenuItemsUseCase>(() => GetMenuItemsUseCase(repository: sl<MenuRepository>()));

  // Blocs
  sl.registerFactory(() => MenuBloc(getMenuItemsUseCase: sl<GetMenuItemsUseCase>()));
}
