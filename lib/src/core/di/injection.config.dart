// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/admin/data/datasources/admin_remote_data_source.dart'
    as _i517;
import '../../features/admin/data/repositories/admin_repository_impl.dart'
    as _i335;
import '../../features/admin/domain/repositories/admin_repository.dart'
    as _i583;
import '../../features/admin/domain/usecases/get_admin_users_usecase.dart'
    as _i695;
import '../../features/admin/domain/usecases/get_system_stats_usecase.dart'
    as _i307;
import '../../features/admin/domain/usecases/update_user_role_usecase.dart'
    as _i179;
import '../../features/admin/presentation/bloc/admin_bloc.dart' as _i55;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/auth_usecases.dart' as _i46;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/category/data/repositories/category_repository_impl.dart'
    as _i528;
import '../../features/category/domain/repositories/category_repository.dart'
    as _i869;
import '../../features/category/domain/usecases/get_categories_usecase.dart'
    as _i125;
import '../../features/category/presentation/bloc/category_bloc.dart' as _i292;
import '../../features/fridge/data/repositories/fridge_repository_impl.dart'
    as _i986;
import '../../features/fridge/domain/repositories/fridge_repository.dart'
    as _i201;
import '../../features/fridge/domain/usecases/get_fridge_items_usecase.dart'
    as _i404;
import '../../features/fridge/domain/usecases/manage_fridge_items_usecase.dart'
    as _i326;
import '../../features/fridge/presentation/bloc/fridge_bloc.dart' as _i742;
import '../../features/group/data/datasources/group_remote_data_source.dart'
    as _i148;
import '../../features/group/data/repositories/group_repository_impl.dart'
    as _i959;
import '../../features/group/domain/repositories/group_repository.dart'
    as _i702;
import '../../features/group/domain/usecases/add_member_usecase.dart' as _i998;
import '../../features/group/domain/usecases/create_group_usecase.dart'
    as _i382;
import '../../features/group/domain/usecases/get_group_detail_usecase.dart'
    as _i742;
import '../../features/group/domain/usecases/get_groups_usecase.dart' as _i316;
import '../../features/group/domain/usecases/remove_member_usecase.dart'
    as _i909;
import '../../features/group/presentation/bloc/group_bloc.dart' as _i845;
import '../../features/meal_plan/data/repositories/meal_plan_repository_impl.dart'
    as _i314;
import '../../features/meal_plan/domain/repositories/meal_plan_repository.dart'
    as _i952;
import '../../features/meal_plan/domain/usecases/meal_plan_usecases.dart'
    as _i381;
import '../../features/meal_plan/presentation/bloc/meal_plan_bloc.dart'
    as _i642;
import '../../features/notification/data/repositories/notification_repository_impl.dart'
    as _i407;
import '../../features/notification/domain/repositories/notification_repository.dart'
    as _i630;
import '../../features/notification/domain/usecases/notification_usecases.dart'
    as _i312;
import '../../features/notification/notification_service.dart' as _i617;
import '../../features/notification/presentation/bloc/notification_bloc.dart'
    as _i29;
import '../../features/recipe/data/repositories/recipe_repository_impl.dart'
    as _i514;
import '../../features/recipe/domain/repositories/recipe_repository.dart'
    as _i76;
import '../../features/recipe/domain/usecases/recipe_usecases.dart' as _i347;
import '../../features/recipe/presentation/bloc/recipe_bloc.dart' as _i662;
import '../../features/settings/presentation/bloc/theme_bloc.dart' as _i930;
import '../../features/shopping_list/data/repositories/shopping_repository_impl.dart'
    as _i249;
import '../../features/shopping_list/domain/repositories/shopping_repository.dart'
    as _i933;
import '../../features/shopping_list/domain/usecases/shopping_usecases.dart'
    as _i313;
import '../../features/shopping_list/presentation/bloc/shopping_bloc.dart'
    as _i192;
import '../../features/statistics/data/repositories/statistics_repository_impl.dart'
    as _i905;
import '../../features/statistics/domain/repositories/statistics_repository.dart'
    as _i1033;
import '../../features/statistics/domain/usecases/statistics_usecases.dart'
    as _i1043;
import '../../features/statistics/presentation/bloc/statistics_bloc.dart'
    as _i923;
import '../../features/user/data/repositories/user_repository_impl.dart'
    as _i664;
import '../../features/user/domain/repositories/user_repository.dart' as _i237;
import '../../features/user/domain/usecases/user_usecases.dart' as _i804;
import '../../features/user/presentation/bloc/user_bloc.dart' as _i747;
import '../../routing/app_router.dart' as _i605;
import '../services/push_notification_service.dart' as _i63;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i605.AppRouter>(() => _i605.AppRouter());
    gh.lazySingleton<_i905.StatisticsRemoteDataSource>(
      () => _i905.StatisticsRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i517.AdminRemoteDataSource>(
      () => _i517.AdminRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i930.ThemeBloc>(
      () => _i930.ThemeBloc(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i153.AuthRemoteDataSource>(
      () => _i153.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i986.FridgeRemoteDataSource>(
      () => _i986.FridgeRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i514.RecipeRemoteDataSource>(
      () => _i514.RecipeRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i249.ShoppingRemoteDataSource>(
      () => _i249.ShoppingRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i664.UserRemoteDataSource>(
      () => _i664.UserRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i148.GroupRemoteDataSource>(
      () => _i148.GroupRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1033.StatisticsRepository>(
      () => _i905.StatisticsRepositoryImpl(
        gh<_i905.StatisticsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i617.NotificationService>(
      () => _i617.NotificationService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i63.PushNotificationService>(
      () => _i63.PushNotificationService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i407.NotificationRemoteDataSource>(
      () => _i407.NotificationRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i933.ShoppingRepository>(
      () => _i249.ShoppingRepositoryImpl(gh<_i249.ShoppingRemoteDataSource>()),
    );
    gh.lazySingleton<_i314.MealPlanRemoteDataSource>(
      () => _i314.MealPlanRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i528.CategoryRemoteDataSource>(
      () => _i528.CategoryRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i76.RecipeRepository>(
      () => _i514.RecipeRepositoryImpl(gh<_i514.RecipeRemoteDataSource>()),
    );
    gh.lazySingleton<_i313.GetShoppingTasksUseCase>(
      () => _i313.GetShoppingTasksUseCase(gh<_i933.ShoppingRepository>()),
    );
    gh.lazySingleton<_i313.CreateShoppingListUseCase>(
      () => _i313.CreateShoppingListUseCase(gh<_i933.ShoppingRepository>()),
    );
    gh.lazySingleton<_i313.AddShoppingTaskUseCase>(
      () => _i313.AddShoppingTaskUseCase(gh<_i933.ShoppingRepository>()),
    );
    gh.lazySingleton<_i313.UpdateShoppingTaskUseCase>(
      () => _i313.UpdateShoppingTaskUseCase(gh<_i933.ShoppingRepository>()),
    );
    gh.lazySingleton<_i313.DeleteShoppingTaskUseCase>(
      () => _i313.DeleteShoppingTaskUseCase(gh<_i933.ShoppingRepository>()),
    );
    gh.lazySingleton<_i313.ReorderShoppingTasksUseCase>(
      () => _i313.ReorderShoppingTasksUseCase(gh<_i933.ShoppingRepository>()),
    );
    gh.lazySingleton<_i237.UserRepository>(
      () => _i664.UserRepositoryImpl(gh<_i664.UserRemoteDataSource>()),
    );
    gh.lazySingleton<_i201.FridgeRepository>(
      () => _i986.FridgeRepositoryImpl(gh<_i986.FridgeRemoteDataSource>()),
    );
    gh.lazySingleton<_i1043.GetConsumptionStatsUseCase>(
      () =>
          _i1043.GetConsumptionStatsUseCase(gh<_i1033.StatisticsRepository>()),
    );
    gh.lazySingleton<_i1043.GetShoppingStatsUseCase>(
      () => _i1043.GetShoppingStatsUseCase(gh<_i1033.StatisticsRepository>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i153.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i46.LoginUseCase>(
      () => _i46.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.RegisterUseCase>(
      () => _i46.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i630.NotificationRepository>(
      () => _i407.NotificationRepositoryImpl(
        gh<_i407.NotificationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i869.CategoryRepository>(
      () => _i528.CategoryRepositoryImpl(gh<_i528.CategoryRemoteDataSource>()),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(gh<_i46.LoginUseCase>(), gh<_i46.RegisterUseCase>()),
    );
    gh.lazySingleton<_i952.MealPlanRepository>(
      () => _i314.MealPlanRepositoryImpl(gh<_i314.MealPlanRemoteDataSource>()),
    );
    gh.lazySingleton<_i583.AdminRepository>(
      () => _i335.AdminRepositoryImpl(gh<_i517.AdminRemoteDataSource>()),
    );
    gh.lazySingleton<_i347.GetAllRecipesUseCase>(
      () => _i347.GetAllRecipesUseCase(gh<_i76.RecipeRepository>()),
    );
    gh.lazySingleton<_i347.CreateRecipeUseCase>(
      () => _i347.CreateRecipeUseCase(gh<_i76.RecipeRepository>()),
    );
    gh.lazySingleton<_i347.UpdateRecipeUseCase>(
      () => _i347.UpdateRecipeUseCase(gh<_i76.RecipeRepository>()),
    );
    gh.lazySingleton<_i347.DeleteRecipeUseCase>(
      () => _i347.DeleteRecipeUseCase(gh<_i76.RecipeRepository>()),
    );
    gh.lazySingleton<_i347.GetRecipesByFoodUseCase>(
      () => _i347.GetRecipesByFoodUseCase(gh<_i76.RecipeRepository>()),
    );
    gh.factory<_i662.RecipeBloc>(
      () => _i662.RecipeBloc(
        gh<_i347.GetAllRecipesUseCase>(),
        gh<_i347.CreateRecipeUseCase>(),
        gh<_i347.UpdateRecipeUseCase>(),
        gh<_i347.DeleteRecipeUseCase>(),
        gh<_i347.GetRecipesByFoodUseCase>(),
      ),
    );
    gh.lazySingleton<_i404.GetFridgeItemsUseCase>(
      () => _i404.GetFridgeItemsUseCase(gh<_i201.FridgeRepository>()),
    );
    gh.lazySingleton<_i326.AddFridgeItemUseCase>(
      () => _i326.AddFridgeItemUseCase(gh<_i201.FridgeRepository>()),
    );
    gh.lazySingleton<_i326.UpdateFridgeItemUseCase>(
      () => _i326.UpdateFridgeItemUseCase(gh<_i201.FridgeRepository>()),
    );
    gh.lazySingleton<_i326.RemoveFridgeItemUseCase>(
      () => _i326.RemoveFridgeItemUseCase(gh<_i201.FridgeRepository>()),
    );
    gh.lazySingleton<_i326.ConsumeFridgeItemUseCase>(
      () => _i326.ConsumeFridgeItemUseCase(gh<_i201.FridgeRepository>()),
    );
    gh.factory<_i923.StatisticsBloc>(
      () => _i923.StatisticsBloc(
        gh<_i1043.GetConsumptionStatsUseCase>(),
        gh<_i1043.GetShoppingStatsUseCase>(),
      ),
    );
    gh.lazySingleton<_i804.GetProfileUseCase>(
      () => _i804.GetProfileUseCase(gh<_i237.UserRepository>()),
    );
    gh.lazySingleton<_i804.UpdateFcmTokenUseCase>(
      () => _i804.UpdateFcmTokenUseCase(gh<_i237.UserRepository>()),
    );
    gh.lazySingleton<_i702.GroupRepository>(
      () => _i959.GroupRepositoryImpl(gh<_i148.GroupRemoteDataSource>()),
    );
    gh.lazySingleton<_i312.GetNotificationsUseCase>(
      () => _i312.GetNotificationsUseCase(gh<_i630.NotificationRepository>()),
    );
    gh.lazySingleton<_i312.MarkAsReadUseCase>(
      () => _i312.MarkAsReadUseCase(gh<_i630.NotificationRepository>()),
    );
    gh.lazySingleton<_i312.MarkAllReadUseCase>(
      () => _i312.MarkAllReadUseCase(gh<_i630.NotificationRepository>()),
    );
    gh.lazySingleton<_i125.GetCategoriesUseCase>(
      () => _i125.GetCategoriesUseCase(gh<_i869.CategoryRepository>()),
    );
    gh.factory<_i192.ShoppingBloc>(
      () => _i192.ShoppingBloc(
        gh<_i313.GetShoppingTasksUseCase>(),
        gh<_i313.CreateShoppingListUseCase>(),
        gh<_i313.AddShoppingTaskUseCase>(),
        gh<_i313.UpdateShoppingTaskUseCase>(),
        gh<_i313.DeleteShoppingTaskUseCase>(),
        gh<_i313.ReorderShoppingTasksUseCase>(),
      ),
    );
    gh.lazySingleton<_i998.AddMemberUseCase>(
      () => _i998.AddMemberUseCase(gh<_i702.GroupRepository>()),
    );
    gh.lazySingleton<_i382.CreateGroupUseCase>(
      () => _i382.CreateGroupUseCase(gh<_i702.GroupRepository>()),
    );
    gh.lazySingleton<_i316.GetGroupsUseCase>(
      () => _i316.GetGroupsUseCase(gh<_i702.GroupRepository>()),
    );
    gh.lazySingleton<_i742.GetGroupDetailUseCase>(
      () => _i742.GetGroupDetailUseCase(gh<_i702.GroupRepository>()),
    );
    gh.lazySingleton<_i909.RemoveMemberUseCase>(
      () => _i909.RemoveMemberUseCase(gh<_i702.GroupRepository>()),
    );
    gh.lazySingleton<_i845.GroupBloc>(
      () => _i845.GroupBloc(
        gh<_i316.GetGroupsUseCase>(),
        gh<_i742.GetGroupDetailUseCase>(),
        gh<_i998.AddMemberUseCase>(),
        gh<_i382.CreateGroupUseCase>(),
        gh<_i909.RemoveMemberUseCase>(),
      ),
    );
    gh.lazySingleton<_i307.GetSystemStatsUseCase>(
      () => _i307.GetSystemStatsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i695.GetAdminUsersUseCase>(
      () => _i695.GetAdminUsersUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i179.UpdateUserRoleUseCase>(
      () => _i179.UpdateUserRoleUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i747.UserBloc>(
      () => _i747.UserBloc(
        gh<_i804.GetProfileUseCase>(),
        gh<_i804.UpdateFcmTokenUseCase>(),
      ),
    );
    gh.lazySingleton<_i381.GetMealPlanUseCase>(
      () => _i381.GetMealPlanUseCase(gh<_i952.MealPlanRepository>()),
    );
    gh.lazySingleton<_i381.AddMealPlanUseCase>(
      () => _i381.AddMealPlanUseCase(gh<_i952.MealPlanRepository>()),
    );
    gh.lazySingleton<_i381.DeleteMealPlanUseCase>(
      () => _i381.DeleteMealPlanUseCase(gh<_i952.MealPlanRepository>()),
    );
    gh.lazySingleton<_i381.GetMealSuggestionsUseCase>(
      () => _i381.GetMealSuggestionsUseCase(gh<_i952.MealPlanRepository>()),
    );
    gh.factory<_i55.AdminBloc>(
      () => _i55.AdminBloc(
        gh<_i307.GetSystemStatsUseCase>(),
        gh<_i695.GetAdminUsersUseCase>(),
        gh<_i179.UpdateUserRoleUseCase>(),
      ),
    );
    gh.factory<_i292.CategoryBloc>(
      () => _i292.CategoryBloc(gh<_i125.GetCategoriesUseCase>()),
    );
    gh.factory<_i29.NotificationBloc>(
      () => _i29.NotificationBloc(
        gh<_i312.GetNotificationsUseCase>(),
        gh<_i312.MarkAsReadUseCase>(),
        gh<_i312.MarkAllReadUseCase>(),
      ),
    );
    gh.factory<_i742.FridgeBloc>(
      () => _i742.FridgeBloc(
        gh<_i404.GetFridgeItemsUseCase>(),
        gh<_i326.AddFridgeItemUseCase>(),
        gh<_i326.UpdateFridgeItemUseCase>(),
        gh<_i326.RemoveFridgeItemUseCase>(),
        gh<_i326.ConsumeFridgeItemUseCase>(),
        gh<_i125.GetCategoriesUseCase>(),
      ),
    );
    gh.factory<_i642.MealPlanBloc>(
      () => _i642.MealPlanBloc(
        gh<_i381.GetMealPlanUseCase>(),
        gh<_i381.AddMealPlanUseCase>(),
        gh<_i381.DeleteMealPlanUseCase>(),
        gh<_i381.GetMealSuggestionsUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
