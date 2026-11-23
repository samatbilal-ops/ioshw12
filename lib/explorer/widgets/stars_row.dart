import 'package:flutter/material.dart';

class StarsRow extends StatelessWidget {
  final double rating;
  final double size;
  const StarsRow({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            rating >= i + 0.75
                ? Icons.star
                : rating >= i + 0.25
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
      ],
    );
  }
}
