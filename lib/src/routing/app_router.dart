import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'package:nutriary_fe/src/features/auth/presentation/login_screen.dart';
import 'package:nutriary_fe/src/features/auth/presentation/register_screen.dart';
import 'package:nutriary_fe/src/features/home/presentation/home_screen.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/shopping_list_detail_screen.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/fridge_screen.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/recipe_screen.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/meal_plan_screen.dart';
import 'package:nutriary_fe/src/features/group/presentation/group_management_screen.dart';
import 'package:nutriary_fe/src/features/settings/presentation/settings_screen.dart';
import 'package:nutriary_fe/src/features/notification/presentation/notification_screen.dart';
import 'package:nutriary_fe/src/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:nutriary_fe/src/features/notification/presentation/bloc/notification_event.dart';
import 'package:nutriary_fe/src/features/splash/presentation/splash_screen.dart';
import 'package:nutriary_fe/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:nutriary_fe/src/features/statistics/presentation/statistics_screen.dart';
import 'package:nutriary_fe/src/features/admin/presentation/admin_screen.dart';
import 'package:nutriary_fe/src/routing/scaffold_with_navbar.dart';
import 'package:nutriary_fe/src/features/recipe/domain/entities/recipe.dart';

@lazySingleton
class AppRouter {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/group-management',
        builder: (context, state) => const GroupManagementScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<NotificationBloc>()..add(LoadNotifications()),
          child: const NotificationScreen(),
        ),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      // Stateful Nested Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavbar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home (Shopping)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tabs/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'shopping-list/:id',
                    builder: (context, state) => ShoppingListDetailScreen(
                      listId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: Fridge
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tabs/fridge',
                builder: (context, state) => const FridgeScreen(),
              ),
            ],
          ),
          // Tab 3: Recipes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tabs/recipe',
                builder: (context, state) => const RecipeListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      return RecipeDetailScreen(recipe: state.extra as Recipe?);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Tab 4: Meal Plan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tabs/meal-plan',
                builder: (context, state) => const MealPlanScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
