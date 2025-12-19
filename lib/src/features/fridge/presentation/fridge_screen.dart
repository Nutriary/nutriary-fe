import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutriary_fe/src/features/fridge/data/fridge_repository.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen> {
  String _filter = 'All'; // All, Expiring

  @override
  Widget build(BuildContext context) {
    final fridgeAsync = ref.watch(fridgeItemsProvider);

    return Scaffold(
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
          ).then((_) => ref.refresh(fridgeItemsProvider));
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
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Sắp hết hạn',
                  'Expiring',
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: fridgeAsync.when(
              data: (items) {
                // Apply Filter
                final filteredItems = items.where((item) {
                  if (_filter == 'All') return true;
                  if (_filter == 'Expiring') {
                    final useWithin = item['use_within'];
                    if (useWithin == null) return false;
                    final date = DateTime.tryParse(useWithin);
                    if (date == null) return false;
                    final daysLeft = date.difference(DateTime.now()).inDays;
                    return daysLeft <= 3;
                  }
                  return true;
                }).toList();

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
                          _filter == 'All'
                              ? 'Tủ lạnh trống :('
                              : 'Không có gì sắp hỏng!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(fridgeItemsProvider.future),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildFridgeItemCard(context, item, index);
                    },
                  ),
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

  Widget _buildFilterChip(String label, String value, {Color? color}) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
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
    final foodName = item['food']?['name'] ?? 'Món lạ';
    final quantity = item['quantity'] ?? '1';
    final imageUrl = item['food']?['foodImageUrl'];
    final useWithinStr = item['use_within'];

    // Calculate Days Left
    int? daysLeft;
    Color statusColor = Colors.green;
    String statusText = 'Tươi';

    if (useWithinStr != null) {
      final date = DateTime.tryParse(useWithinStr);
      if (date != null) {
        daysLeft = date.difference(DateTime.now()).inDays;
        if (daysLeft < 0) {
          statusColor = Colors.grey;
          statusText = 'Hết hạn';
        } else if (daysLeft <= 3) {
          statusColor = Colors.red;
          statusText = '$daysLeft ngày';
        } else if (daysLeft <= 7) {
          statusColor = Colors.orange;
          statusText = '$daysLeft ngày';
        } else {
          statusText = '$daysLeft ngày';
        }
      }
    }

    return GestureDetector(
      onLongPress: () {
        _showDeleteDialog(context, foodName);
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

  void _showDeleteDialog(BuildContext context, String foodName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá món này?'),
        content: Text('Bạn có muốn bỏ $foodName khỏi tủ lạnh không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(fridgeRepositoryProvider)
                  .removeFridgeItem(foodName)
                  .then((_) {
                    ref.refresh(fridgeItemsProvider);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Đã xoá $foodName')));
                  });
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

class _AddFridgeItemDialog extends ConsumerStatefulWidget {
  const _AddFridgeItemDialog();
  @override
  ConsumerState<_AddFridgeItemDialog> createState() =>
      _AddFridgeItemDialogState();
}

class _AddFridgeItemDialogState extends ConsumerState<_AddFridgeItemDialog> {
  final _foodController = TextEditingController();
  final _qtyController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _add() async {
    if (_foodController.text.isEmpty) return;
    try {
      await ref
          .read(fridgeRepositoryProvider)
          .addFridgeItem(
            _foodController.text,
            _qtyController.text.isEmpty ? '1' : _qtyController.text,
            _selectedDate,
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
      title: const Text('Thêm vào Tủ lạnh'),
      content: Column(
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
          TextField(
            controller: _qtyController,
            decoration: const InputDecoration(
              labelText: 'Số lượng',
              prefixIcon: Icon(Icons.confirmation_number),
              border: OutlineInputBorder(),
            ),
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

final fridgeItemsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(fridgeRepositoryProvider).getFridgeItems();
});
