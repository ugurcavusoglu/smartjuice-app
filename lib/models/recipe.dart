import 'ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final int? totalMlOverride;
  bool isFavourite;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    this.isFavourite = false,
    this.totalMlOverride,
  });

  int get totalMl => totalMlOverride ?? ingredients.fold(0, (sum, i) => sum + i.ml);
}
