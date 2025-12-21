import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_bloc.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_event.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_state.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_state.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.selectedGroupId != current.selectedGroupId,
      listener: (context, state) {
        context.read<FridgeBloc>().add(LoadFridgeItems(state.selectedGroupId));
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Tủ lạnh của bạn'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const _AddFridgeItemDialog(),
            );
          },
          label: const Text('Thêm món'),
          icon: const Icon(LucideIcons.plus),
        ),
        body: Column(
          children: [
            // Filter Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BlocBuilder<FridgeBloc, FridgeState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      _buildFilterChip(
                        context,
                        'Tất cả',
                        FridgeFilter.all,
                        isSelected: state.filter == FridgeFilter.all,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        'Sắp hết hạn',
                        FridgeFilter.expiring,
                        isSelected: state.filter == FridgeFilter.expiring,
                        color: Colors.redAccent,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Content
            Expanded(
              child: BlocConsumer<FridgeBloc, FridgeState>(
                listener: (context, state) {
                  if (state.errorMessage != null && !state.isLoadingAction) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == FridgeStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == FridgeStatus.failure) {
                    return Center(child: Text('Lỗi: ${state.errorMessage}'));
                  }

                  final filteredItems = state.filteredItems;

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.snowflake,
                            size: 64,
                            color: Colors.blue[100],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.filter == FridgeFilter.all
                                ? 'Tủ lạnh trống :('
                                : 'Không có gì sắp hỏng!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by Category (UI Logic)
                  final grouped = <String, List<dynamic>>{};
                  for (var item in filteredItems) {
                    final cat = item.categoryName;
                    if (!grouped.containsKey(cat)) grouped[cat] = [];
                    grouped[cat]!.add(item);
                  }

                  final sortedKeys = grouped.keys.toList()..sort();

                  return RefreshIndicator(
                    onRefresh: () async {
                      final groupId = context
                          .read<GroupBloc>()
                          .state
                          .selectedGroupId;
                      context.read<FridgeBloc>().add(LoadFridgeItems(groupId));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final cat = sortedKeys[index];
                        final catItems = grouped[cat]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                cat.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: catItems.length,
                              itemBuilder: (c, i) =>
                                  _buildFridgeItemCard(c, catItems[i], i),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    FridgeFilter value, {
    bool isSelected = false,
    Color? color,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final filterStr = value == FridgeFilter.all ? 'All' : 'Expiring';
          context.read<FridgeBloc>().add(ChangeFilter(filterStr));
        }
      },
      selectedColor:
          color?.withOpacity(0.2) ??
          Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? (color ?? Theme.of(context).colorScheme.primary)
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildFridgeItemCard(BuildContext context, dynamic item, int index) {
    // using dynamic for item b/c I used List<dynamic> in grouping, but actually it is FridgeItem
    final foodName = item.foodName;
    final quantity = item.quantity.toString();
    final imageUrl = item.imageUrl;
    final useWithin = item.useWithin;

    // Calculate Days Left
    int? daysLeft;
    Color statusColor = Colors.green;
    String statusText = 'Tươi';

    if (useWithin != null) {
      final diff = useWithin.difference(DateTime.now()).inDays;
      daysLeft = diff;
      if (diff < 0) {
        statusColor = Colors.grey;
        statusText = 'Hết hạn';
      } else if (diff <= 3) {
        statusColor = Colors.red;
        statusText = '$diff ngày';
      } else if (diff <= 7) {
        statusColor = Colors.orange;
        statusText = '$diff ngày';
      } else {
        statusText = '$diff ngày';
      }
    }

    return GestureDetector(
      onTap: () {
        _showItemActions(context, item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: imageUrl != null
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: Colors.blue[50],
                            child: Icon(
                              LucideIcons.snowflake,
                              size: 40,
                              color: Colors.blue[200],
                            ),
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          foodName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.package,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              quantity,
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
                ),
              ],
            ),
            if (daysLeft != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().scale(delay: (index * 50).ms, duration: 300.ms);
  }

  void _showItemActions(BuildContext context, dynamic item) {
    final groupId = context.read<GroupBloc>().state.selectedGroupId;

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
            const SizedBox(height: 16),
            Text(
              item.foodName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Số lượng: ${item.quantity}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Consume
                _buildActionButton(
                  icon: LucideIcons.utensils,
                  label: 'Sử dụng',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (_) => _ConsumeDialog(item: item),
                    );
                  },
                ),
                // Edit
                _buildActionButton(
                  icon: LucideIcons.edit3,
                  label: 'Sửa',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (_) => _EditFridgeItemDialog(item: item),
                    );
                  },
                ),
                // Delete
                _buildActionButton(
                  icon: LucideIcons.trash2,
                  label: 'Bỏ đi',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<FridgeBloc>().add(
                      RemoveItem(item.foodName, groupId),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã bỏ "${item.foodName}"')),
                    );
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
}

// Consume Dialog
class _ConsumeDialog extends StatefulWidget {
  final dynamic item;
  const _ConsumeDialog({required this.item});
  @override
  State<_ConsumeDialog> createState() => _ConsumeDialogState();
}

class _ConsumeDialogState extends State<_ConsumeDialog> {
  late double _quantity;
  late double _maxQuantity;

  @override
  void initState() {
    super.initState();
    _maxQuantity = double.tryParse(widget.item.quantity.toString()) ?? 1;
    _quantity = _maxQuantity; // Default to consume all
  }

  void _consume() {
    final groupId = context.read<GroupBloc>().state.selectedGroupId;
    context.read<FridgeBloc>().add(
      ConsumeItem(
        foodName: widget.item.foodName,
        quantity: _quantity,
        groupId: groupId,
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sử dụng $_quantity ${widget.item.foodName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(LucideIcons.utensils, color: Colors.green),
          const SizedBox(width: 12),
          const Text('Sử dụng thực phẩm'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.chefHat, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.foodName,
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
          Text('Số lượng sử dụng: ${_quantity.toStringAsFixed(1)}'),
          Slider(
            value: _quantity,
            min: 0.5,
            max: _maxQuantity,
            divisions: (_maxQuantity * 2).toInt(),
            label: _quantity.toStringAsFixed(1),
            activeColor: Colors.green,
            onChanged: (value) => setState(() => _quantity = value),
          ),
          Text(
            'Còn lại: ${(_maxQuantity - _quantity).toStringAsFixed(1)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          onPressed: _consume,
          child: const Text('Sử dụng'),
        ),
      ],
    );
  }
}

class _EditFridgeItemDialog extends StatefulWidget {
  final dynamic item; // FridgeItem
  const _EditFridgeItemDialog({required this.item});
  @override
  State<_EditFridgeItemDialog> createState() => _EditFridgeItemDialogState();
}

class _EditFridgeItemDialogState extends State<_EditFridgeItemDialog> {
  late TextEditingController _qtyController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _selectedDate = widget.item.useWithin;
  }

  Future<void> _save() async {
    final groupId = context.read<GroupBloc>().state.selectedGroupId;
    context.read<FridgeBloc>().add(
      UpdateItem(
        foodName: widget.item.foodName,
        quantity: _qtyController.text,
        useWithin: _selectedDate,
        groupId: groupId,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sửa ${widget.item.foodName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _qtyController,
            decoration: const InputDecoration(
              labelText: 'Số lượng',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _selectedDate ??
                    DateTime.now().add(const Duration(days: 3)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hạn sử dụng',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDate != null
                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                    : 'Chưa đặt',
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}

class _AddFridgeItemDialog extends StatefulWidget {
  const _AddFridgeItemDialog();
  @override
  State<_AddFridgeItemDialog> createState() => _AddFridgeItemDialogState();
}

class _AddFridgeItemDialogState extends State<_AddFridgeItemDialog> {
  final _foodController = TextEditingController();
  final _qtyController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  Future<void> _add() async {
    if (_foodController.text.isEmpty) return;
    final groupId = context.read<GroupBloc>().state.selectedGroupId;

    context.read<FridgeBloc>().add(
      AddItem(
        foodName: _foodController.text,
        quantity: _qtyController.text.isEmpty ? '1' : _qtyController.text,
        useWithin: _selectedDate,
        categoryName: _selectedCategory,
        groupId: groupId,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm vào Tủ lạnh'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodController,
              decoration: const InputDecoration(
                labelText: 'Tên thực phẩm',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Category Dropdown
            BlocBuilder<FridgeBloc, FridgeState>(
              builder: (context, state) {
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: state.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                prefixIcon: Icon(Icons.confirmation_number),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 3)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hạn sử dụng (Tuỳ chọn)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate != null
                      ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                      : 'Chọn ngày',
                ),
              ),
            ),
          ],
        ),
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
