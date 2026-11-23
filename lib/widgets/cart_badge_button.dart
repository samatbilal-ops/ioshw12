import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

/// AppBar cart icon with a LIVE badge. Opens the cart screen.
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count =
        context.select<CartProvider, int>((cart) => cart.totalQuantity);

    return IconButton(
      tooltip: 'Cart',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CartScreen()),
      ),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
