import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_state.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_event.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_state.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_event.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final user = state.user;
          final userName = user?.name ?? 'Người dùng';
          final userEmail = user?.email ?? '';
          final avatarUrl = user?.image;

          // If loading and no user yet, show loading? Or just show placeholders.
          // We can show loading indicator for header.

          return Column(
            children: [
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          backgroundColor: Colors.white,
                          child: avatarUrl == null
                              ? const Icon(
                                  LucideIcons.user,
                                  color: Colors.black87,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Group Switcher
                    BlocBuilder<GroupBloc, GroupState>(
                      builder: (context, state) {
                        if (state.status == GroupStatus.loading) {
                          return const SizedBox(
                            height: 48,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (state.status == GroupStatus.failure) {
                          return const Text(
                            'Lỗi tải nhóm',
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        final groups = state.groups;

                        // Empty state - no groups
                        if (groups.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Bạn chưa có nhóm nào',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showCreateGroupDialog(context),
                                  icon: const Icon(LucideIcons.plus, size: 16),
                                  label: const Text('Tạo nhóm đầu tiên'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Dropdown to select group
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value:
                                      groups.any(
                                        (g) => g.id == state.selectedGroupId,
                                      )
                                      ? state.selectedGroupId
                                      : null,
                                  hint: const Text(
                                    'Chọn nhóm',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  dropdownColor: Colors.grey[900],
                                  isExpanded: true,
                                  icon: const Icon(
                                    LucideIcons.chevronDown,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  items: groups.map<DropdownMenuItem<int>>((g) {
                                    return DropdownMenuItem<int>(
                                      value: g.id,
                                      child: Text(
                                        g.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newId) {
                                    if (newId != null) {
                                      context.read<GroupBloc>().add(
                                        SelectGroup(newId),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Create new group button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showCreateGroupDialog(context),
                                icon: const Icon(LucideIcons.plus, size: 16),
                                label: const Text('Tạo nhóm mới'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(LucideIcons.users),
                        title: const Text('Quản lý Nhóm'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/group-management');
                        },
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.settings),
                        title: const Text('Cài đặt'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/settings');
                        },
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.bell),
                        title: const Text('Thông báo'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/notifications');
                        },
                        trailing:
                            null, // Removed switch, moved to Settings or just link to list
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.barChart2),
                        title: const Text('Thống kê'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/statistics');
                        },
                      ),
                      // Admin menu - only visible for admin users
                      if (state.user?.isAdmin == true)
                        ListTile(
                          leading: const Icon(LucideIcons.shield),
                          title: const Text('Quản trị'),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/admin');
                          },
                        ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          LucideIcons.logOut,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          // Clear user state before logout
                          context.read<UserBloc>().add(ClearUserState());
                          await const FlutterSecureStorage().deleteAll();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showCreateGroupDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tạo nhóm mới'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Tên nhóm',
          hintText: 'Ví dụ: Gia đình, Bạn bè...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.read<GroupBloc>().add(CreateGroup(value.trim()));
            Navigator.of(dialogContext).pop();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              context.read<GroupBloc>().add(CreateGroup(name));
              Navigator.of(dialogContext).pop();
            }
          },
          child: const Text('Tạo'),
        ),
      ],
    ),
  );
}
