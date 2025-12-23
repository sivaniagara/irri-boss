import '../../domain/entities/unmapped_category_entity.dart';
import '../../domain/entities/unmapped_category_node_entity.dart';
import 'unmapped_category_node_model.dart';

class UnmappedCategoryModel extends UnmappedCategoryEntity {
  const UnmappedCategoryModel({
    required super.categoryId,
    required super.categoryName,
    required super.count,
    required super.nodes,
  });

  factory UnmappedCategoryModel.fromJson(Map<String, dynamic> json) {
    return UnmappedCategoryModel(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      count: json['count'],
      nodes: (json['nodeList'] as List? ?? [])
          .map((e) => UnmappedCategoryNodeModel.fromJson(e))
          .toList().cast<UnmappedCategoryNodeEntity>(),
    );
  }

  Map<String, dynamic> toJson(){
    return {};
  }
}

