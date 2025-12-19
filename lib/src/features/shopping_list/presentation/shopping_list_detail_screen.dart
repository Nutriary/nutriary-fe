import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nutriary_fe/src/features/shopping_list/data/shopping_repository.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  final String listId;
  const ShoppingListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState
    extends ConsumerState<ShoppingListDetailScreen> {
  // Local state for optimistic UI updates during dragging
  List<dynamic> _localTasks = [];
  bool _isInit = true;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(shoppingTasksProvider(widget.listId));

    // Initialize local state from provider data once loaded
    ref.listen(shoppingTasksProvider(widget.listId), (previous, next) {
      if (next.hasValue) {
        setState(() {
          _localTasks = List.from(next.value!);
          _isInit = false;
        });
      }
    });

    // If first load and data exists, set it (handle case where listen doesn't fire immediately on first build if cached)
    if (_isInit && tasksAsync.hasValue) {
      _localTasks = List.from(tasksAsync.value!);
      _isInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách mua sắm'),
        actions: [
          // Sort or Filter options could go here
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: tasksAsync.isLoading
              ? const LinearProgressIndicator()
              : const SizedBox(height: 4.0),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => _AddTaskDialog(listId: widget.listId),
          ).then((_) => ref.refresh(shoppingTasksProvider(widget.listId)));
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (_localTasks.isEmpty && !_isInit) {
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
                    onPressed: () =>
                        ref.refresh(shoppingTasksProvider(widget.listId)),
                    child: const Text('Làm mới'),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
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
              _debounce = Timer(const Duration(milliseconds: 1000), () {
                ref.read(shoppingRepositoryProvider).reorderTasks(_localTasks);
              });
            },
            itemBuilder: (context, index) {
              final task = _localTasks[index];
              final id = task['id'];
              final foodName = task['food']?['name'] ?? 'Món lạ';
              final quantity = task['quantity'] ?? '1';
              final imageUrl = task['food']?['foodImageUrl'];

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
                  // Optimistic remove
                  final removedItem = task;
                  setState(() {
                    _localTasks.removeAt(index);
                  });

                  ref
                      .read(shoppingRepositoryProvider)
                      .deleteTask(id)
                      .catchError((e) {
                        // Rollback if failed
                        setState(() {
                          _localTasks.insert(index, removedItem);
                        });
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Lỗi xoá: $e')));
                      });
                },
                child: Container(
                  key: ValueKey(id), // Required for ReorderableListView
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                        image: imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
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
                    title: Text(
                      foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'SL: $quantity',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}

class _AddTaskDialog extends ConsumerStatefulWidget {
  final String listId;
  const _AddTaskDialog({required this.listId});

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _foodController = TextEditingController();
  final _qtyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _add() async {
    if (_foodController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(shoppingRepositoryProvider)
          .addTask(
            int.parse(widget.listId),
            _foodController.text,
            _qtyController.text.isEmpty ? '1' : _qtyController.text,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        setState(() => _isLoading = false);
      }
    }
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
        FilledButton(
          onPressed: _isLoading ? null : _add,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }
}

final shoppingTasksProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, listId) async {
      return ref.read(shoppingRepositoryProvider).getTasks(listId);
    });
