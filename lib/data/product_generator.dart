import 'dart:math';

import '../models/product.dart';
import 'products_data.dart';

/// Items created by pull-to-refresh. Kept here so the Favorites tab can find them too.
final List<Product> kGeneratedProducts = [];

final Random _rnd = Random();

const List<String> _names = [
  'Fresh Drop',
  'Night Runner',
  'Cloud Walker',
  'Street Flex',
  'Retro Glide',
  'Summit Trail',
  'Urban Pulse',
  'Velvet Low',
];

const List<String> _brands = [
  'AeroRun',
  'Streetline',
  'Hoops',
  'FlexFit',
  'Heritage',
];

/// Simulates "new item arrived from the server".
Product generateNewProduct(int number, {String? category}) {
  final cat = category ?? kCategories[1 + _rnd.nextInt(kCategories.length - 1)];
  final base = kProducts[_rnd.nextInt(kProducts.length)];
  final price = 59 + _rnd.nextInt(121) + 0.99;
  final rating =
      double.parse((3.8 + _rnd.nextDouble() * 1.1).toStringAsFixed(1));

  final product = Product(
    id: 'new_${DateTime.now().microsecondsSinceEpoch}',
    name: '${_names[_rnd.nextInt(_names.length)]} #$number',
    brand: _brands[_rnd.nextInt(_brands.length)],
    category: cat,
    price: price,
    rating: rating,
    reviews: 20 + _rnd.nextInt(980),
    tags: ['New', cat, 'Just landed'],
    sizes: base.sizes,
    description:
        'Freshly added to the catalog by pull-to-refresh. Lightweight, '
        'comfortable and ready for everyday wear.',
    imageUrl: base.imageUrl,
  );
  kGeneratedProducts.add(product);
  return product;
}

List<Product> allKnownProducts() => [...kProducts, ...kGeneratedProducts];
