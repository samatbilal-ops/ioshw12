import 'package:flutter/material.dart';

/// Red background revealed under an item while swiping it right-to-left.
class SwipeDeleteBackground extends StatelessWidget {
  final double borderRadius;
  const SwipeDeleteBackground({super.key, this.borderRadius = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(height: 2),
          Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
