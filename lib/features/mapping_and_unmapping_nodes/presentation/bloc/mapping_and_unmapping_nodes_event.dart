part of 'mapping_and_unmapping_nodes_bloc.dart';

abstract class MappingAndUnmappingNodesEvent{}

class FetchMappingAndUnmappingEvent extends MappingAndUnmappingNodesEvent{
  final String userId;
  final String controllerId;
  FetchMappingAndUnmappingEvent({required this.userId, required this.controllerId});
}