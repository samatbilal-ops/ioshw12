import 'package:flutter_test/flutter_test.dart';
// NOTE: "sole_app" must match the `name:` in your pubspec.yaml
import 'package:sole_app/explorer/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a normal API item', () {
      final p = Product.fromJson({
        'id': 1,
        'title': 'Backpack',
        'price': 109.95,
        'description': 'Fits 15 inch laptops',
        'category': "men's clothing",
        'image': 'https://fakestoreapi.com/img/1.jpg',
        'rating': {'rate': 3.9, 'count': 120},
      });
      expect(p.id, 1);
      expect(p.title, 'Backpack');
      expect(p.price, 109.95);
      expect(p.rating, 3.9);
      expect(p.reviewCount, 120);
      expect(p.categoryLabel, "Men's Clothing");
      expect(p.deepLink, 'narxoz://store/product/1');
    });

    test('int price and int rating do NOT crash (num -> double)', () {
      final p = Product.fromJson({
        'id': 2,
        'title': 'Ring',
        'price': 10, // int in JSON
        'rating': {'rate': 4, 'count': 7}, // int in JSON
      });
      expect(p.price, 10.0);
      expect(p.price, isA<double>());
      expect(p.rating, 4.0);
      expect(p.rating, isA<double>());
    });

    test('empty map gets safe fallbacks (no exception)', () {
      final p = Product.fromJson({});
      expect(p.id, 0);
      expect(p.title, 'Untitled product');
      expect(p.price, 0.0);
      expect(p.rating, 0.0);
      expect(p.reviewCount, 0);
      expect(p.imageUrl, '');
    });

    test('missing or broken rating object is handled', () {
      expect(Product.fromJson({'rating': null}).rating, 0.0);
      expect(Product.fromJson({'rating': 'bad'}).reviewCount, 0);
    });

    test('wrong types fall back instead of throwing', () {
      final p = Product.fromJson({
        'id': 'abc',
        'title': 123,
        'price': 'free',
      });
      expect(p.id, 0);
      expect(p.title, 'Untitled product');
      expect(p.price, 0.0);
    });
  });
}
