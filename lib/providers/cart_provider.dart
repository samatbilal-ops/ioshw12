import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// One line in the cart.
class CartItem {
  final Product product;
  int quantity;
  int? size;

  CartItem({required this.product, this.quantity = 1, this.size});

  double get subtotal => product.price * quantity;
}

/// Global cart state. Every screen that reads it is rebuilt automatically
/// after notifyListeners(), so Catalog and Cart are always in sync.
class CartProvider extends ChangeNotifier {
  // Map keeps insertion order -> the cart shows items in the order they were added.
  final Map<String, CartItem> _items = {};

  // ---------- Read-only state ----------
  List<CartItem> get items => List.unmodifiable(_items.values);
  bool get isEmpty => _items.isEmpty;
  int get productCount => _items.length;

  /// Number shown in the AppBar badge (sum of all quantities).
  int get totalQuantity => _items.values.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice => _items.values.fold(0.0, (sum, i) => sum + i.subtotal);

  bool contains(String id) => _items.containsKey(id);
  int indexOf(String id) => _items.keys.toList().indexOf(id);

  // ---------- Actions ----------

  /// Catalog "Add to Cart" toggle. Returns true if the product is now in the cart.
  bool toggle(Product product) {
    if (contains(product.id)) {
      _items.remove(product.id);
      notifyListeners();
      return false;
    }
    _items[product.id] = CartItem(product: product);
    notifyListeners();
    return true;
  }

  /// Used by the detail screen (quantity + size).
  void add(Product product, {int quantity = 1, int? size}) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity += quantity;
      existing.size = size ?? existing.size;
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
        size: size,
      );
    }
    notifyListeners();
  }

  void increment(String id) {
    final item = _items[id];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  void decrement(String id) {
    final item = _items[id];
    if (item == null || item.quantity <= 1) return;
    item.quantity--;
    notifyListeners();
  }

  /// Removes one product. Returns the removed line (for UNDO).
  CartItem? remove(String id) {
    final removed = _items.remove(id);
    if (removed != null) notifyListeners();
    return removed;
  }

  /// UNDO for remove(): puts the line back at its old position.
  void insertAt(int index, CartItem item) {
    final entries = _items.entries.toList();
    final at = index < 0 ? 0 : (index > entries.length ? entries.length : index);
    entries.insert(at, MapEntry(item.product.id, item));
    _items
      ..clear()
      ..addEntries(entries);
    notifyListeners();
  }

  /// "Clear All". Returns the removed lines (for UNDO).
  List<CartItem> clear() {
    final removed = List<CartItem>.of(_items.values);
    _items.clear();
    notifyListeners();
    return removed;
  }

  /// UNDO for clear().
  void restore(Iterable<CartItem> lines) {
    for (final line in lines) {
      _items[line.product.id] = line;
    }
    notifyListeners();
  }
}
