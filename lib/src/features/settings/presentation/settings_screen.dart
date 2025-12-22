import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_state.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_event.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_state.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_event.dart';
import '../../admin/presentation/admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _savePrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  void _showEditProfileDialog(BuildContext context, UserState state) {
    if (state.user == null) return;
    final usernameController = TextEditingController(text: state.user!.name);
    final formKey = GlobalKey<FormState>();
    String? pickedImagePath;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Sửa thông tin cá nhân'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() => pickedImagePath = image.path);
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: pickedImagePath != null
                          ? FileImage(File(pickedImagePath!))
                          : (state.user!.image != null &&
                                        state.user!.image!.isNotEmpty
                                    ? NetworkImage(state.user!.image!)
                                    : null)
                                as ImageProvider?,
                      child:
                          (pickedImagePath == null &&
                              (state.user!.image == null ||
                                  state.user!.image!.isEmpty))
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() => pickedImagePath = image.path);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Đổi ảnh'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Tên hiển thị',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập tên';
                      return null;
                    },
                  ),
                ],
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
                    context.read<UserBloc>().add(
                      UpdateUserProfile(
                        username: usernameController.text,
                        imagePath: pickedImagePath,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureOld = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPassController,
                  obscureText: obscureOld,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu cũ',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureOld ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => obscureOld = !obscureOld),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Nhập mật khẩu cũ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) =>
                      v!.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                  ),
                  validator: (v) => v != newPassController.text
                      ? 'Mật khẩu không khớp'
                      : null,
                ),
              ],
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
                  context.read<UserBloc>().add(
                    ChangeUserPassword(
                      oldPassword: oldPassController.text,
                      newPassword: newPassController.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<UserBloc>().add(DeleteUserAccount());
              Navigator.pop(context);
            },
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.isAccountDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tài khoản đã bị xóa')),
            );
            // In a real app, navigate to login here
          }
        },
        builder: (context, state) {
          if (state.status == UserStatus.loading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == UserStatus.failure) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          final user = state.user;
          if (user == null) {
            return const Center(child: Text('Chưa đăng nhập'));
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Tài khoản',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Sửa thông tin cá nhân'),
                    leading: const Icon(Icons.person_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEditProfileDialog(context, state),
                  ),
                  ListTile(
                    title: const Text('Đổi mật khẩu'),
                    leading: const Icon(Icons.lock_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const Divider(),
                  if (user.isAdmin) ...[
                    const Text(
                      'Quản trị hệ thống',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Thống kê tổng quan'),
                      leading: const Icon(Icons.bar_chart),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Giao diện',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  label: Text('Hệ thống'),
                                  icon: Icon(Icons.brightness_auto),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  label: Text('Sáng'),
                                  icon: Icon(Icons.light_mode),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  label: Text('Tối'),
                                  icon: Icon(Icons.dark_mode),
                                ),
                              ],
                              selected: {state.themeMode},
                              onSelectionChanged: (newSelection) {
                                context.read<ThemeBloc>().add(
                                  ChangeThemeMode(newSelection.first),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            title: const Text('Màu chủ đạo'),
                            trailing: DropdownButton<FlexScheme>(
                              value: state.scheme,
                              onChanged: (FlexScheme? newValue) {
                                if (newValue != null) {
                                  context.read<ThemeBloc>().add(
                                    ChangeScheme(newValue),
                                  );
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: FlexScheme.jungle,
                                  child: Text('Rừng xanh (Mặc định)'),
                                ),
                                DropdownMenuItem(
                                  value: FlexScheme.redWine,
                                  child: Text('Vang đỏ'),
                                ),
                                DropdownMenuItem(
                                  value: FlexScheme.blueWhale,
                                  child: Text('Cá voi xanh'),
                                ),
                                DropdownMenuItem(
                                  value: FlexScheme.gold,
                                  child: Text('Vàng kim'),
                                ),
                                DropdownMenuItem(
                                  value: FlexScheme.purpleBrown,
                                  child: Text('Tím'),
                                ),
                                DropdownMenuItem(
                                  value: FlexScheme.sakura,
                                  child: Text('Hoa anh đào'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _notificationsEnabled,
                    title: const Text('Nhận thông báo'),
                    subtitle: const Text(
                      'Thông báo về hạn sử dụng, gợi ý món ăn',
                    ),
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                      _savePrefs(val);
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Ứng dụng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  ListTile(
                    title: const Text('Phiên bản'),
                    trailing: const Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Xóa tài khoản',
                      style: TextStyle(color: Colors.red),
                    ),
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
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
