import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../data/static_recipes.dart';

class RecipeProvider extends ChangeNotifier {
  final List<Recipe> _recipes = buildStaticRecipes();

  // Home screen state
  List<Ingredient> selectedIngredients = [];
  int cups = 0;
  String recipeName = '';
  bool isMaking = false;
  bool isDone = false;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favourites => _recipes.where((r) => r.isFavourite).toList();
  List<Recipe> get lastRecipes => _recipes.where((r) => !r.isFavourite).take(4).toList();
  List<Recipe> get suggestions => _recipes.skip(8).toList();

  void toggleFavourite(String id) {
    final recipe = _recipes.firstWhere((r) => r.id == id);
    recipe.isFavourite = !recipe.isFavourite;
    notifyListeners();
  }

  void addIngredient(Ingredient ingredient) {
    selectedIngredients.add(Ingredient(
      name: ingredient.name,
      icon: ingredient.icon,
      ml: ingredient.ml,
    ));
    notifyListeners();
  }

  void removeIngredient(int index) {
    selectedIngredients.removeAt(index);
    notifyListeners();
  }

  void updateMl(int index, int ml) {
    selectedIngredients[index] = selectedIngredients[index].copyWith(ml: ml);
    notifyListeners();
  }

  void startMaking() {
    isMaking = true;
    isDone = false;
    notifyListeners();
  }

  void finishMaking() {
    isMaking = false;
    isDone = true;
    notifyListeners();
  }

  void setCups(int v) {
    cups = v.clamp(0, 20);
    notifyListeners();
  }

  void setRecipeName(String v) {
    recipeName = v;
    notifyListeners();
  }

  void reset() {
    selectedIngredients.clear();
    cups = 0;
    recipeName = '';
    isMaking = false;
    isDone = false;
    notifyListeners();
  }

  int get totalSelectedMl =>
      selectedIngredients.fold(0, (s, i) => s + i.ml);
}
