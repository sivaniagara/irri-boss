import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/data/models/unmapped_category_model.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/mapping_and_unmapping_node_entity.dart';

import '../../../program_settings/sub_module/common_id_settings/data/models/category_model.dart';
import 'mapped_node_model.dart';

class MappingAndUnmappingNodeModel extends MappingAndUnmappingNodeEntity{
  MappingAndUnmappingNodeModel({required super.listOfUnmappedCategoryEntity, required super.listOfMappedNodeEntity});

  factory MappingAndUnmappingNodeModel.fromJson(List<dynamic> data){
    List<Map<String, dynamic>> list = List.from(data);
    list.removeAt(0);
    List<UnmappedCategoryModel> listOfCategoryModel = list.map((e){
      return UnmappedCategoryModel.fromJson(e);
    }).toList();
    List<MappedNodeModel> listOfMappedNodeModel = data[0]['Mapped Nodes'].map<MappedNodeModel>((e){
      return MappedNodeModel.fromJson(e);
    }).toList();
    return MappingAndUnmappingNodeModel(
        listOfUnmappedCategoryEntity: listOfCategoryModel,
        listOfMappedNodeEntity: listOfMappedNodeModel
    );
  }
}