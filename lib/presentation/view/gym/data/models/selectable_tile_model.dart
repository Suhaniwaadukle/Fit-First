import 'package:flutter/material.dart';

class SelectableTileItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  SelectableTileItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}
