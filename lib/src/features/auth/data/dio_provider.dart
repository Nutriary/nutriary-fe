import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();

  // Get Base URL from env
  final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);

  // Add Auth Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Read token. Note: We can't use ref inside async callback easily if we want to watch it,
        // but secure storage is fine.
        // Better: Use a synchronous interceptor if token is in memory, or access storage.
        // Since SecureStorage is async, we do this:
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Inspect error
        if (kDebugMode) {
          print('Dio Error: ${e.message}');
          print('Response: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}
