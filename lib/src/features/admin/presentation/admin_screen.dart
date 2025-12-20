import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/category/presentation/bloc/category_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Quản trị hệ thống')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Text(
            'Quản lý danh mục',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Category management
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(LucideIcons.tag, color: Colors.white),
              ),
              title: const Text('Danh mục thực phẩm'),
              subtitle: const Text('Quản lý các loại thực phẩm'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCategoryManagement(context),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(LucideIcons.ruler, color: Colors.white),
              ),
              title: const Text('Đơn vị đo lường'),
              subtitle: const Text('Quản lý các đơn vị'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showUnitManagement(context),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Thống kê hệ thống',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.users, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Người dùng hoạt động')),
                      const Text(
                        '--',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(LucideIcons.users2, color: Colors.green),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Số nhóm gia đình')),
                      const Text(
                        '--',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(LucideIcons.chefHat, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Công thức được tạo')),
                      const Text(
                        '--',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
            icon: const Icon(LucideIcons.settings),
            label: const Text('Cấu hình hệ thống'),
          ),
        ],
      ),
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) =>
            _CategoryManagementSheet(scrollController: scrollController),
      ),
    );
  }

  void _showUnitManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đơn vị đo lường'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('kg - Kilogram')),
            ListTile(title: Text('g - Gram')),
            ListTile(title: Text('l - Liter')),
            ListTile(title: Text('ml - Milliliter')),
            ListTile(title: Text('cái - Piece')),
            ListTile(title: Text('bó - Bunch')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Danh mục thực phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => _showAddCategoryDialog(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              bloc: getIt<CategoryBloc>(),
              builder: (context, state) {
                if (state.status == CategoryStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.categories.isEmpty) {
                  return const Center(child: Text('Chưa có danh mục'));
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(LucideIcons.folder),
                      ),
                      title: Text(category.name),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Xóa chưa được hỗ trợ'),
                            ),
                          );
                        },
                      ),
                    );
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
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Add create category event
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
