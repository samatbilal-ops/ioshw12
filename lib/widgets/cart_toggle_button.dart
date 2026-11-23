import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

/// "Add to Cart" toggle. Rebuilds ONLY when this product enters/leaves the cart.
class CartToggleButton extends StatelessWidget {
  final Product product;
  const CartToggleButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // select -> listen to one bool, not to the whole cart
    final inCart =
        context.select<CartProvider, bool>((cart) => cart.contains(product.id));

    void onPressed() => context.read<CartProvider>().toggle(product);

    return inCart
        ? IconButton.filled(
            tooltip: 'Remove from cart',
            visualDensity: VisualDensity.compact,
            onPressed: onPressed,
            icon: const Icon(Icons.remove_shopping_cart, size: 20),
          )
        : IconButton.outlined(
            tooltip: 'Add to cart',
            visualDensity: VisualDensity.compact,
            onPressed: onPressed,
            icon: const Icon(Icons.add_shopping_cart, size: 20),
          );
  }
}
