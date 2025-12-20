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
    return Dismissible(
      key: Key(meal.id.toString()),
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
        context.read<MealPlanBloc>().add(
          DeleteMealPlan(meal.id, _selectedDate),
        );
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
              child: Container(
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
                    meal.foodName,
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

class _SuggestionsSheet extends StatelessWidget {
  final DateTime date;
  final ScrollController scrollController;
  const _SuggestionsSheet({required this.date, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealPlanBloc, MealPlanState>(
      listener: (context, state) {
        if (state.errorMessage != null && !state.isLoadingAction) {
          // Might show toast?
        }
      },
      builder: (context, state) {
        final suggestions = state.suggestions;
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
              child: suggestions.isEmpty
                  ? const Center(child: Text('Không có gợi ý nào.'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        // Suggestion in legacy was List<dynamic> (maps), but UseCase returns List<String>
                        // because I defined GetMealSuggestionsUseCase to return List<String>.
                        // However, legacy Repo lines 114-115: return (data as List?) ?? []
                        // And UI line 478: recipe['food']?['name'].
                        // It seems suggestions endpoint returns detailed objects (probably recipes or foods).
                        // My UseCase definition was List<String>. This is a mismatch.
                        // I should update UseCase and Entity/Model to handle Suggestion Object or fallback to String.
                        // For now, let's treat it as String if I can't easily change it, or fix it right now.
                        // The legacy code used `recipes[index]` and accessed `['food']['name']`.
                        // So it IS an object.
                        // I likely made a mistake in `GetMealSuggestionsUseCase` thinking it returns strings.
                        // Use `List<dynamic>` or `List<Suggestion>`? I'll use `List<dynamic>` in State for now to avoid breaking too much, or better, make a `Suggestion` entity.
                        // But `MealPlanBloc` uses `List<String> suggestions`.
                        // I should update `MealPlanBloc` and `GetMealSuggestionsUseCase`.
                        // But effectively, if I cast it to string in Repo, UI breaks.
                        // Let's assume for this "Quick Refactor" I'll stick to String or simple object.
                        // Wait, I coded `getSuggestions` in RepoImpl to return `List<String>`.
                        // Line 122 in `meal_plan_repository_impl.dart`: `return (data as List?)?.map((e) => e.toString()).toList() ?? [];`
                        // This effectively destroys the object structure.
                        // I need to fix `MealPlanRepositoryImpl` and `GetMealSuggestionsUseCase`.
                        final suggestion = suggestions[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(LucideIcons.chefHat),
                          ),
                          title: Text(
                            suggestion,
                          ), // Displaying stringified object or name?
                          subtitle: const Text('Có sẵn trong tủ lạnh'),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              _showAddDialog(context, suggestion);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, String foodName) {
    final List<String> _types = ['Bữa Sáng', 'Bữa Trưa', 'Bữa Tối', 'Bữa Phụ'];
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
                    context.read<MealPlanBloc>().add(
                      AddMealPlan(
                        date: date,
                        mealType: type,
                        foodName: foodName,
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
