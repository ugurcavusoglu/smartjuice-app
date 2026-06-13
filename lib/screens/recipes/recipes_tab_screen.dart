import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../../providers/recipe_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/recipe.dart';
import '../../models/ingredient.dart';

const _fruitSvg = {
  'Apple': 'assets/fruits/apple.svg',
  'Banana': 'assets/fruits/banana.svg',
  'Orange': 'assets/fruits/orange.svg',
  'Pear': 'assets/fruits/pear.svg',
  'Peach': 'assets/fruits/peach.svg',
  'Cherry': 'assets/fruits/cherry.svg',
  'Strawberry': 'assets/fruits/strawberry.svg',
  'Blueberry': 'assets/fruits/blueberry.svg',
  'Grape': 'assets/fruits/grape.svg',
  'Watermelon': 'assets/fruits/watermelon.svg',
  'Melon': 'assets/fruits/melon.svg',
  'Pineapple': 'assets/fruits/pineapple.svg',
  'Mango': 'assets/fruits/mango.svg',
  'Kiwi': 'assets/fruits/kiwi.svg',
  'Lemon': 'assets/fruits/lemon.svg',
  'Coconut': 'assets/fruits/coconut.svg',
  'Avocado': 'assets/fruits/avocado.svg',
  'Grapefruit': 'assets/fruits/grapefruit.svg',
  'Carrot': 'assets/fruits/apple.svg',
  'Cucumber': 'assets/fruits/avocado.svg',
};

const _tabs = [
  ('Favourites', Icons.favorite),
  ('Last Recipes', Icons.history),
  ('Suggestions', Icons.lightbulb_outline),
];

class RecipesTabScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const RecipesTabScreen({super.key, this.onGoHome});

  @override
  State<RecipesTabScreen> createState() => _RecipesTabScreenState();
}

class _RecipesTabScreenState extends State<RecipesTabScreen> {
  final _pageCtrl = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageCtrl.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final pages = [
      provider.favourites,
      provider.lastRecipes,
      provider.suggestions,
    ];

    final isDark = context.watch<ThemeProvider>().isDark;
    return Scaffold(
      backgroundColor: isDark ? kBgDark : Colors.white,
      body: Column(
        children: [
          // Red AppBar
          Container(
            color: kPrimary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onGoHome,
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tabs[_pageIndex].$1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(_tabs[_pageIndex].$2, color: Colors.white, size: 24),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemCount: 3,
              itemBuilder: (_, i) => _RecipeListPage(
                recipes: pages[i],
                provider: provider,
                onPrev: i > 0 ? () => _goTo(i - 1) : null,
                onNext: i < 2 ? () => _goTo(i + 1) : null,
                onGoHome: widget.onGoHome,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── List page ─────────────────────────────────────────────────────────────

class _RecipeListPage extends StatelessWidget {
  final List<Recipe> recipes;
  final RecipeProvider provider;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onGoHome;

  const _RecipeListPage({
    required this.recipes,
    required this.provider,
    this.onPrev,
    this.onNext,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final chevronBg = isDark ? kBgDark : Colors.white;
    final chevronIcon = isDark ? Colors.white54 : Colors.black54;
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.only(
              left: 16, right: 16, top: 12, bottom: 80),
          itemCount: recipes.length,
          separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.black12),
          itemBuilder: (_, i) => _RecipeCard(
            number: i + 1,
            recipe: recipes[i],
            provider: provider,
            onGoHome: onGoHome,
          ),
        ),
        if (onPrev != null)
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: onPrev,
                child: Container(
                  width: 28, height: 56,
                  decoration: BoxDecoration(
                    color: chevronBg,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12)),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6)],
                  ),
                  child: Icon(Icons.chevron_left, color: chevronIcon, size: 22),
                ),
              ),
            ),
          ),
        if (onNext != null)
          Positioned(
            right: 0, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  width: 28, height: 56,
                  decoration: BoxDecoration(
                    color: chevronBg,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6)],
                  ),
                  child: Icon(Icons.chevron_right, color: chevronIcon, size: 22),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Recipe card ───────────────────────────────────────────────────────────

class _RecipeCard extends StatefulWidget {
  final int number;
  final Recipe recipe;
  final RecipeProvider provider;
  final VoidCallback? onGoHome;

  const _RecipeCard({
    required this.number,
    required this.recipe,
    required this.provider,
    this.onGoHome,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  late int _ml;

  @override
  void initState() {
    super.initState();
    _ml = widget.recipe.totalMl;
  }

  void _openPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => _RecipePopup(
        recipe: widget.recipe,
        provider: widget.provider,
        onConfirm: () {
          Navigator.of(context).pop();
          widget.onGoHome?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final cardBg = isDark ? const Color(0xFF3D1A24) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white70 : Colors.black54;
    final ingColor = isDark ? Colors.white : Colors.black87;
    return TapEffect(
      onTap: _openPopup,
      scale: 0.97,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: kPrimary.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.number}) ${widget.recipe.name} ($_ml ml)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ingredients:',
                  style: TextStyle(fontSize: 13, color: subColor)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: widget.recipe.ingredients.map((ing) {
                final svgPath = _fruitSvg[ing.name];
                final amount = ing.amount.isNotEmpty ? ing.amount : '1 piece';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    svgPath != null
                        ? SvgPicture.asset(svgPath,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                                ingColor, BlendMode.srcIn))
                        : Text(ing.emoji.isNotEmpty ? ing.emoji : '🍹',
                            style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Text('$amount ${ing.name.toLowerCase()}',
                        style: TextStyle(fontSize: 12, color: ingColor)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text('How many ml of fruit juice would you like?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: subColor)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _ml = (_ml - 50).clamp(50, 1000)),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.remove, color: kPrimary, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Text('$_ml ml',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor)),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () =>
                      setState(() => _ml = (_ml + 50).clamp(50, 1000)),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: kPrimary, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recipe popup ──────────────────────────────────────────────────────────

class _RecipePopup extends StatefulWidget {
  final Recipe recipe;
  final RecipeProvider provider;
  final VoidCallback onConfirm;

  const _RecipePopup({
    required this.recipe,
    required this.provider,
    required this.onConfirm,
  });

  @override
  State<_RecipePopup> createState() => _RecipePopupState();
}

class _RecipePopupState extends State<_RecipePopup> {
  late Map<String, int> _counts;

  @override
  void initState() {
    super.initState();
    // Pre-fill counts from recipe ingredients
    _counts = {};
    for (final ing in widget.recipe.ingredients) {
      _counts[ing.name] = (_counts[ing.name] ?? 0) + 1;
    }
  }

  int get _totalSelected => _counts.values.fold(0, (a, b) => a + b);

  void _confirm() {
    widget.provider.reset();
    _counts.forEach((name, count) {
      if (count > 0) {
        final ing = widget.recipe.ingredients
            .firstWhere((i) => i.name == name,
                orElse: () =>
                    Ingredient(name: name, icon: Icons.circle, ml: 100));
        for (var i = 0; i < count; i++) {
          widget.provider.addIngredient(ing);
        }
      }
    });
    widget.provider.setRecipeName(widget.recipe.name);
    widget.provider.confirmFromRecipe();
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    // Build full list: recipe ingredients + any extras not in recipe
    final allNames = widget.recipe.ingredients.map((i) => i.name).toSet().toList();

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: kPrimary.withValues(alpha: 0.35)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.65),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.recipe.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close,
                                color: Colors.white70, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // Ingredient list with counters
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: allNames.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2)),
                        itemBuilder: (_, i) {
                          final name = allNames[i];
                          final ing = widget.recipe.ingredients
                              .firstWhere((x) => x.name == name);
                          final emoji =
                              ing.emoji.isNotEmpty ? ing.emoji : '🍹';
                          final count = _counts[name] ?? 0;
                          return Container(
                            color: Colors.white.withValues(alpha: 0.12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(emoji,
                                      style:
                                          const TextStyle(fontSize: 22)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                ),
                                _CounterBtn(
                                  count: count,
                                  onInc: () => setState(
                                      () => _counts[name] = count + 1),
                                  onDec: () => setState(() =>
                                      _counts[name] =
                                          (count - 1).clamp(0, 99)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Confirm button
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _totalSelected > 0 ? _confirm : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _totalSelected > 0
                                ? Colors.white.withValues(alpha: 0.85)
                                : Colors.white.withValues(alpha: 0.3),
                            foregroundColor: kPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: const Text('Confirm',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _CounterBtn(
      {required this.count, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onInc,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text('$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ),
        GestureDetector(
          onTap: onDec,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.remove, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }
}
