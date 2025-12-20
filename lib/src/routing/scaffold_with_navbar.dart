import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavbar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavbar'));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Use GoRouter's context to check if we can pop
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }

        // Check if we are at the root of the current tab
        // Note: StatefulNavigationShell doesn't expose a simple "canPop" for the branch stack easily without keeping track.
        // But goRouter.canPop() usually handles internal stack.
        // If router cannot pop, we are likely at the root.

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát ứng dụng?'),
            content: const Text(
              'Bạn có chắc chắn muốn thoát khỏi ứng dụng không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          // Allow the system to pop (exit app)
          // We need to temporarily set canPop to true or use SystemNavigator
          // For PopScope, if we want to exit, we can't just return.
          // Since we set canPop: false, we must manually exit if needed.
          // But flutter recommended way is SystemNavigator.pop() or passing the pop.
          if (context.mounted) {
            // SystemNavigator.pop(); is one way, but let's try to let the pop happen?
            // Actually PopScope canPop: false means "block".
            // If we really want to exit, we might need a workaround or key.
            // Simplest for now: SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            // Or 'package:flutter/services.dart';
            Navigator.of(
              context,
            ).pop(); // This acts on the root navigator which might close the app?
            // No, standard way:
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (int index) => _onTap(context, index),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.home),
              selectedIcon: Icon(LucideIcons.home, color: Colors.green),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.snowflake),
              selectedIcon: Icon(LucideIcons.snowflake, color: Colors.blue),
              label: 'Tủ lạnh',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.chefHat),
              selectedIcon: Icon(LucideIcons.chefHat, color: Colors.orange),
              label: 'Công thức',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              selectedIcon: Icon(LucideIcons.calendar, color: Colors.purple),
              label: 'Thực đơn',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
