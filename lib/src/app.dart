import 'package:flutter/material.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'package:nutriary_fe/src/routing/app_router.dart';
import 'package:nutriary_fe/src/theme/app_theme.dart';
import 'package:nutriary_fe/src/features/notification/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:nutriary_fe/src/features/settings/presentation/bloc/theme_state.dart';

import 'package:nutriary_fe/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nutriary_fe/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_event.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_bloc.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_event.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_bloc.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_event.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_bloc.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_event.dart';
import 'package:nutriary_fe/src/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:nutriary_fe/src/features/notification/presentation/bloc/notification_event.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_event.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<NotificationService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.read<UserBloc>().add(LoadUserProfile());
          context.read<GroupBloc>().add(LoadGroups());
          context.read<FridgeBloc>().add(LoadCategories());
          context.read<RecipeBloc>().add(LoadAllRecipes());
          context.read<MealPlanBloc>().add(LoadMealPlan(DateTime.now()));
          context.read<NotificationBloc>().add(LoadNotifications());
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: appRouter.router,
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'nutriary_fe',
            onGenerateTitle: (context) => 'Nutriary',
            theme: AppTheme.lightTheme(scheme: state.scheme),
            darkTheme: AppTheme.darkTheme(scheme: state.scheme),
            themeMode: state.themeMode,
          );
        },
      ),
    );
  }
}
