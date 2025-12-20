import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/group_model.dart';
import '../models/group_detail_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<GroupDetailModel> getGroupDetail(int groupId);
  Future<void> createGroup(String name);
  Future<void> addMember(String username);
}

@LazySingleton(as: GroupRemoteDataSource)
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final Dio _dio;

  GroupRemoteDataSourceImpl(this._dio);

  @override
  Future<List<GroupModel>> getGroups() async {
    final response = await _dio.get('/user/group/all');
    final responseData = response.data;
    if (responseData == null || responseData['data'] == null) return [];
    return (responseData['data'] as List)
        .map((e) => GroupModel.fromJson(e))
        .toList();
  }

  @override
  Future<GroupDetailModel> getGroupDetail(int groupId) async {
    final response = await _dio.get(
      '/user/group',
      queryParameters: {'groupId': groupId},
    );
    final responseData = response.data;
    if (responseData == null || responseData['data'] == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: "Group not found",
      );
    }
    return GroupDetailModel.fromJson(responseData['data']);
  }

  @override
  Future<void> createGroup(String name) async {
    await _dio.post('/user/group', data: {'name': name});
  }

  @override
  Future<void> addMember(String username) async {
    await _dio.post('/user/group/add', data: {'username': username});
  }
}
