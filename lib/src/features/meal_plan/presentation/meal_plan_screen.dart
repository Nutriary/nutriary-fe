import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_bloc.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_event.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_state.dart';
import 'package:nutriary_fe/src/features/meal_plan/domain/entities/meal_plan.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initial load? Done in main.dart with DateTime.now(), but we might want to ensure _selectedDate is synced.
    // If main.dart loaded with DateTime.now(), we are good.
    // But if we navigate here later, we might need to load.
    context.read<MealPlanBloc>().add(LoadMealPlan(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
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
                context.read<MealPlanBloc>().add(LoadMealPlan(picked));
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
          );
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
            child: BlocBuilder<MealPlanBloc, MealPlanState>(
              builder: (context, state) {
                if (state.status == MealPlanStatus.loading &&
                    state.mealPlans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == MealPlanStatus.failure &&
                    state.mealPlans.isEmpty) {
                  // If error
                  return Center(child: Text('Lỗi: ${state.errorMessage}'));
                }

                if (state.mealPlans.isEmpty &&
                    state.status == MealPlanStatus.success) {
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

                final sortedMeals = List.of(state.mealPlans);
                // Group meals by type manually to order them: Breakfast, Lunch, Dinner, Snack
                final breakfast = _filterMeals(sortedMeals, 'Bữa Sáng');
                final lunch = _filterMeals(sortedMeals, 'Bữa Trưa');
                final dinner = _filterMeals(sortedMeals, 'Bữa Tối');
                final snack = _filterMeals(sortedMeals, 'Bữa Phụ');

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<MealPlanBloc>().add(
                      LoadMealPlan(_selectedDate),
                    );
                  },
                  child: ListView(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuggestionsDialog(BuildContext context) {
    // Trigger load suggestions
    context.read<MealPlanBloc>().add(LoadSuggestions());
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
    );
  }

  List<MealPlan> _filterMeals(List<MealPlan> meals, String type) {
    return meals
        .where((m) => m.mealType.toLowerCase() == type.toLowerCase())
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
    List<MealPlan> meals,
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

  Widget _buildMealCard(MealPlan meal, Color color) {
    final hasImage = meal.foodImageUrl != null && meal.foodImageUrl!.isNotEmpty;

    return GestureDetector(
      onLongPress: () => _showMealOptions(meal, color),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food Image or Icon
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: hasImage
                    ? Image.network(
                        meal.foodImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: color.withOpacity(0.1),
                          child: Icon(
                            LucideIcons.utensils,
                            color: color,
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Icon(
                          LucideIcons.chefHat,
                          color: color,
                          size: 36,
                        ),
                      ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Food Name - prominent
                    Text(
                      meal.foodName.isNotEmpty ? meal.foodName : 'Món ăn',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Meal Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        meal.mealType,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // More Options Button
            PopupMenuButton<String>(
              icon: Icon(LucideIcons.moreVertical, color: Colors.grey[400]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditMealDialog(meal);
                } else if (value == 'delete') {
                  _deleteMeal(meal);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.edit3, size: 18, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                      const SizedBox(width: 12),
                      const Text('Xoá', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
    );
  }

  void _showMealOptions(MealPlan meal, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              meal.foodName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(meal.mealType, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: LucideIcons.edit3,
                  label: 'Sửa',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditMealDialog(meal);
                  },
                ),
                _buildActionButton(
                  icon: LucideIcons.trash2,
                  label: 'Xoá',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteMeal(meal);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showEditMealDialog(MealPlan meal) {
    showDialog(
      context: context,
      builder: (_) => _EditMealDialog(meal: meal, date: _selectedDate),
    );
  }

  void _deleteMeal(MealPlan meal) {
    context.read<MealPlanBloc>().add(DeleteMealPlan(meal.id, _selectedDate));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xoá "${meal.foodName}"'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            // Re-add the meal
            context.read<MealPlanBloc>().add(
              AddMealPlan(
                date: _selectedDate,
                mealType: meal.mealType,
                foodName: meal.foodName,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddMealDialog extends StatefulWidget {
  final DateTime date;
  const _AddMealDialog({required this.date});

  @override
  State<_AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<_AddMealDialog> {
  final _foodController = TextEditingController();
  String _selectedType = 'Bữa Sáng';
  final List<String> _types = ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Bữa Phụ'];

  void _add() {
    if (_foodController.text.isEmpty) return;
    context.read<MealPlanBloc>().add(
      AddMealPlan(
        date: widget.date,
        mealType: _selectedType,
        foodName: _foodController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealPlanBloc, MealPlanState>(
      listenWhen: (prev, curr) => prev.isLoadingAction && !curr.isLoadingAction,
      listener: (context, state) {
        if (state.errorMessage == null) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.errorMessage}')));
        }
      },
      builder: (context, state) {
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
            FilledButton(
              onPressed: state.isLoadingAction ? null : _add,
              child: state.isLoadingAction
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
}

// Edit Meal Dialog
class _EditMealDialog extends StatefulWidget {
  final MealPlan meal;
  final DateTime date;
  const _EditMealDialog({required this.meal, required this.date});

  @override
  State<_EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<_EditMealDialog> {
  late String _selectedType;
  final List<String> _types = ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Bữa Phụ'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.meal.mealType;
  }

  void _save() {
    // Since we don't have UpdateMealPlan event, we'll delete and re-add
    context.read<MealPlanBloc>().add(
      DeleteMealPlan(widget.meal.id, widget.date),
    );
    // Add with new type after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      context.read<MealPlanBloc>().add(
        AddMealPlan(
          date: widget.date,
          mealType: _selectedType,
          foodName: widget.meal.foodName,
        ),
      );
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(LucideIcons.edit3, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          const Text('Chỉnh sửa món'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Name Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.chefHat, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.meal.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chọn bữa ăn:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          // Meal Type Selection
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((type) {
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}

// Improved Suggestions Sheet
class _SuggestionsSheet extends StatelessWidget {
  final DateTime date;
  final ScrollController scrollController;
  const _SuggestionsSheet({required this.date, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealPlanBloc, MealPlanState>(
      builder: (context, state) {
        final suggestions = state.suggestions;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.lightbulb,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gợi ý từ Tủ lạnh',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${suggestions.length} món có thể nấu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: suggestions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.refrigerator,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tủ lạnh trống hoặc chưa có công thức phù hợp',
                              style: TextStyle(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return _buildSuggestionCard(
                            context,
                            suggestion,
                            index,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    String foodName,
    int index,
  ) {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(LucideIcons.chefHat, color: color),
        ),
        title: Text(
          foodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.check, size: 14, color: Colors.green),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Có sẵn nguyên liệu',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: IconButton.filled(
          onPressed: () => _showAddDialog(context, foodName),
          icon: const Icon(LucideIcons.plus, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  void _showAddDialog(BuildContext context, String foodName) {
    final List<String> types = ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Bữa Phụ'];
    final colors = [Colors.orange, Colors.blue, Colors.indigo, Colors.green];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Thêm "$foodName" vào',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: List.generate(types.length, (index) {
                final type = types[index];
                final color = colors[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Close suggestions sheet
                    context.read<MealPlanBloc>().add(
                      AddMealPlan(
                        date: date,
                        mealType: type,
                        foodName: foodName,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm "$foodName" vào $type'),
                        backgroundColor: color,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
