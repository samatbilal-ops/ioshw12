import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/products_data.dart';
import '../../models/product.dart';
import '../../widgets/product_image.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../cart/cart_bloc.dart';
import '../cart/cart_event.dart';
import '../cart/cart_state.dart';
import '../widgets/bloc_cart_badge.dart';
import 'login_screen.dart';

/// Screen 2: product list. "Add" dispatches AddProductEvent to the CartBloc;
/// the AppBar badge listens to the same bloc through BlocBuilder.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocListener: side effect only (no UI). After logout() -> back to Login.
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthInitial,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catalog'),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) => Text(
                  state is AuthSuccess ? 'Hi, ${state.username}' : '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          actions: [
            const BlocCartBadge(),
            IconButton(
              key: const Key('lw12_logout_button'),
              tooltip: 'Log out',
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthCubit>().logout(),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: kProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _ProductCard(product: kProducts[i]),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ProductImage(
                path: product.imageUrl,
                width: 92,
                height: 92,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(product.brand,
                      style: TextStyle(color: theme.hintColor, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.oldPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    // Rebuild just this button when THIS product's quantity changes.
                    child: BlocBuilder<CartBloc, CartState>(
                      buildWhen: (p, c) =>
                          p.quantityOf(product.id) != c.quantityOf(product.id),
                      builder: (context, state) {
                        final qty = state.quantityOf(product.id);
                        return FilledButton.tonalIcon(
                          key: Key('lw12_add_${product.id}'),
                          onPressed: () {
                            context
                                .read<CartBloc>()
                                .add(AddProductEvent(product));
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text('${product.brand} added'),
                                  duration: const Duration(milliseconds: 900),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                          },
                          icon: Icon(
                              qty == 0 ? Icons.add_shopping_cart : Icons.check),
                          label: Text(qty == 0 ? 'Add' : 'Add  ($qty)'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
