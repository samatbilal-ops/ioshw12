import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/product_image.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
import '../cart/cart_state.dart';

/// Screen 3: shows the cart. It is a different route from the catalog, yet it
/// reads the SAME CartBloc instance (provided above MaterialApp), so both
/// screens always agree.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('lw12_clear_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CartBloc>().add(const ClearCartEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEmpty ? 'Cart' : 'Cart (${state.count})'),
            actions: [
              if (!state.isEmpty)
                TextButton.icon(
                  key: const Key('lw12_clear_all'),
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear All'),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: state.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 72, color: theme.hintColor),
                      const SizedBox(height: 12),
                      Text('Your cart is empty',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Add something from the catalog',
                          style: TextStyle(color: theme.hintColor)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final line = state.items[i];
                          final p = line.product;
                          return Dismissible(
                            key: ValueKey(p.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) => context
                                .read<CartBloc>()
                                .add(RemoveProductEvent(p.id)),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ProductImage(
                                    path: p.imageUrl,
                                    width: 56,
                                    height: 56,
                                  ),
                                ),
                                title: Text(p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  '\$${p.price.toStringAsFixed(2)}  ×  ${line.quantity}'
                                  '  =  \$${line.subtotal.toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  key: Key('lw12_remove_${p.id}'),
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => context
                                      .read<CartBloc>()
                                      .add(RemoveProductEvent(p.id)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(
                            top: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${state.count} item(s)',
                                      style:
                                          TextStyle(color: theme.hintColor)),
                                  Text(
                                    'Total: \$${state.totalPrice.toStringAsFixed(2)}',
                                    key: const Key('lw12_total_text'),
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _confirmClear(context),
                              icon: const Icon(Icons.delete_sweep_outlined),
                              label: const Text('Clear All'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
