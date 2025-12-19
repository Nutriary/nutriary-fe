import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriary_fe/src/features/auth/presentation/login_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:nutriary_fe/src/features/auth/presentation/register_screen.dart';

import 'package:nutriary_fe/src/features/home/presentation/home_screen.dart';

import 'package:nutriary_fe/src/features/shopping_list/presentation/shopping_list_detail_screen.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/fridge_screen.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/recipe_screen.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/meal_plan_screen.dart';

import 'package:nutriary_fe/src/features/splash/presentation/splash_screen.dart';
import 'package:nutriary_fe/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:nutriary_fe/src/routing/scaffold_with_navbar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
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
                      return RecipeDetailScreen(recipe: state.extra);
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
