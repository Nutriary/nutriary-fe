import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriary_fe/src/features/auth/data/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_repository.g.dart';

@riverpod
GroupRepository groupRepository(Ref ref) {
  return GroupRepository(ref.watch(dioProvider));
}

class GroupRepository {
  final Dio _dio;
  GroupRepository(this._dio);

  Future<Map<String, dynamic>?> getMyGroup() async {
    try {
      final response = await _dio.get('/user/group');
      if (response.data == null) return null;
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      // If it's a string, it might be an error or unexpected format
      print('Unexpected response type: ${response.data.runtimeType}, Value: ${response.data}');
      if (response.data is String && (response.data as String).isEmpty) return null;
      
      throw 'Invalid response format from server';
      
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.response?.data['message'] ?? 'Failed to fetch group';
    }
  }

  Future<void> createGroup() async {
    try {
      await _dio.post('/user/group', data: {});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create group';
    }
  }
}
