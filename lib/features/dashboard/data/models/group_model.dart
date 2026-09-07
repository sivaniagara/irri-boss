import '../../domain/entities/group_entity.dart';

class GroupDetails extends GroupDetailsEntity {
  GroupDetails({
    required super.userGroupId,
    required super.userId,
    required super.groupName,
  });

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return GroupDetails(
      userGroupId: parseId(json['userGroupId'] ?? json['userClusterId'] ?? json['groupId'] ?? json['id']),
      userId: parseId(json['userId']),
      groupName: json['groupName'] as String? ?? json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userGroupId': userGroupId,
      'userId': userId,
      'groupName': groupName,
    };
  }

  GroupDetailsEntity toEntity() {
    return GroupDetailsEntity(
      userGroupId: userGroupId,
      userId: userId,
      groupName: groupName,
    );
  }
}