import 'dart:convert';

import '../../domain/entities/category_entity.dart';
import 'category_node_model.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryName,
    required super.nodes,
    required super.smsFormat,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryName: json['categoryName'] ?? '',
      smsFormat: json['smsFormat'] ?? '',
      nodes: (json['nodeList'] as List<dynamic>? ?? [])
          .where((e) => e['serialNo'] != '000')
          .map((e) => CategoryNodeModel.fromJson(e))
          .toList(),
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      categoryName: entity.categoryName,
      smsFormat: entity.smsFormat,
      nodes: entity.nodes.map<CategoryNodeModel>((e){
        return CategoryNodeModel.fromEntity(e);
      }).toList(),
    );
  }

  Map<String, dynamic> updateCategoryNodeSerialNoPayload(){

    var nodeList = [];
    List<String> nodeSerialNoList = [];
    for(var i = 0;i < 6; i++){
      if(i < nodes.length){
        nodeList.add({'nodeId' : nodes[i].nodeId, 'orderNumber' : i+1});
        nodeSerialNoList.add(nodes[i].serialNo);
      }else{
        nodeList.add({'nodeId' : '', 'orderNumber' : i+1});
        nodeSerialNoList.add('000');
      }
    }

    Map<String, dynamic> smsFormatJson = jsonDecode(smsFormat);
    return {
      "nodeList" : nodeList,
      "sentSms" : "${smsFormatJson[smsFormatJson.keys.first]},${nodeSerialNoList.join(',')}"
    };
  }
}
