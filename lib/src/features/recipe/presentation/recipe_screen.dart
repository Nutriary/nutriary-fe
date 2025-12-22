import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_bloc.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_event.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_state.dart';
import 'package:nutriary_fe/src/features/recipe/domain/entities/recipe.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String _searchQuery = '';
  String _filterType = 'all'; // all, public, group

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: Colors.orange.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepOrange : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          'Công thức nấu ăn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công thức...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Filter Section
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Tất cả', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Công khai', 'public'),
                const SizedBox(width: 8),
                _buildFilterChip('Nhóm của tôi', 'group'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                if (state.status == RecipeStatus.loading &&
                    state.recipes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == RecipeStatus.failure &&
                    state.recipes.isEmpty) {
                  return Center(
                    child: Text('Lỗi tải dữ liệu: ${state.errorMessage}'),
                  );
                }

                // Client-side filtering
                final filtered = state.recipes.where((r) {
                  // Search Query
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch =
                      r.name.toLowerCase().contains(query) ||
                      (r.foodName ?? '').toLowerCase().contains(query);
                  if (!matchesSearch) return false;

                  // Filter Type
                  if (_filterType == 'public') return r.isPublic;
                  if (_filterType == 'group') {
                    final selectedGroupId = context
                        .read<GroupBloc>()
                        .state
                        .selectedGroupId;
                    return r.groupId == selectedGroupId;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Chưa có công thức nào.'
                              : 'Không tìm thấy kết quả.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        if (_searchQuery.isEmpty)
                          TextButton(
                            onPressed: () => context.read<RecipeBloc>().add(
                              LoadAllRecipes(),
                            ),
                            child: const Text('Tải lại'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<RecipeBloc>().add(LoadAllRecipes()),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Taller card for content
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _RecipeCard(recipe: filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const _AddRecipeDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final foodName = recipe.foodName ?? 'Món lạ';
    final imageUrl = recipe.imageUrl;
    final recipeName = recipe.name;

    return GestureDetector(
      onTap: () {
        context.go('/tabs/recipe/${recipe.id}', extra: recipe);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageUrl != null && imageUrl.isNotEmpty
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
  final dynamic
  recipe; // Can be Recipe entity or JSON map if coming from deep link/legacy?
  // Ideally strictly Recipe entity. But checking 'extra' it might be map if not migrated everywhere.
  // Let's assume Entity or handle map.
  const RecipeDetailScreen({super.key, required this.recipe});

  Recipe get _recipeEntity {
    if (recipe is Recipe) return recipe as Recipe;
    // Fallback if map
    return Recipe(
      id: recipe['id'],
      name: recipe['name'] ?? '',
      htmlContent: recipe['html_content'] ?? recipe['htmlContent'],
      foodName:
          recipe['food_name'] ?? recipe['foodName'] ?? recipe['food']?['name'],
      imageUrl:
          recipe['image_url'] ??
          recipe['imageUrl'] ??
          recipe['food']?['foodImageUrl'],
      foodId:
          recipe['food_id'] ??
          (recipe['food'] != null ? recipe['food']['id'] : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If null check
    if (recipe == null) {
      return const Scaffold(body: Center(child: Text('Recipe not found')));
    }

    final entity = _recipeEntity;
    final name = entity.name;
    final foodName = entity.foodName ?? '';
    final htmlContent = entity.htmlContent ?? '<p>Chưa có hướng dẫn</p>';
    final imageUrl = entity.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(foodName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xoá công thức?'),
                  content: const Text('Hành động này không thể hoàn tác.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Huỷ'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        // Action
                        context.read<RecipeBloc>().add(DeleteRecipe(entity.id));
                        Navigator.pop(ctx); // Close dialog
                        context.pop(); // Go back to list
                      },
                      child: const Text('Xoá'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => _AddRecipeDialog(recipe: entity),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ).animate().fadeIn(),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            HtmlWidget(
              htmlContent,
              textStyle: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecipeDialog extends StatefulWidget {
  final Recipe? recipe;
  const _AddRecipeDialog({this.recipe});

  @override
  State<_AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<_AddRecipeDialog> {
  final _nameController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isPublic = true;
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _foodNameController.text = widget.recipe!.foodName ?? '';
      _contentController.text = widget.recipe!.htmlContent ?? '';
      // Existing recipe editing - currently API doesn't fully support editing visibility easily in UI without more data
      // For now we keep edit simple or assume public.
      _isPublic = widget.recipe!.isPublic;
      _selectedGroupId = widget.recipe!.groupId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.recipe != null;
    final groups = context
        .read<GroupBloc>()
        .state
        .groups; // Assuming joinedGroups or groups

    return BlocConsumer<RecipeBloc, RecipeState>(
      listenWhen: (prev, curr) =>
          (prev.isLoadingAction && !curr.isLoadingAction),
      listener: (context, state) {
        if (state.errorMessage == null && !state.isLoadingAction) {
          Navigator.pop(context); // Close dialog on success
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.errorMessage}')));
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: Text(isEdit ? 'Sửa công thức' : 'Thêm công thức'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _foodNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên món ăn (gắn với thực phẩm)',
                  ),
                  enabled: !isEdit,
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên công thức'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Cách làm (Mỗi bước 1 dòng)',
                    alignLabelWithHint: true,
                    helperText: 'Nhập nội dung, xuống dòng để tách đoạn.',
                  ),
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Công khai (Mọi người đều thấy)'),
                    value: _isPublic,
                    onChanged: (val) {
                      setState(() {
                        _isPublic = val;
                        if (_isPublic) _selectedGroupId = null;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!_isPublic)
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Chọn nhóm'),
                      value: _selectedGroupId,
                      items: groups.map((g) {
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text(g.name),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedGroupId = val),
                      hint: const Text('Chọn nhóm để chia sẻ'),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: state.isLoadingAction
                  ? null
                  : () {
                      final raw = _contentController.text;
                      if (raw.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập cách làm'),
                          ),
                        );
                        return;
                      }
                      final formattedHtml = raw
                          .split('\n')
                          .where((line) => line.trim().isNotEmpty)
                          .map((line) => '<p>${line.trim()}</p>')
                          .join('');

                      if (isEdit) {
                        context.read<RecipeBloc>().add(
                          UpdateRecipe(
                            id: widget.recipe!.id,
                            name: _nameController.text,
                            content: formattedHtml,
                          ),
                        );
                      } else {
                        if (!_isPublic && _selectedGroupId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng chọn nhóm')),
                          );
                          return;
                        }
                        context.read<RecipeBloc>().add(
                          CreateRecipe(
                            name: _nameController.text,
                            foodName: _foodNameController.text,
                            content: formattedHtml,
                            isPublic: _isPublic,
                            groupId: _selectedGroupId,
                          ),
                        );
                      }
                    },
              child: state.isLoadingAction
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      },
    );
  }
}
