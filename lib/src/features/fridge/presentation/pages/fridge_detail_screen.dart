import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/fridge_item.dart';
import '../bloc/fridge_bloc.dart';
import '../bloc/fridge_event.dart';
import '../../../group/presentation/bloc/group_bloc.dart';

class FridgeItemDetailScreen extends StatefulWidget {
  final FridgeItem item;

  const FridgeItemDetailScreen({super.key, required this.item});

  @override
  State<FridgeItemDetailScreen> createState() => _FridgeItemDetailScreenState();
}

class _FridgeItemDetailScreenState extends State<FridgeItemDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _showConsumeDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConsumeDialog(item: widget.item),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã sử dụng ${widget.item.foodName}'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(); // Go back to fridge list
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _EditFridgeItemDialog(item: widget.item),
    );
  }

  void _deleteItem(BuildContext context) {
    final groupId = context.read<GroupBloc>().state.selectedGroupId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bỏ thực phẩm?'),
        content: Text('Bạn có chắc muốn bỏ "${widget.item.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<FridgeBloc>().add(
                RemoveItem(widget.item.foodName, groupId),
              );
              Navigator.pop(ctx); // Close dialog
              context.pop(); // Go back to list
            },
            child: const Text('Bỏ đi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final daysLeft = item.useWithin?.difference(DateTime.now()).inDays;

    // Status Logic
    Color statusColor = Colors.green;
    String statusText = 'Tươi ngon';
    if (daysLeft != null) {
      if (daysLeft < 0) {
        statusColor = Colors.grey;
        statusText = 'Hết hạn';
      } else if (daysLeft <= 3) {
        statusColor = Colors.red;
        statusText = 'Sắp hỏng ($daysLeft ngày)';
      } else if (daysLeft <= 7) {
        statusColor = Colors.orange;
        statusText = 'Cần dùng sớm ($daysLeft ngày)';
      } else {
        statusText = 'Còn $daysLeft ngày';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(item.foodName),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red),
            onPressed: () => _deleteItem(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[100],
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : Icon(
                      LucideIcons.snowflake,
                      size: 80,
                      color: Colors.blue[200],
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.foodName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.categoryName,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantity} ${item.unitName}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Expiry Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendarClock, color: statusColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hạn sử dụng',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.useWithin != null
                                    ? "${item.useWithin!.day}/${item.useWithin!.month}/${item.useWithin!.year}"
                                    : "Chưa đặt hạn",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showEditDialog(context),
                          icon: const Icon(LucideIcons.edit3),
                          label: const Text('Chỉnh sửa'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showConsumeDialog(context),
                          icon: const Icon(LucideIcons.utensils),
                          label: const Text('Sử dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Copy of _ConsumeDialog and _EditFridgeItemDialog from fridge_screen.dart
// Ideally these should be refactored to separate files for reuse, but for now I will define them here
// or import them if I can make them public.
// Since they were private in fridge_screen.dart, I should duplicate them or (better) move them to separate files.
// For expediency, I will duplicate them here but cleaner is to extract them.
// Actually, `FridgeScreen` is in `lib/src/features/fridge/presentation/fridge_screen.dart`.
// If I move them to `widgets/` I can reuse them.

// Let's create `consume_dialog.dart` and `edit_fridge_item_dialog.dart`?
// Or just duplicate for now to avoid refactoring existing file too much (risk of breaking).
// I'll duplicate quickly.

class _ConsumeDialog extends StatefulWidget {
  final FridgeItem item;
  const _ConsumeDialog({required this.item});
  @override
  State<_ConsumeDialog> createState() => _ConsumeDialogState();
}

class _ConsumeDialogState extends State<_ConsumeDialog> {
  late double _quantity;
  late double _maxQuantity;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _maxQuantity = widget.item.quantity.toDouble();
    _quantity = _maxQuantity;
    _textController = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
    // Pop the dialog with result true to signal that consumption happened
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sử dụng thực phẩm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bạn đang dùng ${widget.item.foodName}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 0) {
                    setState(() {
                      _quantity = (_quantity - 1).clamp(0.0, _maxQuantity);
                      _textController.text = _quantity.toStringAsFixed(1);
                    });
                  }
                },
                icon: const Icon(LucideIcons.minus, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _textController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    final v = double.tryParse(val);
                    if (v != null) {
                      setState(() => _quantity = v.clamp(0.0, _maxQuantity));
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  if (_quantity < _maxQuantity) {
                    setState(() {
                      _quantity = (_quantity + 1).clamp(0.0, _maxQuantity);
                      _textController.text = _quantity.toStringAsFixed(1);
                    });
                  }
                },
                icon: const Icon(LucideIcons.plus, color: Colors.green),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tối đa: ${_maxQuantity.toStringAsFixed(1)} ${widget.item.unitName}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(onPressed: _consume, child: const Text('Sử dụng')),
      ],
    );
  }
}

class _EditFridgeItemDialog extends StatefulWidget {
  final FridgeItem item;
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
    // Refresh parent screen? Bloc handles state update.
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
            decoration: const InputDecoration(labelText: 'Số lượng'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Hạn sử dụng'),
              child: Text(
                _selectedDate != null
                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                    : "Chưa đặt",
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
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }
}
