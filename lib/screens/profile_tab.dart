import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../lw12/auth/auth_cubit.dart';
import '../lw12/screens/login_screen.dart';
import '../providers/cart_provider.dart';

/// Tab 3: profile / settings (name comes from the registration form).
class ProfileTab extends StatefulWidget {
  final String userName;
  final int favoritesCount;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.userName,
    required this.favoritesCount,
    required this.onLogout,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notifications = true;
  bool _newsletter = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              widget.userName.isEmpty ? '?' : widget.userName[0].toUpperCase(),
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            widget.userName,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('Sneaker lover',
              style: TextStyle(color: Colors.grey.shade600)),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Saved sneakers'),
                trailing: Text('${widget.favoritesCount}',
                    style: theme.textTheme.titleMedium),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Items in cart'),
                trailing: Text('${context.watch<CartProvider>().totalQuantity}',
                    style: theme.textTheme.titleMedium),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Push notifications'),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.email_outlined),
                title: const Text('Email newsletter'),
                value: _newsletter,
                onChanged: (v) => setState(() => _newsletter = v),
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('LW12: BLoC Shop'),
            subtitle: const Text('Login (Cubit) -> Catalog -> Cart (Bloc)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.read<AuthCubit>().logout(); // always start at the login
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
