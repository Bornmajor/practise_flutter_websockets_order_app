import 'package:dio/dio.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/data/models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  Future<List<MenuItemModel>> getMenuDataItems();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({required this.dio});

 /// Fetches menu data items from the remote API
  @override
  Future<List<MenuItemModel>> getMenuDataItems() async {
    final response = await dio.get('/menu');

    // Access inner list data from the response
    final List<dynamic> rawList = response.data['data'] as List<dynamic>;

    // Map over the list elements
    return rawList.map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
