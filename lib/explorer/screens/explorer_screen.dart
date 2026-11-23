import 'package:flutter/material.dart';

import '../../widgets/category_chips.dart';
import '../models/product.dart';
import '../services/product_api.dart';
import '../widgets/error_view.dart';
import '../widgets/product_row.dart';
import 'product_detail_screen.dart';

enum _LoadState { loading, success, error }

/// Lab 10: Cloud Product Explorer.
/// Three UI states: Loading spinner -> Product feed -> Error with Retry.
class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final ProductApi _api = ProductApi();

  _LoadState _state = _LoadState.loading;
  List<Product> _products = [];
  ApiException? _error;

  String _category = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Full load: shows the spinner, then success or error.
  Future<void> _load() async {
    setState(() {
      _state = _LoadState.loading;
      _error = null;
    });
    try {
      final data = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = data;
        _state = _LoadState.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _state = _LoadState.error;
      });
    }
  }

  /// Pull-to-refresh: keeps the list on screen. If it fails, the old data stays
  /// and a SnackBar explains why.
  Future<void> _refresh() async {
    try {
      final data = await _api.fetchProducts();
      if (!mounted) return;
      setState(() => _products = data);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Refresh failed: ${e.message}'),
        ));
    }
  }

  List<String> get _categories => [
        'All',
        ...{for (final p in _products) p.categoryLabel},
      ];

  List<Product> get _visible => _products.where((p) {
        final matchCategory = _category == 'All' || p.categoryLabel == _category;
        final matchQuery =
            p.title.toLowerCase().contains(_query.toLowerCase().trim());
        return matchCategory && matchQuery;
      }).toList();

  void _open(Product product) {
    // The carousel needs several photos, but the API gives one per product,
    // so we add photos of other products from the same category.
    final related = _products
        .where((p) => p.id != product.id && p.category == product.category)
        .take(2)
        .map((p) => p.imageUrl)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          relatedImages: related,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _LoadState.loading => const _LoadingView(),
      _LoadState.error => ErrorView(
          message: _error?.message ?? 'Unknown error',
          offline: _error?.isOffline ?? false,
          onRetry: _load,
        ),
      _LoadState.success => _buildFeed(),
    };
  }

  Widget _buildFeed() {
    final items = _visible;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            CategoryChips(
              categories: _categories,
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} products',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'fakestoreapi.com',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 260,
                            child: Center(child: Text('No products found')),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, thickness: 0.5),
                        itemBuilder: (context, i) => ProductRow(
                          product: items[i],
                          onTap: () => _open(items[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// UI state 1: centered spinner.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading products...'),
        ],
      ),
    );
  }
}
