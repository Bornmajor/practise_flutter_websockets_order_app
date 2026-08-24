import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/models/menu_item_model.dart';

/// This abstract class defines the contract for a MenuRepository
abstract class MenuRepository {
  Future<Either<Failure, List<MenuItemModel>>> getMenuItems();
}