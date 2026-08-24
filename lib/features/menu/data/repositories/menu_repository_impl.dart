import 'package:dio/dio.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/models/menu_item_model.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/repositories/menu_repositories.dart';
import 'package:dartz/dartz.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource menuRemoteDataSource;

  MenuRepositoryImpl({required this.menuRemoteDataSource});

  @override
  Future<Either<Failure, List<MenuItemModel>>> getMenuItems() async {
    try {
      final listItemsResponse = await menuRemoteDataSource.getMenuDataItems();
      return Right(listItemsResponse);
    } on DioException catch (e) {
      return Left(handleDioException(e));
    } catch (e){
      return Left(UnknownFailure(e.toString()));
    }
  }
}
