import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_bloc.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_event.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_state.dart';
import 'package:nutriary_fe/src/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:nutriary_fe/src/features/admin/presentation/bloc/admin_event.dart';
import 'package:nutriary_fe/src/features/admin/presentation/bloc/admin_state.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'package:nutriary_fe/src/features/unit/presentation/bloc/unit_bloc.dart';
import 'package:nutriary_fe/src/features/unit/presentation/bloc/unit_event.dart';
import 'package:nutriary_fe/src/features/unit/presentation/bloc/unit_state.dart';
import 'package:nutriary_fe/src/features/unit/domain/entities/unit.dart';
import '../../food/presentation/pages/food_management_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late AdminBloc _adminBloc;

  @override
  void initState() {
    super.initState();
    _adminBloc = getIt<AdminBloc>()..add(LoadAdminStats());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _adminBloc,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Quản trị hệ thống'),
              floating: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Overview
                  _buildStatsOverview(
                    theme,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quản lý dữ liệu',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _ActionCard(
                                  icon: Icons.label,
                                  title: 'Danh mục',
                                  subtitle: 'Quản lý loại thực phẩm',
                                  color: Colors.blue,
                                  onTap: () => _showCategoryManagement(context),
                                )
                                .animate(delay: 150.ms)
                                .fadeIn()
                                .scale(begin: const Offset(0.9, 0.9)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            _ActionCard(
                                  icon: Icons.straighten,
                                  title: 'Đơn vị',
                                  subtitle: 'Đơn vị đo lường',
                                  color: Colors.green,
                                  onTap: () => _showUnitManagement(context),
                                )
                                .animate(delay: 200.ms)
                                .fadeIn()
                                .scale(begin: const Offset(0.9, 0.9)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _ActionCard(
                                  icon: Icons.people,
                                  title: 'Người dùng',
                                  subtitle: 'Quản lý tài khoản',
                                  color: Colors.purple,
                                  onTap: () => _showUserManagement(context),
                                )
                                .animate(delay: 250.ms)
                                .fadeIn()
                                .scale(begin: const Offset(0.9, 0.9)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            _ActionCard(
                                  icon: Icons.settings,
                                  title: 'Cấu hình',
                                  subtitle: 'Cài đặt hệ thống',
                                  color: Colors.orange,
                                  onTap: () => _showComingSoon(context),
                                )
                                .animate(delay: 300.ms)
                                .fadeIn()
                                .scale(begin: const Offset(0.9, 0.9)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity
                  Text(
                    'Hoạt động gần đây',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 16),

                  _ActivityCard(
                    icon: Icons.person_add,
                    title: 'Người dùng mới đăng ký',
                    time: 'Hôm nay',
                    color: Colors.green,
                  ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2),

                  _ActivityCard(
                    icon: Icons.create_new_folder,
                    title: 'Danh mục mới được tạo',
                    time: 'Hôm qua',
                    color: Colors.blue,
                  ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.2),

                  _ActivityCard(
                    icon: Icons.shopping_cart,
                    title: 'Đơn hàng mới được hoàn thành',
                    time: '2 ngày trước',
                    color: Colors.orange,
                  ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.2),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(ThemeData theme) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final stats = state.stats;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withAlpha(200),
                theme.colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tổng quan hệ thống',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _StatItem(
                    icon: Icons.people,
                    value: state.status == AdminStatus.loading
                        ? '...'
                        : '${stats?.users ?? 0}',
                    label: 'Người dùng',
                  ),
                  _StatItem(
                    icon: Icons.group,
                    value: state.status == AdminStatus.loading
                        ? '...'
                        : '${stats?.groups ?? 0}',
                    label: 'Nhóm',
                  ),
                  _StatItem(
                    icon: Icons.restaurant_menu,
                    value: state.status == AdminStatus.loading
                        ? '...'
                        : '${stats?.recipes ?? 0}',
                    label: 'Công thức',
                  ),
                  _StatItem(
                    icon: Icons.shopping_bag,
                    value: state.status == AdminStatus.loading
                        ? '...'
                        : '${stats?.shoppingLists ?? 0}',
                    label: 'Đơn hàng',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add Food Management Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodManagementScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  icon: const Icon(Icons.fastfood),
                  label: const Text('Quản lý thực phẩm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryManagement(BuildContext context) {
    final bloc = getIt<CategoryBloc>()..add(LoadCategories());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _CategoryManagementSheet(scrollController: scrollController),
          ),
        ),
      ),
    );
  }

  void _showUnitManagement(BuildContext context) {
    final bloc = getIt<UnitBloc>()..add(LoadUnits());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _UnitManagementSheet(scrollController: scrollController),
          ),
        ),
      ),
    );
  }

  void _showUserManagement(BuildContext context) {
    _adminBloc.add(LoadAdminUsers());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _adminBloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (ctx, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Quản lý người dùng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      if (state.status == AdminStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.users.isEmpty) {
                        return const Center(child: Text('Không có người dùng'));
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.purple.withAlpha(
                                        30,
                                      ),
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            user.email,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final newRole = user.role == 'ADMIN'
                                            ? 'USER'
                                            : 'ADMIN';
                                        _adminBloc.add(
                                          UpdateUserRole(
                                            userId: user.id,
                                            role: newRole,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: user.role == 'ADMIN'
                                              ? Colors.purple.withAlpha(30)
                                              : Colors.grey.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          user.role,
                                          style: TextStyle(
                                            color: user.role == 'ADMIN'
                                                ? Colors.purple
                                                : Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              'Xóa người dùng?',
                                            ),
                                            content: Text(
                                              'Bạn có chắc muốn xóa "${user.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Hủy'),
                                              ),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _adminBloc.add(
                                                    DeleteUser(user.id),
                                                  );
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text('Xóa'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                              .animate(
                                delay: Duration(milliseconds: 50 * index),
                              )
                              .fadeIn()
                              .slideX(begin: 0.1);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Tính năng đang phát triển'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final Color color;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class _CategoryManagementSheet extends StatelessWidget {
  final ScrollController scrollController;

  const _CategoryManagementSheet({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (!state.isLoadingAction && state.errorMessage == null) {
          // If action successful (and not loading), maybe show success?
          // Since we reload list, it's fine.
          // Navigator pop is handled by dialogs usually.
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Danh mục thực phẩm',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state.status == CategoryStatus.loading &&
                    state.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text('Chưa có danh mục nào'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditCategoryDialog(context, category);
                                } else if (value == 'delete') {
                                  _confirmDeleteCategory(context, category);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa tên'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn()
                        .slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Tên danh mục',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.folder),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CategoryBloc>().add(
                  CreateCategory(controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa danh mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Tên danh mục',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.edit),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty &&
                  controller.text != category.name) {
                context.read<CategoryBloc>().add(
                  UpdateCategory(category.name, controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(category.name));
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _UnitManagementSheet extends StatelessWidget {
  final ScrollController scrollController;

  const _UnitManagementSheet({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Đơn vị đo lường',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddUnitDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<UnitBloc, UnitState>(
              builder: (context, state) {
                if (state.status == UnitStatus.loading && state.units.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.units.isEmpty) {
                  return const Center(child: Text('Chưa có đơn vị nào'));
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.units.length,
                  itemBuilder: (context, index) {
                    final unit = state.units[index];
                    return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.straighten,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(
                              unit.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditUnitDialog(context, unit);
                                } else if (value == 'delete') {
                                  _confirmDeleteUnit(context, unit);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa tên'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn()
                        .slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm đơn vị'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Tên đơn vị',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<UnitBloc>().add(CreateUnit(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditUnitDialog(BuildContext context, UnitEntity unit) {
    final controller = TextEditingController(text: unit.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa đơn vị'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Tên đơn vị',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != unit.name) {
                context.read<UnitBloc>().add(
                  UpdateUnit(unit.name, controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUnit(BuildContext context, UnitEntity unit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đơn vị "${unit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<UnitBloc>().add(DeleteUnit(unit.name));
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
