import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriary_fe/src/features/group/data/group_repository.dart';
import 'package:nutriary_fe/src/features/shopping_list/data/shopping_repository.dart';
import 'package:nutriary_fe/src/features/fridge/data/fridge_repository.dart';
import 'package:nutriary_fe/src/features/recipe/data/recipe_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(myGroupProvider);
    final fridgeAsync = ref.watch(fridgeSummaryProvider);
    final recipesAsync = ref.watch(featuredRecipesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(myGroupProvider);
          ref.refresh(fridgeSummaryProvider);
          ref.refresh(featuredRecipesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar & Greeting
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: const Text(
                  'Xin chào!',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),

            // Summary Cards (Fridge & Lists)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: 'Tủ lạnh',
                        icon: Icons.kitchen,
                        color: Colors.blueAccent,
                        content: fridgeAsync.when(
                          data: (items) => '${items.length} món',
                          loading: () => '...',
                          error: (_, __) => 'Lỗi',
                        ),
                        subContent: fridgeAsync.when(
                          data: (items) {
                            final expiring = items.where((i) {
                              if (i['useWithin'] == null) return false;
                              final date = DateTime.tryParse(i['useWithin']);
                              if (date == null) return false;
                              final diff = date
                                  .difference(DateTime.now())
                                  .inDays;
                              return diff <= 3 && diff >= 0;
                            }).length;
                            return expiring > 0
                                ? '$expiring sắp hết hạn'
                                : 'Tươi ngon';
                          },
                          loading: () => '',
                          error: (_, __) => '',
                        ),
                        onTap: () => context.go('/tabs/fridge'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        title: 'Đi chợ',
                        icon: Icons.shopping_cart,
                        color: Colors.orangeAccent,
                        content: groupAsync.when(
                          data: (g) =>
                              '${(g?['shoppingLists'] as List? ?? []).length} danh sách',
                          loading: () => '...',
                          error: (_, __) => 'Lỗi',
                        ),
                        subContent: 'Chạm để xem',
                        onTap: () {
                          // Scroll to lists or do nothing specific (lists are below)
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Recipes Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Gợi ý hôm nay',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/tabs/recipe'),
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Recipes List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: recipesAsync.when(
                  data: (recipes) {
                    if (recipes.isEmpty)
                      return const Center(child: Text('Chưa có công thức'));
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _buildRecipeCard(context, recipe);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Lỗi tải món ăn')),
                ),
              ),
            ),

            // Shopping Lists Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Danh sách mua sắm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 28,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const _CreateListDialog(),
                        ).then((_) => ref.refresh(myGroupProvider));
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Shopping Lists
            groupAsync.when(
              data: (group) {
                if (group == null) {
                  return SliverFillRemaining(
                    child: Center(
                      child: FilledButton(
                        onPressed: () {
                          ref.read(createGroupProvider.future).then((_) {
                            ref.refresh(myGroupProvider);
                          });
                        },
                        child: const Text('Tạo nhóm gia đình'),
                      ),
                    ),
                  );
                }
                final lists = (group['shoppingLists'] as List?) ?? [];
                if (lists.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Chưa có danh sách nào. Hãy tạo mới!'),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final list = lists[index];
                    return _buildShoppingListTile(context, list);
                  }, childCount: lists.length),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Lỗi tải nhóm: $e')),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    required String subContent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subContent,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, dynamic recipe) {
    return GestureDetector(
      onTap: () => context.go('/tabs/home/recipe/${recipe['id']}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: recipe['food']?['foodImageUrl'] != null
                    ? Image.network(
                        recipe['food']['foodImageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'] ?? 'Món ngon',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingListTile(BuildContext context, dynamic list) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.list_alt, color: Colors.green),
        ),
        title: Text(
          list['name'] ?? 'Không tên',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Ghi chú: ${list['note'] ?? 'Không có'}'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          context.go('/tabs/home/shopping-list/${list['id']}');
        },
      ),
    );
  }
}

class _CreateListDialog extends ConsumerStatefulWidget {
  const _CreateListDialog();
  @override
  ConsumerState<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends ConsumerState<_CreateListDialog> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  Future<void> _create() async {
    if (_nameController.text.isEmpty) return;
    try {
      await ref
          .read(shoppingRepositoryProvider)
          .createList(
            _nameController.text,
            _noteController.text.isEmpty ? null : _noteController.text,
            null,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Danh sách mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên danh sách',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _create, child: const Text('Tạo')),
      ],
    );
  }
}

// Logic Providers
final myGroupProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(groupRepositoryProvider).getMyGroup();
});

final createGroupProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(groupRepositoryProvider).createGroup();
});

final fridgeSummaryProvider = FutureProvider.autoDispose((ref) async {
  // Fetch fridge items for summary stats
  return ref.read(fridgeRepositoryProvider).getFridgeItems();
});

final featuredRecipesProvider = FutureProvider.autoDispose((ref) async {
  // Fetch all recipes and take top 5
  final recipes = await ref.read(recipeRepositoryProvider).getAllRecipes();
  return recipes.take(5).toList();
});
