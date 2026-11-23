import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../screens/cart_screen.dart';
import '../../widgets/cart_badge_button.dart';
import '../mappers/cart_mapper.dart';
import '../models/product.dart';
import '../widgets/photo_carousel.dart';
import '../widgets/share_sheet.dart';
import '../widgets/stars_row.dart';

/// Master-detail: Hero image, photo carousel, description, share, Add to Cart.
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final List<String> relatedImages;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.relatedImages = const [],
  });

  void _addToCart(BuildContext context) {
    // Same global cart as the sneaker catalog (Lab 9).
    context.read<CartProvider>().add(product.toCartProduct());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text('Added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CartScreen()),
          ),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = [product.imageUrl, ...relatedImages];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: () => showShareSheet(context, product),
            icon: const Icon(Icons.share_outlined),
          ),
          const CartBadgeButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoCarousel(
                  images: images,
                  heroTag: 'product_image_${product.id}',
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.sell_outlined, size: 16),
                        label: Text(product.categoryLabel),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          StarsRow(rating: product.rating, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${product.rating.toStringAsFixed(1)} '
                              '(${product.reviewCount} reviews)',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Description', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(product.description),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Sticky bottom bar: price + full-width "Add to Cart"
      bottomNavigationBar: Material(
        elevation: 12,
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Price', style: theme.textTheme.bodySmall),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _addToCart(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Add to Cart'),
                        ),
                      ),
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
