import 'package:flutter/material.dart';
import 'package:practise_flutter_websockets_order_app/core/constants/ui_constants.dart';
import 'package:practise_flutter_websockets_order_app/features/menu/domain/entities/menu_item.dart';

class MenuItemCard extends StatelessWidget {

  const MenuItemCard({super.key, required this.item, required this.onTap});

  final MenuItem item;
  final  VoidCallback? onTap;



  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: UIConstants.spacingMedium,
        children: [
         // Image
         Expanded(
            child: Image.network(
              item.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: UIConstants.spacingSmall,
            children: 
            [
             Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ),
               TextButton(
                onPressed: onTap,
                child: Text(
                  "Place order",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  )
                  )
              ),
             

          ],)

        ],
      )
      
    
    );
  }
}
