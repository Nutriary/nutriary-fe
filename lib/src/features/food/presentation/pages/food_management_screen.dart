import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import '../../domain/entities/food.dart';

class FoodManagementScreen extends StatelessWidget {
  const FoodManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FoodBloc>()..add(LoadFoods()),
      child: const _FoodManagementView(),
    );
  }
}

class _FoodManagementView extends StatelessWidget {
  const _FoodManagementView();

  void _showAddEditFoodDialog(BuildContext context, {Food? food}) {
    final isEditing = food != null;
    final nameController = TextEditingController(text: food?.name);
    final categoryController = TextEditingController(text: food?.category);
    final unitController = TextEditingController(text: food?.unit);
    File? selectedImage;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Sửa thực phẩm' : 'Thêm thực phẩm'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          selectedImage = File(image.path);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : (food?.imageUrl != null
                                ? NetworkImage(food!.imageUrl!) as ImageProvider
                                : null),
                      child: (selectedImage == null && food?.imageUrl == null)
                          ? const Icon(Icons.add_a_photo)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên thực phẩm',
                    ),
                    enabled:
                        !isEditing, // Assuming name is ID and cannot be changed
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Danh mục'),
                    validator: (v) =>
                        v!.isEmpty ? 'Vui lòng nhập danh mục' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Đơn vị tính'),
                    validator: (v) =>
                        v!.isEmpty ? 'Vui lòng nhập đơn vị' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final bloc = context.read<FoodBloc>();
                  if (isEditing) {
                    bloc.add(
                      UpdateFood(
                        name: nameController.text,
                        newCategory: categoryController.text,
                        newUnit: unitController.text,
                        image: selectedImage,
                      ),
                    );
                  } else {
                    bloc.add(
                      CreateFood(
                        name: nameController.text,
                        category: categoryController.text,
                        unit: unitController.text,
                        image: selectedImage,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa thực phẩm?'),
        content: Text('Bạn có chắc muốn xóa "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<FoodBloc>().add(DeleteFood(name));
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thực phẩm')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditFoodDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<FoodBloc, FoodState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FoodStatus.loading && state.foods.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FoodStatus.failure && state.foods.isEmpty) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          if (state.foods.isEmpty) {
            return const Center(child: Text('Chưa có thực phẩm nào'));
          }

          return Stack(
            children: [
              ListView.builder(
                itemCount: state.foods.length,
                itemBuilder: (context, index) {
                  final food = state.foods[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: food.imageUrl != null
                          ? NetworkImage(food.imageUrl!)
                          : null,
                      child: food.imageUrl == null
                          ? Text(food.name[0].toUpperCase())
                          : null,
                    ),
                    title: Text(food.name),
                    subtitle: Text('${food.category} - ${food.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showAddEditFoodDialog(context, food: food),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, food.name),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (state.isLoadingAction)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
