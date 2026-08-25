import 'package:practise_flutter_websockets_order_app/features/orders/domain/entities/order_item.dart';

/// This class is a model for OrderItem
/// It extends the OrderItem entity and provides a factory constructor to create an OrderItemModel from
class OrderItemModel extends OrderItem{

  const OrderItemModel({
   required super.orderId,
   required super.meal, 
   required super.price, 
   required super.imageUrl,
   required super.status,
   required super.createdAt});

   //Mapping from OrderItemModel to OrderItem
    factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
      orderId: json['order_id'] as String,
      meal: json['meal'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  
}