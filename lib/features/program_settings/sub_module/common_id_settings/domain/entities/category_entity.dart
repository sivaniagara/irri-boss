import 'category_node_entity.dart';

class CategoryEntity {
  final String categoryName;
  final List<CategoryNodeEntity> nodes;
  final String smsFormat;

  const CategoryEntity({
    required this.categoryName,
    required this.nodes,
    required this.smsFormat,
  });

  CategoryEntity copyWith({List<CategoryNodeEntity>? updatedNodes}){
    return CategoryEntity(
        categoryName: categoryName,
        nodes: updatedNodes ?? nodes,
        smsFormat: smsFormat
    );
  }
}
