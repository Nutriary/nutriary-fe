import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:nutriary_fe/src/features/auth/presentation/auth_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDrawer extends ConsumerWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, fetch user profile from provider
    // For now, mock or read from storage if available
    final userEmail =
        "admin@nutriary.com"; // Placeholder or fetch from provider
    final userName = "Admin User";

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black87),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(LucideIcons.user, color: Colors.black87, size: 30),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail),
          ),
          ListTile(
            leading: const Icon(LucideIcons.settings),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // context.push('/settings'); // Todo: implement settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.bell),
            title: const Text('Thông báo'),
            trailing: Switch(value: true, onChanged: (val) {}), // Mock toggle
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Logout logic
              await const FlutterSecureStorage().deleteAll();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
