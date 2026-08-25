import 'package:flutter/material.dart';

enum OrderStatus {
  orderPlaced('ORDER_PLACED'),
  preparing('PREPARING'),
  outForDelivery('OUT_FOR_DELIVERY'),
  delivered('DELIVERED');

  // Key matching the backend response string
  final String value;

  const OrderStatus(this.value);

  /// Converts backend string to OrderStatus enum
  static OrderStatus fromString(String rawValue) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == rawValue.toUpperCase(),
      orElse: () => OrderStatus.orderPlaced,
    );
  }

  /// Human-readable title to show in UI
  String get displayTitle {
    return switch (this) {
      OrderStatus.orderPlaced => 'Order Placed',
      OrderStatus.preparing => 'Preparing Food',
      OrderStatus.outForDelivery => 'Out for Delivery',
      OrderStatus.delivered => 'Delivered',
    };
  }

  /// Theme-based badge/text color
  Color color(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      OrderStatus.orderPlaced => colorScheme.primary,
      OrderStatus.preparing => Colors.orange,
      OrderStatus.outForDelivery => Colors.blue,
      OrderStatus.delivered => Colors.green,
    };
  }
}