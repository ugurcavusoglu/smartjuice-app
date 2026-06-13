import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

List<Recipe> buildStaticRecipes() => [
      // ── Favourites ──────────────────────────────────────────────────────
      Recipe(
        id: '1',
        name: 'Tropical Energy',
        totalMlOverride: 200,
        isFavourite: true,
        ingredients: [
          Ingredient(name: 'Mango', icon: Icons.circle, ml: 100, emoji: '🥭', amount: '1 piece'),
          Ingredient(name: 'Orange', icon: Icons.circle, ml: 100, emoji: '🍊', amount: '1 piece'),
          Ingredient(name: 'Pineapple', icon: Icons.circle, ml: 100, emoji: '🍍', amount: '2 slices'),
        ],
      ),
      Recipe(
        id: '2',
        name: 'Green Detox',
        totalMlOverride: 300,
        isFavourite: true,
        ingredients: [
          Ingredient(name: 'Apple', icon: Icons.circle, ml: 100, emoji: '🍎', amount: '1 piece'),
          Ingredient(name: 'Lemon', icon: Icons.circle, ml: 80, emoji: '🍋', amount: '1 piece'),
          Ingredient(name: 'Kiwi', icon: Icons.circle, ml: 120, emoji: '🥝', amount: '1 piece'),
        ],
      ),
      Recipe(
        id: '3',
        name: 'Pink Fresh',
        totalMlOverride: 250,
        isFavourite: true,
        ingredients: [
          Ingredient(name: 'Strawberry', icon: Icons.circle, ml: 150, emoji: '🍓', amount: '3 pieces'),
          Ingredient(name: 'Cherry', icon: Icons.circle, ml: 100, emoji: '🍒', amount: '2 pieces'),
        ],
      ),
      Recipe(
        id: '4',
        name: 'Berry Blast',
        totalMlOverride: 280,
        isFavourite: true,
        ingredients: [
          Ingredient(name: 'Blueberry', icon: Icons.circle, ml: 140, emoji: '🫐', amount: '2 pieces'),
          Ingredient(name: 'Grape', icon: Icons.circle, ml: 140, emoji: '🍇', amount: '1 piece'),
        ],
      ),

      // ── Last Recipes ─────────────────────────────────────────────────────
      Recipe(
        id: '5',
        name: 'Sunrise Glow',
        totalMlOverride: 250,
        ingredients: [
          Ingredient(name: 'Peach', icon: Icons.circle, ml: 100, emoji: '🍑', amount: '2 pieces'),
          Ingredient(name: 'Orange', icon: Icons.circle, ml: 100, emoji: '🍊', amount: '1 piece'),
          Ingredient(name: 'Lemon', icon: Icons.circle, ml: 50, emoji: '🍋', amount: '1 piece'),
        ],
      ),
      Recipe(
        id: '6',
        name: 'Winter Shield',
        totalMlOverride: 200,
        ingredients: [
          Ingredient(name: 'Apple', icon: Icons.circle, ml: 100, emoji: '🍎', amount: '1 piece'),
          Ingredient(name: 'Pear', icon: Icons.circle, ml: 50, emoji: '🍐', amount: '1 piece'),
          Ingredient(name: 'Lemon', icon: Icons.circle, ml: 50, emoji: '🍋', amount: '1/2 piece'),
        ],
      ),
      Recipe(
        id: '7',
        name: 'Golden Shine',
        totalMlOverride: 250,
        ingredients: [
          Ingredient(name: 'Mango', icon: Icons.circle, ml: 150, emoji: '🥭', amount: '1 piece'),
          Ingredient(name: 'Pineapple', icon: Icons.circle, ml: 100, emoji: '🍍', amount: '2 slices'),
        ],
      ),
      Recipe(
        id: '8',
        name: 'Red Power',
        totalMlOverride: 300,
        ingredients: [
          Ingredient(name: 'Watermelon', icon: Icons.circle, ml: 200, emoji: '🍉', amount: '2 pieces'),
          Ingredient(name: 'Strawberry', icon: Icons.circle, ml: 100, emoji: '🍓', amount: '3 pieces'),
        ],
      ),

      // ── Suggestions ──────────────────────────────────────────────────────
      Recipe(
        id: '9',
        name: 'Purple Power',
        totalMlOverride: 200,
        ingredients: [
          Ingredient(name: 'Grape', icon: Icons.circle, ml: 100, emoji: '🍇', amount: '1 piece'),
          Ingredient(name: 'Blueberry', icon: Icons.circle, ml: 100, emoji: '🫐', amount: '1 piece'),
          Ingredient(name: 'Apple', icon: Icons.circle, ml: 50, emoji: '🍎', amount: '1/2 piece'),
        ],
      ),
      Recipe(
        id: '10',
        name: 'Cool Garden',
        totalMlOverride: 250,
        ingredients: [
          Ingredient(name: 'Pear', icon: Icons.circle, ml: 100, emoji: '🍐', amount: '1 piece'),
          Ingredient(name: 'Kiwi', icon: Icons.circle, ml: 100, emoji: '🥝', amount: '1 piece'),
          Ingredient(name: 'Avocado', icon: Icons.circle, ml: 50, emoji: '🥑', amount: '1/2 piece'),
        ],
      ),
      Recipe(
        id: '11',
        name: 'Citrus Blast',
        totalMlOverride: 400,
        ingredients: [
          Ingredient(name: 'Grapefruit', icon: Icons.circle, ml: 200, emoji: '🍊', amount: '1 piece'),
          Ingredient(name: 'Lemon', icon: Icons.circle, ml: 100, emoji: '🍋', amount: '2 pieces'),
          Ingredient(name: 'Orange', icon: Icons.circle, ml: 100, emoji: '🍊', amount: '1 piece'),
        ],
      ),
      Recipe(
        id: '12',
        name: 'Tropical Dream',
        totalMlOverride: 350,
        ingredients: [
          Ingredient(name: 'Mango', icon: Icons.circle, ml: 150, emoji: '🥭', amount: '1 piece'),
          Ingredient(name: 'Coconut', icon: Icons.circle, ml: 100, emoji: '🥥', amount: '1/2 piece'),
          Ingredient(name: 'Pineapple', icon: Icons.circle, ml: 100, emoji: '🍍', amount: '2 slices'),
        ],
      ),
    ];
