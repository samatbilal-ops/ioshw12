import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';

/// Share button -> modal bottom sheet with the deep link and a copy button.
Future<void> showShareSheet(BuildContext context, Product product) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _ShareSheet(product: product),
  );
}

class _ShareSheet extends StatefulWidget {
  final Product product;
  const _ShareSheet({required this.product});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.product.deepLink));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = widget.product.deepLink;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share product',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Text('Deep link', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      link,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy link',
                    onPressed: _copy,
                    icon: Icon(_copied ? Icons.check : Icons.copy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _copy,
                icon: Icon(_copied ? Icons.check : Icons.copy),
                label: Text(_copied ? 'Copied!' : 'Copy link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
