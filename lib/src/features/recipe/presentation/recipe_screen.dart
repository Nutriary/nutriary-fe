import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nutriary_fe/src/features/recipe/data/recipe_repository.dart';
import 'package:go_router/go_router.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(allRecipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Công thức')),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('Chưa có công thức nào.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _RecipeCard(recipe: recipe);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final dynamic recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final foodName = recipe['food']?['name'] ?? 'Món lạ';
    final imageUrl = recipe['food']?['foodImageUrl'];
    final recipeName = recipe['name'] ?? foodName;

    return GestureDetector(
      onTap: () {
        context.go('/home/recipe/${recipe['id']}', extra: recipe);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageUrl != null && (imageUrl as String).isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.orange.shade100,
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.orange,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipeName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    foodName,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final dynamic recipe; // Passed via 'extra' or fetched
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // If recipe is null (page refresh), you might fetch it by ID. For now assume passed.
    if (recipe == null)
      return const Scaffold(body: Center(child: Text('Recipe not found')));

    final name = recipe['name'];
    final htmlContent = recipe['html_content'] ?? '<p>No content</p>';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Image if available
            HtmlWidget(
              htmlContent,
              textStyle: const TextStyle(fontSize: 16),
            ).animate().fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

final allRecipesProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(recipeRepositoryProvider).getAllRecipes();
});
