import 'package:dartz/dartz.dart';
import 'package:practise_flutter_websockets_order_app/core/error/failures.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/models/menu_item_model.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/repositories/menu_repositories.dart';

/// This class represents the use case for fetching menu items.
/// [MenuRepository] - The repository that provides the data for menu items.
class GetMenuItemsUseCase {
  final MenuRepository repository;

  GetMenuItemsUseCase({required this.repository});

  Future<Either<Failure, List<MenuItemModel>>> call() async {
    return await repository.getMenuItems();
  }
}