import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import '../../../groups/groups_barrel.dart';

class GroupRepositoryImpl extends GroupRepository {
  final GroupDataSources groupDataSources;
  GroupRepositoryImpl({required this.groupDataSources});

  @override
  Future<Either<Failure, List<GroupEntity>>> fetchGroupEntity(int userId) async{
    try {
      final groupData = await groupDataSources.fetchGroups(userId);
      return Right(groupData);
    } catch (e) {
      return Left(ServerFailure('Group Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> addGroup(int userId, String groupName) async{
    try {
      final groupData = await groupDataSources.addGroups(userId, groupName);
      return Right(groupData);
    } catch (e) {
      return Left(ServerFailure('Group Adding Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> editGroup(int userId, String groupName, int groupId) async{
    try {
      final groupData = await groupDataSources.editGroups(userId, groupName, groupId);
      return Right(groupData);
    } catch (e) {
      return Left(ServerFailure('Group Adding Failure: $e'));
    }
  }

  // New Delete Method
  @override
  Future<Either<Failure, String>> deleteGroup(int userId, int groupId) async {
    try {
      final groupData = await groupDataSources.deleteGroup(userId, groupId);
      return Right(groupData);
    } catch (e) {
      return Left(ServerFailure('Group Delete Failure: $e'));
    }
  }
}