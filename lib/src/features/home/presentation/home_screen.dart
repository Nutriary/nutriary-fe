import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_event.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_state.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_bloc.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_event.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_state.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_bloc.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_event.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_state.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_bloc.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_event.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_state.dart';
import 'package:nutriary_fe/src/common_widgets/user_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  Future<void> _onRefresh() async {
    // Trigger refreshes
    final groupState = context.read<GroupBloc>().state;
    context.read<GroupBloc>().add(LoadGroups());
    if (groupState.selectedGroup != null) {
      context.read<FridgeBloc>().add(
        LoadFridgeItems(groupState.selectedGroup!.id),
      );
    }
    // Shopping lists are refreshed via GroupBloc (as they are inside Group)
    // Recipes are global
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const UserDrawer(),
      body: BlocListener<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state.selectedGroup != null) {
            // Load fridge items when group is loaded/selected
            // We can use distinct check to avoid loop, but LoadFridgeItems is safe
            context.read<FridgeBloc>().add(
              LoadFridgeItems(state.selectedGroup!.id),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar & Greeting
              SliverAppBar(
                expandedHeight: 140.0,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Colors.black87,
                title: const Text(
                  'Xin chào!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                flexibleSpace: FlexibleSpaceBar(
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
                  // Notification bell
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),

              // Group & Content
              BlocBuilder<GroupBloc, GroupState>(
                builder: (context, groupState) {
                  if (groupState.status == GroupStatus.loading &&
                      groupState.groups.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final group =
                      groupState.selectedGroup ??
                      (groupState.groups.isNotEmpty
                          ? groupState.groups.first
                          : null);

                  if (group == null) {
                    // No Group State
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_off_rounded,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Bạn chưa có nhóm gia đình',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tạo nhóm để bắt đầu quản lý tủ lạnh và danh sách mua sắm cùng nhau!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 32),
                            FilledButton.icon(
                              onPressed: () {
                                context.read<GroupBloc>().add(
                                  CreateGroup(),
                                ); // Need CreateGroup event? Use dialog logic?
                                // Legacy used ref.read(createGroupProvider).
                                // GroupBloc should handle creation.
                                // Actually, use CreateGroupDialog or similar?
                                // Assuming we add a simple creation event/dialog here.
                                _showCreateGroupDialog(context);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo nhóm mới'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // HAS GROUP -> Show Dashboard
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Summary Cards
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: BlocBuilder<FridgeBloc, FridgeState>(
                                builder: (context, fridgeState) {
                                  String content = '...';
                                  String subContent = '';

                                  if (fridgeState.status ==
                                      FridgeStatus.success) {
                                    content = '${fridgeState.items.length} món';
                                    final expiring = fridgeState.items.where((
                                      i,
                                    ) {
                                      if (i.useWithin == null) return false;
                                      final date = i.useWithin!;
                                      final diff = date
                                          .difference(DateTime.now())
                                          .inDays;
                                      return diff <= 3 && diff >= 0;
                                    }).length;
                                    subContent = expiring > 0
                                        ? '$expiring sắp hết hạn'
                                        : 'Tươi ngon';
                                  } else if (fridgeState.status ==
                                      FridgeStatus.failure) {
                                    content = '0 món';
                                    subContent = 'Lỗi tải';
                                  }

                                  return _buildSummaryCard(
                                    context,
                                    title: 'Tủ lạnh',
                                    icon: Icons.kitchen,
                                    color: Colors.blueAccent,
                                    content: content,
                                    subContent: subContent,
                                    onTap: () => context.go('/tabs/fridge'),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                context,
                                title: 'Đi chợ',
                                icon: Icons.shopping_cart,
                                color: Colors.orangeAccent,
                                content:
                                    '${group.shoppingLists.length} danh sách',
                                subContent: 'Chạm để xem',
                                onTap: () {
                                  _scrollController.animateTo(
                                    500, // Estimated offset
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Featured Recipes
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Gợi ý hôm nay',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.go('/tabs/recipe'),
                              child: const Text('Xem tất cả'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: BlocBuilder<RecipeBloc, RecipeState>(
                          builder: (context, recipeState) {
                            if (recipeState.status == RecipeStatus.loading &&
                                recipeState.recipes.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (recipeState.recipes.isEmpty) {
                              return const Center(
                                child: Text('Chưa có công thức'),
                              );
                            }

                            final featured = recipeState.recipes
                                .take(5)
                                .toList();
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: featured.length,
                              itemBuilder: (context, index) {
                                return _buildRecipeCard(
                                  context,
                                  featured[index],
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Shopping Lists Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Danh sách mua sắm',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                                  builder: (_) =>
                                      _CreateListDialog(groupId: group.id),
                                ).then((result) {
                                  if (result == true) {
                                    context.read<GroupBloc>().add(LoadGroups());
                                  }
                                });
                              },
                            ),
                            if (group.shoppingLists.length > 3)
                              TextButton(
                                onPressed: () =>
                                    context.push('/tabs/home/shopping-lists'),
                                child: const Text('Xem tất cả'),
                              ),
                          ],
                        ),
                      ),

                      // Shopping Lists
                      if (group.shoppingLists.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Chưa có danh sách nào. Hãy tạo mới!'),
                        )
                      else
                        ...group.shoppingLists.take(3).map((list) {
                          return _buildShoppingListTile(context, list);
                        }),

                      if (group.shoppingLists.length > 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: OutlinedButton(
                            onPressed: () =>
                                context.push('/tabs/home/shopping-lists'),
                            child: const Text('Xem thêm danh sách'),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    // Implement standard Create Group Dialog
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo nhóm mới'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Tên nhóm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<GroupBloc>().add(CreateGroup(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
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
    // recipe is dynamic from BLoC? No, it's Recipe entity.
    // recipe['food'] -> recipe.foodName / recipe.imageUrl
    // In Entity: id, name, htmlContent, foodName, imageUrl, foodId.
    return GestureDetector(
      onTap: () => context.go('/tabs/recipe/${recipe.id}', extra: recipe),
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
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
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
                    recipe.name,
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
    // list is ShoppingList entity?
    // In Group Entity, shoppingLists is List<ShoppingList>.
    // Propertoes: id, name, note.
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
          list.name ?? 'Không tên',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Ghi chú: ${list.note ?? 'Không có'}'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          context.go('/tabs/home/shopping-list/${list.id}');
        },
      ),
    );
  }
}

class _CreateListDialog extends StatefulWidget {
  final int? groupId;
  const _CreateListDialog({this.groupId});
  @override
  State<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<_CreateListDialog> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  void _create() {
    if (_nameController.text.isEmpty) return;
    context.read<ShoppingBloc>().add(
      CreateList(
        _nameController.text,
        _noteController.text.isEmpty ? null : _noteController.text,
        widget.groupId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (!state.isLoadingAction && state.errorMessage == null) {
          // Success
          Navigator.pop(context, true);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.errorMessage}')));
        }
      },
      listenWhen: (prev, curr) =>
          (prev.isLoadingAction && !curr.isLoadingAction),
      builder: (context, state) {
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
            FilledButton(
              onPressed: state.isLoadingAction ? null : _create,
              child: state.isLoadingAction
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }
}
