import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  GroupModel({
    required super.userGroupId,
    required super.userId,
    required super.groupName
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
        userGroupId: json["userGroupId"],
        userId: json["userId"],
        groupName: json["groupName"]
    );
  }
}