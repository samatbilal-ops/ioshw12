import 'package:flutter/material.dart';

import '../data/product_generator.dart';
import '../data/products_data.dart';
import '../models/product.dart';
import '../widgets/catalog_grid_card.dart';
import '../widgets/catalog_list_item.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_catalog.dart';

enum SortOption { none, priceLow, priceHigh, rating }

/// LW8: Smart Catalog. List <-> Grid, pull-to-refresh, swipe-to-delete + UNDO.
class FeedTab extends StatefulWidget {
  final Set<String> favoriteIds;
  final ValueChanged<Product> onOpen;
  final ValueChanged<String> onToggleFavorite;

  const FeedTab({
    super.key,
    required this.favoriteIds,
    required this.onOpen,
    required this.onToggleFavorite,
  });

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  // The data list that is changed by refresh / delete / undo.
  final List<Product> _items = List.of(kProducts);

  bool _isGrid = false;
  String _category = 'All';
  SortOption _sort = SortOption.none;
  int _refreshCount = 0;

  static const Map<SortOption, String> _sortLabels = {
    SortOption.none: 'Default',
    SortOption.priceLow: 'Price ↑',
    SortOption.priceHigh: 'Price ↓',
    SortOption.rating: 'Top rated',
  };

  // ---------- Data actions ----------

  /// Pull-to-refresh: fake 1.5 s network call, then new item at index 0.
  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _refreshCount++;
      _sort = SortOption.none; // so the new item really appears on top
      _items.insert(
        0,
        generateNewProduct(
          _refreshCount,
          category: _category == 'All' ? null : _category,
        ),
      );
    });
  }

  /// Swipe-to-delete: remove, remember the ORIGINAL index, offer UNDO.
  void _removeProduct(Product product) {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index == -1) return;

    setState(() => _items.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '"${product.name}" deleted',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                final at = index > _items.length ? _items.length : index;
                _items.insert(at, product);
              });
            },
          ),
        ),
      );
  }

  void _resetCatalog() {
    setState(() {
      _items
        ..clear()
        ..addAll(kProducts);
      _category = 'All';
      _sort = SortOption.none;
    });
  }

  // Filter by category, then sort (a copy - the source list stays untouched).
  List<Product> get _visible {
    final list = _items
        .where((p) => _category == 'All' || p.category == _category)
        .toList();
    switch (_sort) {
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.none:
        break;
    }
    return list;
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    // Empty state: nothing left in the catalog at all.
    if (_items.isEmpty) {
      return EmptyCatalog(onReset: _resetCatalog);
    }

    final items = _visible;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CategoryChips(
              categories: kCategories,
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} sneakers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  PopupMenuButton<SortOption>(
                    tooltip: 'Sort',
                    initialValue: _sort,
                    onSelected: (s) => setState(() => _sort = s),
                    itemBuilder: (context) => [
                      for (final e in _sortLabels.entries)
                        PopupMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 20),
                          const SizedBox(width: 4),
                          Text(_sortLabels[_sort]!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // List <-> Grid toggle
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.view_list),
                        tooltip: 'List view',
                      ),
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.grid_view),
                        tooltip: 'Grid view',
                      ),
                    ],
                    selected: {_isGrid},
                    onSelectionChanged: (s) =>
                        setState(() => _isGrid = s.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isGrid ? _buildGrid(items) : _buildList(items),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// View mode 1: ListView.separated (lazy: only visible rows are built).
  Widget _buildList(List<Product> items) {
    return RefreshIndicator(
      key: const ValueKey('list'),
      onRefresh: _refresh,
      child: items.isEmpty
          ? _emptyFilter()
          : ListView.separated(
              // Always scrollable -> pull-to-refresh works even with few items
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, i) {
                final p = items[i];
                return CatalogListItem(
                  product: p,
                  onTap: () => widget.onOpen(p),
                  onDismissed: () => _removeProduct(p),
                );
              },
            ),
    );
  }

  /// View mode 2: GridView.builder, 2 columns, childAspectRatio 0.72.
  Widget _buildGrid(List<Product> items) {
    return RefreshIndicator(
      key: const ValueKey('grid'),
      onRefresh: _refresh,
      child: items.isEmpty
          ? _emptyFilter()
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final p = items[i];
                return CatalogGridCard(
                  product: p,
                  isFavorite: widget.favoriteIds.contains(p.id),
                  onTap: () => widget.onOpen(p),
                  onFavorite: () => widget.onToggleFavorite(p.id),
                  onDismissed: () => _removeProduct(p),
                );
              },
            ),
    );
  }

  // Category filter has no matches (but the catalog itself is not empty).
  Widget _emptyFilter() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 260,
          child: Center(child: Text('No sneakers in this category')),
        ),
      ],
    );
  }
}
