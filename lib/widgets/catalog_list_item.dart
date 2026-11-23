import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/category_icon.dart';
import 'cart_toggle_button.dart';
import 'swipe_delete_background.dart';

/// One row of the List view: avatar, title, category tag, rating, price + cart toggle.
/// Wrapped in Dismissible -> swipe right-to-left to delete.
///
/// Built with a plain Row (not ListTile): the row height follows its content,
/// so the price + cart button can never overflow.
class CatalogListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const CatalogListItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      // Mandatory unique key: tells Flutter WHICH item is being removed.
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart, // right -> left
      background: const SwipeDeleteBackground(),
      onDismissed: (_) => onDismissed(),
      // Opaque Material so the red background is hidden until you swipe.
      child: Material(
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    categoryIcon(product.category),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text('${product.rating}',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CartToggleButton(product: product),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
