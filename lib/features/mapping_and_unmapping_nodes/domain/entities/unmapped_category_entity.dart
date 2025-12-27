import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/unmapped_category_node_entity.dart';

class UnmappedCategoryEntity {
  final int categoryId;
  final String categoryName;
  final int count;
  final List<UnmappedCategoryNodeEntity> nodes;

  const UnmappedCategoryEntity({
    required this.categoryId,
    required this.categoryName,
    required this.count,
    required this.nodes,
  });

  UnmappedCategoryEntity copyWith(){
    return UnmappedCategoryEntity(
        categoryId: categoryId,
        categoryName: categoryName,
        count: count,
        nodes: nodes.map((e) => e.copyWith()).toList()
    );
  }


}
