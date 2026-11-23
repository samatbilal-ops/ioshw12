import '../../models/product.dart' as shop;
import '../models/product.dart';

/// The global cart (Lab 9) stores the shop's own Product type.
/// This converts a cloud product so it can be added to the same cart.
extension ProductToCart on Product {
  shop.Product toCartProduct() => shop.Product(
        id: 'api_$id',
        name: title,
        brand: 'Cloud Store',
        category: categoryLabel,
        price: price,
        rating: rating,
        reviews: reviewCount,
        tags: [categoryLabel],
        sizes: const [],
        description: description,
        imageUrl: imageUrl,
      );
}
