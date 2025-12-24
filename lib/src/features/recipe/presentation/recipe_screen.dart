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
import 'package:nutriary_fe/src/features/food/presentation/bloc/food_bloc.dart';
import 'package:nutriary_fe/src/features/food/presentation/bloc/food_event.dart';
import 'package:nutriary_fe/src/features/food/presentation/bloc/food_state.dart';
import 'package:nutriary_fe/src/features/unit/presentation/bloc/unit_bloc.dart';
import 'package:nutriary_fe/src/features/unit/presentation/bloc/unit_event.dart';
import 'package:nutriary_fe/src/features/unit/presentation/bloc/unit_state.dart';

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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const AddRecipeSheet(),
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
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => AddRecipeSheet(recipe: entity),
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

class AddRecipeSheet extends StatefulWidget {
  final Recipe? recipe;
  // initialFoodName for creating from MealPlan flow
  final String? initialFoodName;

  const AddRecipeSheet({super.key, this.recipe, this.initialFoodName});

  @override
  State<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<AddRecipeSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();

  final _instructionController = TextEditingController();

  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController();
  String? _ingUnit;

  final List<Map<String, String>> _ingredients = [];

  bool _isPublic = true;
  int? _selectedGroupId;

  /// Convert HTML content to plain text for editing (instructions only)
  String _htmlToPlainText(String html) {
    String text = html;

    // Remove the entire ingredients section: <h3>Nguyên liệu</h3><ul>...</ul>
    // This regex matches from "Nguyên liệu" header through the closing </ul>
    text = text.replaceAll(
      RegExp(
        r'<h3>Nguyên liệu</h3>\s*<ul>.*?</ul>',
        caseSensitive: false,
        dotAll: true,
      ),
      '',
    );

    // Remove "Cách làm" header (it's auto-generated)
    text = text.replaceAll(
      RegExp(r'<h3>Cách làm</h3>', caseSensitive: false),
      '',
    );

    // Replace <br> and <br/> with newlines
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');

    // Replace </p> with newlines
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');

    // Remove all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    // Decode HTML entities
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');

    // Clean up multiple newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FoodBloc>().add(LoadFoods());
    context.read<UnitBloc>().add(LoadUnits());

    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;

      // Convert HTML to plain text for editing
      _instructionController.text = _htmlToPlainText(
        widget.recipe!.htmlContent ?? '',
      );
      _isPublic = widget.recipe!.isPublic;
      _selectedGroupId = widget.recipe!.groupId;

      // Load existing ingredients
      for (final ing in widget.recipe!.ingredients) {
        _ingredients.add({
          'name': ing.name,
          'qty': ing.quantity.toString(),
          'unit': ing.unit,
        });
      }
    } else if (widget.initialFoodName != null) {
      _nameController.text = widget.initialFoodName!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();

    _instructionController.dispose();
    _ingNameController.dispose();
    _ingQtyController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingNameController.text.isEmpty || _ingQtyController.text.isEmpty) {
      return;
    }
    setState(() {
      _ingredients.add({
        'name': _ingNameController.text,
        'qty': _ingQtyController.text,
        'unit': _ingUnit ?? '',
      });
      _ingNameController.clear();
      _ingQtyController.clear();
      _ingUnit = null;
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  String _buildHtml() {
    final buffer = StringBuffer();
    if (_ingredients.isNotEmpty) {
      buffer.write('<h3>Nguyên liệu</h3><ul>');
      for (final ing in _ingredients) {
        final unitStr = ing['unit']!.isNotEmpty ? ' ${ing['unit']}' : '';
        buffer.write('<li>${ing['name']}: ${ing['qty']}$unitStr</li>');
      }
      buffer.write('</ul>');
    }

    final rawInst = _instructionController.text;
    if (rawInst.isNotEmpty) {
      if (_ingredients.isNotEmpty) {
        buffer.write('<h3>Cách làm</h3>');
      }
      final pTags = rawInst
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => '<p>${l.trim()}</p>')
          .join('');
      buffer.write(pTags);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.recipe != null;
    final groups = context.read<GroupBloc>().state.groups;

    return BlocConsumer<RecipeBloc, RecipeState>(
      listenWhen: (prev, curr) =>
          (prev.isLoadingAction && !curr.isLoadingAction),
      listener: (context, state) {
        if (state.errorMessage == null && !state.isLoadingAction) {
          Navigator.pop(context); // Close modal
          // If editing, also pop the detail screen to go back to refreshed list
          if (widget.recipe != null) {
            Navigator.pop(context); // Pop detail screen
          }
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.errorMessage}')));
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isEdit ? 'Sửa công thức' : 'Thêm công thức',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const Divider(height: 1),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Tiêu đề (VD: Gà rán giòn)',
                                  prefixIcon: Icon(Icons.title, size: 20),
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.deepOrange,
                            unselectedLabelColor: Colors.grey[600],
                            indicatorColor: Colors.deepOrange,
                            tabs: const [
                              Tab(icon: Icon(Icons.list), text: 'Nguyên liệu'),
                              Tab(
                                icon: Icon(Icons.menu_book),
                                text: 'Cách làm',
                              ),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIngredientsTab(),
                      _buildInstructionsTab(groups, isEdit),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: state.isLoadingAction
                            ? null
                            : () {
                                final content = _buildHtml();
                                if (content.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng nhập nội dung'),
                                    ),
                                  );
                                  return;
                                }

                                if (isEdit) {
                                  context.read<RecipeBloc>().add(
                                    UpdateRecipe(
                                      id: widget.recipe!.id,
                                      name: _nameController.text,
                                      content: content,
                                      ingredients: _ingredients,
                                    ),
                                  );
                                } else {
                                  if (!_isPublic && _selectedGroupId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Vui lòng chọn nhóm'),
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<RecipeBloc>().add(
                                    CreateRecipe(
                                      name: _nameController.text,
                                      content: content,
                                      ingredients: _ingredients,
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
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEdit ? 'Lưu Công Thức' : 'Tạo Công Thức'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIngredientsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: BlocBuilder<FoodBloc, FoodState>(
              builder: (context, foodState) {
                final foods = foodState.foods;
                return Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty)
                          return const Iterable<String>.empty();
                        final query = textEditingValue.text.toLowerCase();
                        return foods
                            .where((f) => f.name.toLowerCase().contains(query))
                            .map((f) => f.name);
                      },
                      onSelected: (selection) {
                        _ingNameController.text = selection;
                        try {
                          final f = foods.firstWhere(
                            (x) => x.name == selection,
                          );
                          if (f.unit.isNotEmpty)
                            setState(() => _ingUnit = f.unit);
                        } catch (_) {}
                      },
                      fieldViewBuilder: (ctx, tec, fn, onSub) {
                        if (_ingNameController.text != tec.text)
                          tec.text = _ingNameController.text;
                        return TextField(
                          controller: tec,
                          focusNode: fn,
                          decoration: const InputDecoration(
                            labelText: 'Tên nguyên liệu',
                            hintText: 'Nhập tên thực phẩm...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (v) => _ingNameController.text = v,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _ingQtyController,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng',
                              border: OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: BlocBuilder<UnitBloc, UnitState>(
                            builder: (_, unitState) {
                              var unitNames = unitState.units
                                  .map((u) => u.name)
                                  .toSet()
                                  .toList();

                              if (unitNames.isEmpty) {
                                unitNames = [
                                  'g',
                                  'kg',
                                  'ml',
                                  'l',
                                  'cái',
                                  'quả',
                                  'hộp',
                                  'muỗng',
                                  'thìa',
                                ];
                              }

                              final items = unitNames
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text(n),
                                    ),
                                  )
                                  .toList();
                              return DropdownButtonFormField<String>(
                                value:
                                    _ingUnit != null &&
                                        unitNames.contains(_ingUnit)
                                    ? _ingUnit
                                    : null,
                                items: items,
                                onChanged: (v) => setState(() => _ingUnit = v),
                                decoration: const InputDecoration(
                                  labelText: 'Đơn vị',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addIngredient,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _ingredients.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có nguyên liệu nào',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.separated(
                    itemCount: _ingredients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _ingredients[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                        title: Text(
                          item['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${item['qty']} ${item['unit']}'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeIngredient(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab(List groups, bool isEdit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _instructionController,
            decoration: const InputDecoration(
              labelText: 'Hướng dẫn thực hiện',
              hintText: 'Bước 1: Sơ chế...\nBước 2: Nấu...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 12,
            keyboardType: TextInputType.multiline,
          ),
          if (!isEdit) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Công khai'),
                      subtitle: const Text('Mọi người đều có thể xem'),
                      value: _isPublic,
                      activeColor: Colors.deepOrange,
                      onChanged: (val) {
                        setState(() {
                          _isPublic = val;
                          if (_isPublic) _selectedGroupId = null;
                        });
                      },
                    ),
                    if (!_isPublic)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Chọn nhóm',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedGroupId,
                          items: groups.map<DropdownMenuItem<int>>((g) {
                            return DropdownMenuItem(
                              value: g.id,
                              child: Text(g.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedGroupId = val),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
