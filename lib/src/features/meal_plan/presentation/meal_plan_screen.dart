import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/features/meal_plan/data/meal_plan_repository.dart';

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final mealPlanAsync = ref.watch(mealPlanProvider(_selectedDate));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thực đơn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.lightbulb,
              color: Colors.orange,
            ), // Idea icon
            onPressed: () => _showSuggestionsDialog(context),
          ),
          IconButton(
            icon: const Icon(LucideIcons.calendarDays, color: Colors.black87),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => _AddMealDialog(date: _selectedDate),
          ).then((_) => ref.refresh(mealPlanProvider(_selectedDate)));
        },
        backgroundColor: Colors.black87,
        label: const Text('Thêm món', style: TextStyle(color: Colors.white)),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: mealPlanAsync.when(
              data: (meals) {
                if (meals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.chefHat,
                          size: 64,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có thực đơn.\nLên kế hoạch ngay!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group meals by type manually to order them: Breakfast, Lunch, Dinner, Snack
                final breakfast = _filterMeals(meals, 'Bữa Sáng');
                final lunch = _filterMeals(meals, 'Bữa Trưa');
                final dinner = _filterMeals(meals, 'Bữa Tối');
                final snack = _filterMeals(meals, 'Bữa Phụ');

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  children: [
                    if (breakfast.isNotEmpty)
                      ..._buildTimelineSection(
                        'Bữa Sáng',
                        breakfast,
                        Colors.orange,
                        true,
                      ),
                    if (lunch.isNotEmpty)
                      ..._buildTimelineSection(
                        'Bữa Trưa',
                        lunch,
                        Colors.blue,
                        true,
                      ),
                    if (dinner.isNotEmpty)
                      ..._buildTimelineSection(
                        'Bữa Tối',
                        dinner,
                        Colors.indigo,
                        true,
                      ),
                    if (snack.isNotEmpty)
                      ..._buildTimelineSection(
                        'Bữa Phụ',
                        snack,
                        Colors.green,
                        false,
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuggestionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => _SuggestionsSheet(
          date: _selectedDate,
          scrollController: scrollController,
        ),
      ),
    ).then((_) => ref.refresh(mealPlanProvider(_selectedDate)));
  }

  List<dynamic> _filterMeals(List<dynamic> meals, String type) {
    return meals
        .where(
          (m) => (m['mealType'] as String).toLowerCase() == type.toLowerCase(),
        )
        .toList();
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendarCheck, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            isToday
                ? "Hôm nay, ${_selectedDate.day}/${_selectedDate.month}"
                : "Ngày ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineSection(
    String title,
    List<dynamic> meals,
    Color color,
    bool showLine,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.circle, size: 12, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
      ...meals.asMap().entries.map((entry) {
        final index = entry.key;
        final meal = entry.value;
        final isLast = index == meals.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Line
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 2,
                        color: (isLast && !showLine)
                            ? Colors.transparent
                            : Colors.grey[200],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildMealCard(meal, color),
                ),
              ),
            ],
          ),
        );
      }),
    ];
  }

  Widget _buildMealCard(dynamic meal, Color color) {
    final foodName = meal['food']?['name'] ?? 'Món lạ';
    final imageUrl = meal['food']?['foodImageUrl'];

    return Dismissible(
      key: Key(meal['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(mealPlanRepositoryProvider).deleteMealPlan(meal['id']).then((
          _,
        ) {
          ref.refresh(mealPlanProvider(_selectedDate));
        });
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: color.withOpacity(0.1),
                      child: Icon(LucideIcons.utensils, color: color),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1 phần',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
              onPressed: () {},
            ),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}

class _AddMealDialog extends ConsumerStatefulWidget {
  final DateTime date;
  const _AddMealDialog({required this.date});

  @override
  ConsumerState<_AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends ConsumerState<_AddMealDialog> {
  final _foodController = TextEditingController();
  String _selectedType = 'Bữa Sáng';
  final List<String> _types = ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Bữa Phụ'];

  Future<void> _add() async {
    if (_foodController.text.isEmpty) return;
    try {
      await ref
          .read(mealPlanRepositoryProvider)
          .addMealPlan(widget.date, _selectedType, _foodController.text, null);
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
      title: const Text('Thêm món ăn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
            decoration: const InputDecoration(
              labelText: 'Bữa',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _foodController,
            decoration: const InputDecoration(
              labelText: 'Tên món',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              helperText: 'Nhập chính xác tên món ăn để tìm ảnh',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _add, child: const Text('Thêm')),
      ],
    );
  }
}

class _SuggestionsSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final ScrollController scrollController;
  const _SuggestionsSheet({required this.date, required this.scrollController});

  @override
  ConsumerState<_SuggestionsSheet> createState() => _SuggestionsSheetState();
}

class _SuggestionsSheetState extends ConsumerState<_SuggestionsSheet> {
  final List<String> _types = ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Bữa Phụ'];

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(suggestionsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Gợi ý từ Tủ lạnh',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: suggestionsAsync.when(
            data: (recipes) {
              if (recipes.isEmpty) {
                return const Center(
                  child: Text('Không có gợi ý nào từ tủ lạnh của bạn.'),
                );
              }
              return ListView.builder(
                controller: widget.scrollController,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  final foodName = recipe['food']?['name'] ?? 'Món lạ';
                  final imageUrl = recipe['food']?['foodImageUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null
                          ? const Icon(LucideIcons.chefHat)
                          : null,
                    ),
                    title: Text(foodName),
                    subtitle: const Text('Có sẵn trong tủ lạnh'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        _showAddDialog(context, foodName);
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Lỗi: $e')),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, String foodName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thêm $foodName vào thực đơn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _types
              .map(
                (type) => ListTile(
                  title: Text(type),
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    // Add to meal plan
                    ref
                        .read(mealPlanRepositoryProvider)
                        .addMealPlan(widget.date, type, foodName, null)
                        .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã thêm $foodName vào $type'),
                            ),
                          );
                        });
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

final suggestionsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(mealPlanRepositoryProvider).getSuggestions();
});

final mealPlanProvider = FutureProvider.autoDispose
    .family<List<dynamic>, DateTime>((ref, date) async {
      return ref.read(mealPlanRepositoryProvider).getMealPlan(date);
    });
