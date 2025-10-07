import 'package:flutter/material.dart';

enum Categories {
  vegetable,
  fruits,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
  dairy,
  meat,
}

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;
}
