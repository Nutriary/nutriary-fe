import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_state.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_event.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_state.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../../admin/presentation/admin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled =
      true; // Use local state or shared prefs in real app

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.status == UserStatus.loading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == UserStatus.failure) {
            return Center(child: Text('Lỗi: ${state.errorMessage}'));
          }

          final user = state.user;
          // If user is null but not failure? Maybe unauthenticated or empty.
          if (user == null) {
            return const Center(child: Text('Chưa đăng nhập'));
          }

          return ListView(
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
                title: const Text('Đổi mật khẩu'),
                leading: const Icon(Icons.lock_outline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to change password screen or show dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng sắp ra mắt')),
                  );
                },
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
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
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
                subtitle: const Text('Thông báo về hạn sử dụng, gợi ý món ăn'),
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                  // Call API to disable/enable or remove token
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
            ],
          );
        },
      ),
    );
  }
}
