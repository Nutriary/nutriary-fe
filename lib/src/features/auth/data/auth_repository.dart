import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriary_fe/src/features/auth/data/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(dioProvider));
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/user/login', // Prefix /api is handled by BaseUrl if set correctly, usually /api/user/login.
        // My dio_provider set baseUrl to /api/v1. But the backend has /api/user.
        // Wait, backend main.ts has global prefix 'api'. 
        // AuthController has 'user'.
        // So route is /api/user/login.
        // Dio baseUrl should be http://.../api
        data: {'email': email, 'password': password},
      );
      // Assuming response.data returns { access_token: ... } or similar
      return response.data['access_token']; 
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  Future<void> register(String email, String password, String name, String username) async {
    try {
      await _dio.post(
        '/user', 
        data: {'email': email, 'password': password, 'name': name, 'username': username},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Registration failed';
    }
  }
}
