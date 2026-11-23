import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

/// Screen 2: selected products, remove buttons, total price, Clear All.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _remove(BuildContext context, CartProvider cart, CartItem item) {
    final index = cart.indexOf(item.product.id);
    cart.remove(item.product.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          '"${item.product.name}" removed',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => cart.insertAt(index, item),
        ),
      ));
  }

  void _clearAll(BuildContext context, CartProvider cart) {
    final removed = cart.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Cart cleared (${removed.length} items)'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => cart.restore(removed),
        ),
      ));
  }

  Future<void> _checkout(BuildContext context, CartProvider cart) async {
    final total = cart.totalPrice;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Order placed'),
        content: Text('Total paid: \$${total.toStringAsFixed(2)} (demo)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    // watch -> this screen is rebuilt on every cart change
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cart.totalQuantity})'),
        actions: [
          TextButton.icon(
            onPressed: cart.isEmpty ? null : () => _clearAll(context, cart),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear All'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onBack: () => Navigator.of(context).pop())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, thickness: 0.5),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return CartItemTile(
                      key: ValueKey(item.product.id),
                      item: item,
                      onIncrement: () => cart.increment(item.product.id),
                      onDecrement: () => cart.decrement(item.product.id),
                      onRemove: () => _remove(context, cart, item),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Material(
              elevation: 12,
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: false,
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text('${cart.productCount} product(s), '
                                  '${cart.totalQuantity} pair(s)'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Total',
                                  style: theme.textTheme.titleMedium),
                              const Spacer(),
                              Text(
                                '\$${cart.totalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _checkout(context, cart),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  icon: const Icon(Icons.lock_outline),
                                  label: const Text('Checkout'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyCart({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add sneakers from the catalog.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Back to catalog'),
            ),
          ],
        ),
      ),
    );
  }
}
