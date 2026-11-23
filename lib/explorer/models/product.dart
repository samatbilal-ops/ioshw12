/// Product from https://fakestoreapi.com/products
///
/// NOTE: the sneaker catalog has its own `Product` in lib/models.
/// This one belongs to the "Cloud Explorer" feature (lib/explorer).
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  /// Type-safe parsing.
  /// JSON numbers can arrive as `int` (10) or `double` (10.5). A direct
  /// `json['price'] as double` crashes on 10, so we cast to `num` first
  /// and convert. Every field has a fallback, so a bad item never crashes the app.
  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'];
    final ratingMap =
        ratingJson is Map<String, dynamic> ? ratingJson : <String, dynamic>{};

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _text(json['title'], 'Untitled product'),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: _text(json['description'], 'No description available.'),
      category: _text(json['category'], 'other'),
      imageUrl: _text(json['image'], ''),
      rating: (ratingMap['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (ratingMap['count'] as num?)?.toInt() ?? 0,
    );
  }

  static String _text(Object? value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  /// "men's clothing" -> "Men's Clothing"
  String get categoryLabel => category
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  /// Deep link shown in the share sheet.
  String get deepLink => 'narxoz://store/product/$id';
}
