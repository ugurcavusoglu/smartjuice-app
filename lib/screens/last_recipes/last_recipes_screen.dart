import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/recipe_card.dart';

class LastRecipesScreen extends StatelessWidget {
  const LastRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last Recipes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Consumer<RecipeProvider>(
        builder: (_, provider, __) {
          final recipes = provider.lastRecipes;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: recipes.length,
            itemBuilder: (_, i) => RecipeCard(recipe: recipes[i]),
          );
        },
      ),
    );
  }
}
