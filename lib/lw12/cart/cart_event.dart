import 'package:equatable/equatable.dart';

import '../../models/product.dart';

/// Everything that can happen to the cart. The UI never edits the cart
/// directly: it only dispatches one of these events with `bloc.add(...)`.
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Put one more unit of [product] into the cart.
class AddProductEvent extends CartEvent {
  final Product product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product.id];
}

/// Remove the whole line of the product with [productId].
class RemoveProductEvent extends CartEvent {
  final String productId;

  const RemoveProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Empty the cart.
class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
