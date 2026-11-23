import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_event.dart';
import 'cart_state.dart';

/// Event-driven cart: Event in -> handler -> new State out.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddProductEvent>(_onAdd);
    on<RemoveProductEvent>(_onRemove);
    on<ClearCartEvent>(_onClear);
  }

  void _onAdd(AddProductEvent event, Emitter<CartState> emit) {
    final id = event.product.id;
    final exists = state.items.any((l) => l.product.id == id);

    final List<CartLine> next = exists
        // already in the cart -> quantity + 1 (new list, new line object)
        ? [
            for (final l in state.items)
              if (l.product.id == id)
                l.copyWith(quantity: l.quantity + 1)
              else
                l,
          ]
        // new product -> appended to the end
        : [...state.items, CartLine(product: event.product)];

    emit(CartState.fromItems(next));
  }

  void _onRemove(RemoveProductEvent event, Emitter<CartState> emit) {
    final next =
        state.items.where((l) => l.product.id != event.productId).toList();
    emit(CartState.fromItems(next));
  }

  void _onClear(ClearCartEvent event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
