import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  GroupModel({
    required super.userGroupId,
    required super.userId,
    required super.groupName,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return GroupModel(
      userGroupId: parseId(json["userGroupId"] ?? json["userClusterId"] ?? json["groupId"] ?? json["id"]),
      userId: parseId(json["userId"]),
      groupName: json["groupName"] as String? ?? json["name"] as String? ?? '',
    );
  }
}