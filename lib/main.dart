import 'package:flutter/material.dart';
import 'package:nutriary_fe/src/app.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutriary_fe/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nutriary_fe/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_bloc.dart';
import 'package:nutriary_fe/src/features/group/presentation/bloc/group_event.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_bloc.dart';
import 'package:nutriary_fe/src/features/fridge/presentation/bloc/fridge_event.dart';
import 'package:nutriary_fe/src/features/shopping_list/presentation/bloc/shopping_bloc.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_bloc.dart';
import 'package:nutriary_fe/src/features/recipe/presentation/bloc/recipe_event.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_bloc.dart';
import 'package:nutriary_fe/src/features/meal_plan/presentation/bloc/meal_plan_event.dart';
import 'package:nutriary_fe/src/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:nutriary_fe/src/features/notification/presentation/bloc/notification_event.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:nutriary_fe/src/features/user/presentation/bloc/user_event.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  configureDependencies();

  try {
    // If you have generated firebase_options.dart, import and use it:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase init failed (likely missing config): $e");
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => getIt<GroupBloc>()..add(LoadGroups())),
        BlocProvider(create: (_) => getIt<FridgeBloc>()..add(LoadCategories())),
        BlocProvider(create: (_) => getIt<ShoppingBloc>()),
        BlocProvider(create: (_) => getIt<RecipeBloc>()..add(LoadAllRecipes())),
        BlocProvider(
          create: (_) =>
              getIt<MealPlanBloc>()..add(LoadMealPlan(DateTime.now())),
        ),
        BlocProvider(
          create: (_) => getIt<NotificationBloc>()..add(LoadNotifications()),
        ),
        BlocProvider(create: (_) => getIt<UserBloc>()..add(LoadUserProfile())),
      ],
      child: const MyApp(),
    ),
  );
}
