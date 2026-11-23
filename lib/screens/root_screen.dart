import 'package:flutter/material.dart';

import '../data/product_generator.dart';
import '../explorer/screens/explorer_screen.dart';
import '../models/product.dart';
import '../widgets/cart_badge_button.dart';
import 'detail_screen.dart';
import 'favorites_tab.dart';
import 'feed_tab.dart';
import 'profile_tab.dart';
import '../vault/screens/vault_screen.dart';

/// Root screen with BottomNavigationBar (Feed / Cloud / Favorites / Profile).
/// The cart is NOT stored here - it lives in CartProvider.
class RootScreen extends StatefulWidget {
  final String userName;
  const RootScreen({super.key, this.userName = 'Guest'});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  static const List<String> _titles = [
    'SoleStore',
    'Cloud Explorer',
    'Favorites',
    'Profile',
    'Vault',
  ];

  int _index = 0;
  bool _cloudOpened = false; // the API is called only when the tab is first opened
  final Set<String> _favoriteIds = {};

  void _toggleFavorite(String id) {
    setState(() {
      if (!_favoriteIds.remove(id)) _favoriteIds.add(id);
    });
  }

  // Navigator.push: send the complete Product object to DetailScreen.
  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          product: product,
          isFavorite: _favoriteIds.contains(product.id),
          onToggleFavorite: () => _toggleFavorite(product.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites =
        allKnownProducts().where((p) => _favoriteIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles[_index]),
        actions: const [CartBadgeButton(), SizedBox(width: 8)],
      ),
      // IndexedStack keeps every tab alive -> state is not lost when switching.
      body: IndexedStack(
        index: _index,
        children: [
          FeedTab(
            favoriteIds: _favoriteIds,
            onOpen: _openDetail,
            onToggleFavorite: _toggleFavorite,
          ),
          _cloudOpened ? const ExplorerScreen() : const SizedBox.shrink(),
          FavoritesTab(
            favorites: favorites,
            onOpen: _openDetail,
            onToggleFavorite: _toggleFavorite,
          ),
          ProfileTab(
            userName: widget.userName,
            favoritesCount: favorites.length,
            onLogout: () => Navigator.of(context).pop(),
          ),
          const VaultScreen(), // Lab 11
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // needed for 4+ items
        currentIndex: _index,
        onTap: (i) => setState(() {
          _index = i;
          if (i == 1) _cloudOpened = true;
        }),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.cloud_outlined),
            activeIcon: Icon(Icons.cloud),
            label: 'Cloud',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: favorites.isNotEmpty,
              label: Text('${favorites.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            activeIcon: Badge(
              isLabelVisible: favorites.isNotEmpty,
              label: Text('${favorites.length}'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Favorites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Vault',
          ),
        ],
      ),
    );
  }
}
