part of 'mapping_and_unmapping_nodes_bloc.dart';


abstract class MappingAndUnmappingNodesState{}

class MappingAndUnmappingNodesInitial extends MappingAndUnmappingNodesState{}
class MappingAndUnmappingNodesLoading extends MappingAndUnmappingNodesState{}
class MappingAndUnmappingNodesLoaded extends MappingAndUnmappingNodesState{
  final String userId;
  final String controllerId;
  final MappingAndUnmappingNodeEntity mappingAndUnmappingNodeEntity;

  MappingAndUnmappingNodesLoaded({
    required this.userId,
    required this.controllerId,
    required this.mappingAndUnmappingNodeEntity,
  });
}
class MappingAndUnmappingNodesError extends MappingAndUnmappingNodesState{}