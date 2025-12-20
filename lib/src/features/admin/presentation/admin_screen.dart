import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_bloc.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_event.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_state.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                                icon: LucideIcons.tag,
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
                                icon: LucideIcons.ruler,
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
                                icon: LucideIcons.users,
                                title: 'Người dùng',
                                subtitle: 'Quản lý tài khoản',
                                color: Colors.purple,
                                onTap: () => _showComingSoon(context),
                              )
                              .animate(delay: 250.ms)
                              .fadeIn()
                              .scale(begin: const Offset(0.9, 0.9)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _ActionCard(
                                icon: LucideIcons.settings,
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
                  icon: LucideIcons.userPlus,
                  title: 'Người dùng mới đăng ký',
                  time: 'Hôm nay',
                  color: Colors.green,
                ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2),

                _ActivityCard(
                  icon: LucideIcons.folderPlus,
                  title: 'Danh mục mới được tạo',
                  time: 'Hôm qua',
                  color: Colors.blue,
                ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.2),

                _ActivityCard(
                  icon: LucideIcons.shoppingCart,
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
    );
  }

  Widget _buildStatsOverview(ThemeData theme) {
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
                child: const Icon(
                  LucideIcons.layoutDashboard,
                  color: Colors.white,
                ),
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
                icon: LucideIcons.users,
                value: '--',
                label: 'Người dùng',
              ),
              _StatItem(icon: LucideIcons.users2, value: '--', label: 'Nhóm'),
              _StatItem(
                icon: LucideIcons.chefHat,
                value: '--',
                label: 'Công thức',
              ),
              _StatItem(
                icon: LucideIcons.shoppingBag,
                value: '--',
                label: 'Đơn hàng',
              ),
            ],
          ),
        ],
      ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Đơn vị đo lường',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _UnitChip(label: 'kg', fullName: 'Kilogram'),
                _UnitChip(label: 'g', fullName: 'Gram'),
                _UnitChip(label: 'l', fullName: 'Liter'),
                _UnitChip(label: 'ml', fullName: 'Milliliter'),
                _UnitChip(label: 'cái', fullName: 'Piece'),
                _UnitChip(label: 'bó', fullName: 'Bunch'),
                _UnitChip(label: 'hộp', fullName: 'Box'),
                _UnitChip(label: 'gói', fullName: 'Package'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.construction, color: Colors.white),
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
    return Column(
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
              if (state.status == CategoryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.folderOpen,
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
                              LucideIcons.folder,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
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
            prefixIcon: const Icon(LucideIcons.folder),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final String fullName;

  const _UnitChip({required this.label, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: fullName,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withAlpha(50)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
