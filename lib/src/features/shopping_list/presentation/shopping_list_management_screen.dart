import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_state.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_bloc.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_event.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_event.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_state.dart';

class ShoppingListManagementScreen extends StatefulWidget {
  const ShoppingListManagementScreen({super.key});

  @override
  State<ShoppingListManagementScreen> createState() =>
      _ShoppingListManagementScreenState();
}

class _ShoppingListManagementScreenState
    extends State<ShoppingListManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh sách mua sắm')),
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, groupState) {
          final group =
              groupState.selectedGroup ??
              (groupState.groups.isNotEmpty ? groupState.groups.first : null);

          if (group == null) {
            return const Center(child: Text('Chưa có nhóm nào.'));
          }

          if (group.shoppingLists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.playlist_remove,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Chưa có danh sách nào'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showCreateListDialog(context, group.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo danh sách'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: group.shoppingLists.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final list = group.shoppingLists[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.5),
                    child: Icon(
                      Icons.shopping_cart,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: list.note != null && list.note!.isNotEmpty
                      ? Text(list.note!)
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/tabs/home/shopping-list/${list.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          final group =
              state.selectedGroup ??
              (state.groups.isNotEmpty ? state.groups.first : null);
          if (group == null) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showCreateListDialog(context, group.id),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, int groupId) {
    showDialog(
      context: context,
      builder: (_) => _CreateListDialog(groupId: groupId),
    ).then((result) {
      if (result == true) {
        // Refresh groups to see new list
        context.read<GroupBloc>().add(LoadGroups());
      }
    });
  }
}

class _CreateListDialog extends StatefulWidget {
  final int groupId;
  const _CreateListDialog({required this.groupId});
  @override
  State<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<_CreateListDialog> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  void _create() {
    if (_nameController.text.isEmpty) return;
    context.read<ShoppingBloc>().add(
      CreateList(
        _nameController.text,
        _noteController.text.isEmpty ? null : _noteController.text,
        widget.groupId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShoppingBloc, ShoppingState>(
      listener: (context, state) {
        if (!state.isLoadingAction && state.errorMessage == null) {
          Navigator.pop(context, true);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.errorMessage}')));
        }
      },
      listenWhen: (prev, curr) =>
          (prev.isLoadingAction && !curr.isLoadingAction),
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Danh sách mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh sách',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
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
              onPressed: state.isLoadingAction ? null : _create,
              child: state.isLoadingAction
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }
}
