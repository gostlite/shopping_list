import 'package:flutter/material.dart';

enum Categories {
  food,
  carbs,
  fruit,
  dairy,
  vegetables,
  meat,
  sweets,
  spices,
  hygiene,
  convenience,
  other
}

class Category {
  const Category(this.title, this.color);
  final String title;
  final Color color;
}
