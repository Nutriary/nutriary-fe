import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/system_stats_model.dart';
import '../../../user/data/models/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<SystemStatsModel> getSystemStats();
  Future<List<UserModel>> getUsers(int page, int size);
  Future<void> updateUserRole(int userId, String role);
}

@LazySingleton(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio _dio;

  AdminRemoteDataSourceImpl(this._dio);

  @override
  Future<SystemStatsModel> getSystemStats() async {
    final response = await _dio.get('/admin/stats');
    final responseData = response.data;
    if (responseData == null || responseData['data'] == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: "No data returned",
      );
    }
    return SystemStatsModel.fromJson(responseData['data']);
  }

  @override
  Future<List<UserModel>> getUsers(int page, int size) async {
    final response = await _dio.get(
      '/admin/users',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data['data']['data'] as List;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateUserRole(int userId, String role) async {
    await _dio.put('/admin/users/$userId/role', data: {'role': role});
  }
}
