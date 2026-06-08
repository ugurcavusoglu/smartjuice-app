import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../theme/app_theme.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onMlChanged;

  const IngredientTile({
    super.key,
    required this.ingredient,
    this.onRemove,
    this.onMlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(ingredient.icon, color: kPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(ingredient.name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Row(
            children: [
              _MlButton(
                icon: Icons.remove,
                onPressed: onMlChanged == null
                    ? null
                    : () => onMlChanged!(
                        (ingredient.ml - 50).clamp(50, 500)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${ingredient.ml} ml',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _MlButton(
                icon: Icons.add,
                onPressed: onMlChanged == null
                    ? null
                    : () => onMlChanged!(
                        (ingredient.ml + 50).clamp(50, 500)),
              ),
            ],
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 18, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class _MlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _MlButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kPrimary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
