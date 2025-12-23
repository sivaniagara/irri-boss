import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_entity.dart';

import 'mapped_node_entity.dart';

class MappingAndUnmappingNodeEntity{
  final List<UnmappedCategoryEntity> listOfUnmappedCategoryEntity;
  final List<MappedNodeEntity> listOfMappedNodeEntity;
  MappingAndUnmappingNodeEntity({required this.listOfMappedNodeEntity, required this.listOfUnmappedCategoryEntity});
}