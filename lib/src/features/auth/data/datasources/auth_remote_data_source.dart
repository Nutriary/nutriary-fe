import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<void> register(
    String email,
    String password,
    String name,
    String username,
  );
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<String> login(String email, String password) async {
    final response = await _dio.post(
      '/user/login',
      data: {'email': email, 'password': password},
    );
    return response.data['data']['access_token'];
  }

  @override
  Future<void> register(
    String email,
    String password,
    String name,
    String username,
  ) async {
    await _dio.post(
      '/user',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'username': username,
      },
    );
  }
}
