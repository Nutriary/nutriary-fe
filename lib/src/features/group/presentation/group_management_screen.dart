import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_event.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_state.dart';
import '../domain/entities/group_detail.dart';
import '../../user/presentation/bloc/user_bloc.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final _usernameController = TextEditingController();

  Future<void> _addMember() async {
    if (_usernameController.text.isEmpty) return;
    context.read<GroupBloc>().add(AddMember(_usernameController.text));
    _usernameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Nhóm')),
      body: BlocConsumer<GroupBloc, GroupState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = state.groupDetail;
          if (detail == null) {
            // If no group is selected or detail load failed (but no error msg currently)
            // Or maybe selectedGroupId is null
            if (state.selectedGroupId == null) {
              return const Center(child: Text('Bạn chưa chọn nhóm nào.'));
            }
            return const Center(child: Text('Đang tải thông tin nhóm...'));
          }

          final members = detail.members;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add Member Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thêm thành viên',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nhập username của người bạn muốn thêm vào nhóm.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(LucideIcons.userPlus),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton(
                              onPressed:
                                  _addMember, // BLoC handles loading state if we want, or optimistic UI
                              child: const Text('Thêm'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Members List
                const Text(
                  'Danh sách thành viên',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      // Check permissions
                      final userState = context.read<UserBloc>().state;
                      final currentUser = userState.user;
                      final myMember = currentUser != null
                          ? members.firstWhere(
                              (m) => m.userId == currentUser.id,
                              orElse: () => GroupMember(
                                userId: -1,
                                username: '',
                                email: '',
                                role: '',
                              ),
                            )
                          : null;
                      final bool amIAdmin = myMember?.role == 'admin';
                      final bool isMe = member.userId == currentUser?.id;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.username.isEmpty
                                ? '?'
                                : member.username[0].toUpperCase(),
                          ),
                        ),
                        title: Text(member.username),
                        subtitle: Text(member.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                member.role == 'admin'
                                    ? 'Trưởng nhóm'
                                    : 'Thành viên',
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: member.role == 'admin'
                                  ? Colors.orange.shade100
                                  : Colors.grey.shade100,
                            ),
                            if (amIAdmin && !isMe) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                ),
                                tooltip: 'Xoá thành viên',
                                onPressed: () {
                                  // Confirm dialog
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Xác nhận'),
                                      content: Text(
                                        'Bạn có chắc muốn xoá ${member.username} khỏi nhóm?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Huỷ'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            context.read<GroupBloc>().add(
                                              RemoveMember(
                                                detail.id,
                                                member.userId,
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Xoá',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
