import 'package:flutter/material.dart';

import '../providers/cart_provider.dart';
import 'product_image.dart';

/// One line of the Cart screen: photo, name, size, quantity stepper, subtotal, remove.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = item.product;
    final details = [
      p.category,
      if (item.size != null) 'Size ${item.size}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProductImage(path: p.imageUrl, width: 72, height: 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Decrease',
                      onPressed: item.quantity > 1 ? onDecrement : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Increase',
                      onPressed: onIncrement,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.quantity > 1)
                Text(
                  '${item.quantity} × \$${p.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              IconButton(
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
