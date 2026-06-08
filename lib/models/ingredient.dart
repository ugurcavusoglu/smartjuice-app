import 'package:flutter/material.dart';

class Ingredient {
  final String name;
  final IconData icon;
  final String emoji;
  final String amount;
  int ml;

  Ingredient({
    required this.name,
    required this.icon,
    this.ml = 100,
    this.emoji = '',
    this.amount = '',
  });

  Ingredient copyWith({int? ml}) =>
      Ingredient(name: name, icon: icon, ml: ml ?? this.ml, emoji: emoji, amount: amount);
}
