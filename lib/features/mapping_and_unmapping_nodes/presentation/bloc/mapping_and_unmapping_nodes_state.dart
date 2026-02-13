part of 'mapping_and_unmapping_nodes_bloc.dart';


abstract class MappingAndUnmappingNodesState{}

class MappingAndUnmappingNodesInitial extends MappingAndUnmappingNodesState{}
class MappingAndUnmappingNodesLoading extends MappingAndUnmappingNodesState{}
class MappingAndUnmappingNodesLoaded extends MappingAndUnmappingNodesState{
  final String userId;
  final String controllerId;
  final String deviceId;
  DeleteMappedNodeEnum deleteMappedNodeEnum;
  UnmappedNodeToMappedEnum unmappedNodeToMappedEnum;
  String message;
  final MappingAndUnmappingNodeEntity mappingAndUnmappingNodeEntity;

  MappingAndUnmappingNodesLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.mappingAndUnmappingNodeEntity,
    this.deleteMappedNodeEnum = DeleteMappedNodeEnum.idle,
    this.unmappedNodeToMappedEnum = UnmappedNodeToMappedEnum.idle,
    this.message = ''
  });

  MappingAndUnmappingNodesLoaded copyWith({
    MappingAndUnmappingNodeEntity? entity,
    DeleteMappedNodeEnum? deleteStatus,
    UnmappedNodeToMappedEnum? unMapToMapStatus,
    String? msg,
  }){
    return MappingAndUnmappingNodesLoaded(
        userId: userId,
        controllerId: controllerId,
        deviceId: deviceId,
        mappingAndUnmappingNodeEntity: entity ?? mappingAndUnmappingNodeEntity,
        deleteMappedNodeEnum: deleteStatus ?? deleteMappedNodeEnum,
        unmappedNodeToMappedEnum: unMapToMapStatus ?? unmappedNodeToMappedEnum,
        message: msg ?? message
    );
  }
}
class MappingAndUnmappingNodesError extends MappingAndUnmappingNodesState{}