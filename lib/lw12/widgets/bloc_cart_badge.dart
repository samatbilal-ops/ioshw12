import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cart/cart_bloc.dart';
import '../cart/cart_state.dart';
import '../screens/cart_screen.dart';

/// AppBar cart icon. BlocBuilder rebuilds ONLY this icon when the cart changes,
/// so the badge stays live on every screen that shows it.
class BlocCartBadge extends StatelessWidget {
  const BlocCartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (previous, current) => previous.count != current.count,
      builder: (context, state) {
        return IconButton(
          key: const Key('lw12_cart_button'),
          tooltip: 'Cart',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CartScreen()),
          ),
          icon: Badge(
            isLabelVisible: state.count > 0,
            label: Text('${state.count}'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}
