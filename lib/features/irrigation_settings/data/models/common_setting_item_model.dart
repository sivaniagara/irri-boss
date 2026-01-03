import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/common_setting_item_entity.dart';


class SingleSettingItemModel extends SingleSettingItemEntity{
  SingleSettingItemModel({
    required super.sNo,
    required super.widgetType,
    required super.value,
    required super.settingField,
    required super.titleText,
    required super.hf,
    required super.optionSno
  });

  factory SingleSettingItemModel.fromJson({required Map<String, dynamic> json}){
    print("json : $json");
    print(json['OPTION']);
    return SingleSettingItemModel(
        sNo: json['SN'],
        widgetType: json['WT'],
        value: json['VAL'],
        settingField: json['SF'],
        titleText: json['TT'],
        hf: json['HF'],
        optionSno: json['OPTION'] != null ? (json['OPTION'].split(';')) : ['']
    );
  }

}


class MultipleSettingItemModel extends MultipleSettingItemEntity{
  MultipleSettingItemModel({
    required super.listOfSingleSettingItemEntity
  });

  factory MultipleSettingItemModel.fromJson({required Map<String, dynamic> json}){
    print("MultipleSettingItemModel.fromJson called");;
    List<Map<String, dynamic>> data = List.generate(json['VAL'].split(';').length, (index){
      print("multi json : $json");
      return {
        "SN": json['SN'],
        "WT": json['WT'],
        "VAL": json['VAL'].split(';')[index],
        "SF": json['SF'],
        "TT": json['TT'].contains(';') ? json['TT'].split(';')[index] : json['TT'],
        "HF": json['HF'].split(';')[index],
        "OPTION": json['OPTION']
      };
    });
    return MultipleSettingItemModel(
        listOfSingleSettingItemEntity: data.map((e){
          return SingleSettingItemModel.fromJson(json: e);
        }).toList()
    );
  }
}