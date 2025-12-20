import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';

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
    // Based on legacy repo: response.data['data']['access_token']
    final responseData = response.data;
    if (responseData == null || responseData['data'] == null) {
      throw 'Empty response from server';
    }
    return responseData['data']['access_token'];
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

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final result = await _dataSource.login(email, password);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Login failed'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
    String username,
  ) async {
    try {
      await _dataSource.register(email, password, name, username);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Registration failed'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
