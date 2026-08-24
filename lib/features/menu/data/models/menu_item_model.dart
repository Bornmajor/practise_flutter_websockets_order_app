import 'package:practise_flutter_websockets_order_app/features/menu/domain/entities/menu_item.dart';

/// This class is a model for MenuItem
/// It extends the MenuItem entity and provides a factory constructor to create a MenuItemModel from JSON data.
class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.imageUrl,
  });

  // Mapping data from JSON to MenuItemModel
  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['image_url'] as String,
  );
}
