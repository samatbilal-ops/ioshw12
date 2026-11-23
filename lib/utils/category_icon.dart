import 'package:flutter/material.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Sport':
      return Icons.directions_run;
    case 'Classic':
      return Icons.workspace_premium_outlined;
    case 'Casual':
      return Icons.weekend_outlined;
    default:
      return Icons.hiking;
  }
}
