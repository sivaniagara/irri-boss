part of 'mapping_and_unmapping_nodes_bloc.dart';

abstract class MappingAndUnmappingNodesEvent{}

class FetchMappingAndUnmappingEvent extends MappingAndUnmappingNodesEvent{
  final String userId;
  final String controllerId;
  FetchMappingAndUnmappingEvent({required this.userId, required this.controllerId});
}

class DeleteMappedNodeEvent extends MappingAndUnmappingNodesEvent{
  final String userId;
  final String controllerId;
  final MappedNodeEntity mappedNodeEntity;
  DeleteMappedNodeEvent({required this.userId, required this.controllerId, required this.mappedNodeEntity});
}

class UnMappedNodeToMappedEvent extends MappingAndUnmappingNodesEvent{
  final String userId;
  final String controllerId;
  final int categoryId;
  final UnmappedCategoryEntity unmappedCategoryEntity;
  UnMappedNodeToMappedEvent({
    required this.userId,
    required this.controllerId,
    required this.categoryId,
    required this.unmappedCategoryEntity
  });
}
