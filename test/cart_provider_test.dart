import 'package:flutter_test/flutter_test.dart';
// NOTE: "sole_app" must match the `name:` in your pubspec.yaml
import 'package:sole_app/models/product.dart';
import 'package:sole_app/providers/cart_provider.dart';

Product _p(String id, double price) => Product(
      id: id,
      name: 'Shoe $id',
      brand: 'Brand',
      category: 'Sport',
      price: price,
      rating: 4.0,
      reviews: 1,
      tags: const [],
      sizes: const [40],
      description: '',
      imageUrl: '',
    );

void main() {
  late CartProvider cart;
  final a = _p('a', 100);
  final b = _p('b', 50);
  final c = _p('c', 25.5);

  setUp(() => cart = CartProvider());

  test('toggle adds, then removes the same product', () {
    expect(cart.toggle(a), isTrue);
    expect(cart.contains('a'), isTrue);
    expect(cart.toggle(a), isFalse);
    expect(cart.contains('a'), isFalse);
    expect(cart.isEmpty, isTrue);
  });

  test('total price and badge quantity', () {
    cart.add(a, quantity: 2, size: 42); // 200
    cart.toggle(b); // 50
    cart.toggle(c); // 25.5
    expect(cart.totalQuantity, 4);
    expect(cart.productCount, 3);
    expect(cart.totalPrice, 275.5);
  });

  test('increment / decrement (never below 1)', () {
    cart.toggle(a);
    cart.increment('a');
    expect(cart.totalQuantity, 2);
    cart.decrement('a');
    cart.decrement('a');
    expect(cart.totalQuantity, 1);
  });

  test('remove + insertAt (UNDO) keeps the original position', () {
    cart
      ..toggle(a)
      ..toggle(b)
      ..toggle(c);
    final index = cart.indexOf('b');
    final removed = cart.remove('b')!;
    expect(cart.contains('b'), isFalse);
    cart.insertAt(index, removed);
    expect(cart.items.map((i) => i.product.id).toList(), ['a', 'b', 'c']);
  });

  test('clear + restore (UNDO)', () {
    cart
      ..toggle(a)
      ..toggle(b);
    final removed = cart.clear();
    expect(cart.isEmpty, isTrue);
    expect(cart.totalPrice, 0);
    cart.restore(removed);
    expect(cart.productCount, 2);
  });

  test('every change notifies listeners (this is what syncs the screens)', () {
    var calls = 0;
    cart.addListener(() => calls++);
    cart.toggle(a);
    cart.increment('a');
    cart.remove('a');
    cart.clear();
    expect(calls, greaterThanOrEqualTo(3));
  });
}
