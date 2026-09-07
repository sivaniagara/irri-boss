import '../../../groups/utils/groups_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/api_client.dart';
import '../../domain/entities/group_entity.dart';
import '../model/group_details.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

abstract class GroupDataSources {
  Future<List<GroupEntity>> fetchGroups(int userId);
  Future<String> addGroups(int userId, String groupName);
  Future<String> editGroups(int userId, String groupName, int groupId);
  Future<String> deleteGroup(int userId, int groupId);
}

class GroupDataSourcesImpl extends GroupDataSources {
  final ApiClient apiClient;
  GroupDataSourcesImpl({required this.apiClient});

  @override
  Future<List<GroupEntity>> fetchGroups(int userId) async {
    try {
      final endpoint = GroupsUrls.getGroupValues.replaceAll(':userId', userId.toString());
      final response = await apiClient.get(endpoint);
      final code = response['code'] ?? response['statusCode'];
      if (code == 200 || code == '200') {
        final List<dynamic> dataList = response['data'] ?? [];
        final List<GroupModel> parsedGroups = dataList
            .map((json) => GroupModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return parsedGroups.cast<GroupEntity>();
      } else {
        throw ServerException(
          statusCode: code is int ? code : 500,
          message: response['message'] ?? 'Group details fetching Error',
        );
      }
    } catch (e) {
      kdebugmode('Fetch dashboard groups error: $e');
      throw Exception('Failed to fetch dashboard groups: $e');
    }
  }

  @override
  Future<String> addGroups(int userId, String groupName) async {
    try {
      final endpoint = GroupsUrls.addGroupValues.replaceAll(':userId', userId.toString());
      final response = await apiClient.post(
        endpoint,
        body: {
          'userId': userId,
          'groupName': groupName
        },
      );
      final code = response['code'] ?? response['statusCode'];
      if (code == 200 || code == 201 || code == '200' || code == '201') {
        return response['message'] ?? 'Group added successfully';
      } else {
        throw ServerException(
          statusCode: code is int ? code : 500,
          message: response['message'] ?? 'Failed to add group',
        );
      }
    } catch (e) {
      kdebugmode('Group adding error: $e');
      throw Exception('Group adding error: $e');
    }
  }

  @override
  Future<String> editGroups(int userId, String groupName, int groupId) async {
    try {
      final endpoint = GroupsUrls.updateGroupValues.replaceAll(':userId', userId.toString());
      Map<String, dynamic> body = {
        'userId': userId,
        'groupId': groupId,
        'groupName': groupName
      };
      final response = await apiClient.put(
        endpoint,
        body: body,
      );
      final code = response['code'] ?? response['statusCode'];
      if (code == 200 || code == '200') {
        return response['message'] ?? 'Group updated successfully';
      } else {
        throw ServerException(
          statusCode: code is int ? code : 500,
          message: response['message'] ?? 'Failed to update group',
        );
      }
    } catch (e) {
      kdebugmode('editGroups error: $e');
      throw Exception('Failed to edit group: $e');
    }
  }

  @override
  Future<String> deleteGroup(int userId, int groupId) async {
    try {
      final endpoint = GroupsUrls.deleteGroupValues.replaceAll(':userId', userId.toString()).replaceAll(':groupId', groupId.toString());
      final response = await apiClient.delete(
        endpoint,
      );
      final code = response['code'] ?? response['statusCode'];
      if (code == 200 || code == '200') {
        return response['message'] ?? 'Group deleted successfully';
      } else {
        throw ServerException(
          statusCode: code is int ? code : 500,
          message: response['message'] ?? 'Failed to delete group',
        );
      }
    } catch (e) {
      kdebugmode('deleteGroup error: $e');
      throw Exception('Failed to delete group: $e');
    }
  }
}