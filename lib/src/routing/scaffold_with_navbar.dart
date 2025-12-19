import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavbar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavbar'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
