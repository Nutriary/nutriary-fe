import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  
  // Determine Base URL based on Platform
  String baseUrl = 'http://localhost:9999/api';
  if (!kIsWeb && Platform.isAndroid) {
    // 10.0.2.2 for Emulator, 192.168.1.104 for Physical Device
    // Since user is running on physical device (adb-...), use LAN IP.
    baseUrl = 'http://192.168.1.104:9999/api';
  }
  
  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);

  // Add Auth Interceptor
  dio.interceptors.add(InterceptorsWrapper(
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
    }
  ));

  return dio;
}
