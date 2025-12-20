import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_bloc.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_event.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_state.dart';
import 'package:nutriary_fe/src/features/shopping_list/domain/entities/shopping_task.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  final String listId;
  const ShoppingListDetailScreen({super.key, required this.listId});

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  // Local state for optimistic UI updates during dragging
  List<ShoppingTask> _localTasks = [];
  Timer? _debounce;
  final int _debounceDuration = 1000;

  @override
  void initState() {
    super.initState();
    // Dispatch Load Task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingBloc>().add(
        LoadShoppingTasks(int.parse(widget.listId)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách mua sắm'),
        actions: [
          // Sort or Filter options could go here
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: BlocBuilder<ShoppingBloc, ShoppingState>(
            builder: (context, state) {
              return (state.status == ShoppingStatus.loading &&
                      !state.isLoadingAction)
                  ? const LinearProgressIndicator()
                  : const SizedBox(height: 4.0);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => _AddTaskDialog(listId: int.parse(widget.listId)),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
      ),
      body: BlocConsumer<ShoppingBloc, ShoppingState>(
        listenWhen: (previous, current) => previous.tasks != current.tasks,
        listener: (context, state) {
          // Sync local state when BLoC state updates (e.g. initial load or post-refresh)
          // But respect reordering if dragging? Ideally Block source of truth except during drag.
          // For now, simple sync.
          if (state.status == ShoppingStatus.success) {
            setState(() {
              _localTasks = List.from(state.tasks);
            });
          }
        },
        builder: (context, state) {
          if (state.status == ShoppingStatus.loading && _localTasks.isEmpty) {
            // Initial load
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ShoppingStatus.failure && _localTasks.isEmpty) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          if (_localTasks.isEmpty && state.status == ShoppingStatus.success) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.shoppingCart,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Giỏ hàng đang trống',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () => context.read<ShoppingBloc>().add(
                      LoadShoppingTasks(int.parse(widget.listId)),
                    ),
                    child: const Text('Làm mới'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress Bar
              if (_localTasks.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Builder(
                    builder: (context) {
                      final total = _localTasks.length;
                      final done = _localTasks.where((t) => t.isBought).length;
                      final progress = done / total;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã mua: $done/$total',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.green,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 4),
                  itemCount: _localTasks.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _localTasks.removeAt(oldIndex);
                      _localTasks.insert(newIndex, item);
                    });

                    // Debounce API call
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(
                      Duration(milliseconds: _debounceDuration),
                      () {
                        context.read<ShoppingBloc>().add(
                          ReorderShoppingTasks(
                            _localTasks,
                            int.parse(widget.listId),
                          ),
                        );
                      },
                    );
                  },
                  itemBuilder: (context, index) {
                    final task = _localTasks[index];
                    final id = task.id;
                    final foodName = task.foodName;
                    final quantity = task.quantity;
                    final imageUrl = task.imageUrl;
                    final isBought = task.isBought;

                    return Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // Optimistic remove handled by Bloc usually, but here for UI snap:

                        setState(() {
                          _localTasks.removeAt(index);
                        });

                        context.read<ShoppingBloc>().add(
                          DeleteShoppingTask(id, int.parse(widget.listId)),
                        );

                        // Error handling rollback logic is complex with BLoC unless we listen to error state specific to this action.
                        // Implemented in BLoC state listener ideally.
                      },
                      child: Container(
                        key: ValueKey(id), // Required for ReorderableListView
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isBought ? Colors.grey[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isBought
                              ? Border.all(color: Colors.grey[300]!)
                              : null,
                          boxShadow: isBought
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: CheckboxListTile(
                          value: isBought,
                          onChanged: (val) {
                            if (val == null) return;
                            // Optimistic update local
                            setState(() {
                              _localTasks[index] = task.copyWith(isBought: val);
                            });
                            context.read<ShoppingBloc>().add(
                              UpdateShoppingTask(
                                taskId: id,
                                listId: int.parse(widget.listId),
                                isBought: val,
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, // Reduced padding
                            vertical: 4,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: const Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                          title: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: imageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                          colorFilter: isBought
                                              ? const ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.saturation,
                                                )
                                              : null,
                                        )
                                      : null,
                                ),
                                child: imageUrl == null
                                    ? const Icon(
                                        Icons.fastfood,
                                        size: 20,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foodName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        decoration: isBought
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: isBought
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'SL: $quantity',
                                      style: TextStyle(
                                        color: isBought
                                            ? Colors.grey
                                            : Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final int listId;
  const _AddTaskDialog({required this.listId});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _foodController = TextEditingController();
  final _qtyController = TextEditingController();

  Future<void> _add() async {
    if (_foodController.text.isEmpty) return;
    // We can just add event and close. The BLoC handles the loading state.
    // However, if we want to wait for success to close dialog, we need to listen to bloc.
    // For simplicity, fire and forget or let BLoC handle it.
    // Let's close and let background handle it, refreshing the list.
    context.read<ShoppingBloc>().add(
      AddShoppingTask(
        widget.listId,
        _foodController.text,
        _qtyController.text.isEmpty ? '1' : _qtyController.text,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm món mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _foodController,
            decoration: const InputDecoration(
              labelText: 'Tên món (vd: Gà, Bắp cải...)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyController,
            decoration: const InputDecoration(
              labelText: 'Số lượng (vd: 1kg, 2 bó)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
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
