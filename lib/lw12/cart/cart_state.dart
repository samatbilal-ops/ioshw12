import 'package:equatable/equatable.dart';

import '../../models/product.dart';

/// One line of the cart: a product and how many units of it.
class CartLine extends Equatable {
  final Product product;
  final int quantity;

  const CartLine({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product.id, quantity];
}

/// Immutable cart state. A new instance is emitted for every change
/// (the list is never mutated in place), so Equatable can detect it.
class CartState extends Equatable {
  final List<CartLine> items;
  final double totalPrice;

  /// Total number of units (sum of quantities): the AppBar badge number.
  final int count;

  const CartState({
    this.items = const [],
    this.totalPrice = 0,
    this.count = 0,
  });

  /// Derives total and count from the lines, so they can never disagree.
  factory CartState.fromItems(List<CartLine> items) => CartState(
        items: List.unmodifiable(items),
        totalPrice: items.fold<double>(0, (sum, l) => sum + l.subtotal),
        count: items.fold<int>(0, (sum, l) => sum + l.quantity),
      );

  bool get isEmpty => items.isEmpty;

  /// How many units of this product are in the cart (0 if none).
  int quantityOf(String productId) {
    for (final line in items) {
      if (line.product.id == productId) return line.quantity;
    }
    return 0;
  }

  @override
  List<Object?> get props => [items, totalPrice, count];
}
