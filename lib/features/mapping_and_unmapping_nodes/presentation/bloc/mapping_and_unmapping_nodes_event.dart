part of 'mapping_and_unmapping_nodes_bloc.dart';

abstract class MappingAndUnmappingNodesEvent{}

class FetchMappingAndUnmappingEvent extends MappingAndUnmappingNodesEvent{
  final String userId;
  final String controllerId;
  final String deviceId;
  FetchMappingAndUnmappingEvent({required this.userId, required this.controllerId, required this.deviceId});
}

class DeleteMappedNodeEvent extends MappingAndUnmappingNodesEvent{
  final String userId;
  final String controllerId;
  final String deviceId;
  final MappedNodeEntity mappedNodeEntity;
  DeleteMappedNodeEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.mappedNodeEntity
  });
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

class ViewNodeDetailsMqttEvent extends MappingAndUnmappingNodesEvent {
  final MappedNodeEntity mappedNodeEntity;

  ViewNodeDetailsMqttEvent({required this.mappedNodeEntity});
}
