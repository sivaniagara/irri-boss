import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/common_setting_item_entity.dart';


class SingleSettingItemModel extends SingleSettingItemEntity{
  SingleSettingItemModel({
    required super.sNo,
    required super.widgetType,
    required super.value,
    required super.settingField,
    required super.titleText,
    required super.hf,
    required super.option
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
        option: json['OPTION'] != null ? (json['OPTION'].split(';')) : []
    );
  }

  factory SingleSettingItemModel.fromEntity({required SingleSettingItemEntity entity}){
    return SingleSettingItemModel(
        sNo: entity.sNo,
        widgetType: entity.widgetType,
        value: entity.value,
        settingField: entity.settingField,
        titleText: entity.titleText,
        hf: entity.hf,
        option: entity.option
    );
  }

  String mqttPayload({String? dependentValue}){
    if(widgetType == 2){
      return '$settingField$value';
    }else if(widgetType == 3){
      return '$settingField${value.replaceAll(':', '')}';
    }else if(widgetType == 10){
      if(['LOWPRESS', 'HIGHPRESS'].contains(settingField)){
        return '$settingField${formatTo000_0(double.parse(value.isEmpty ? '0' : value))}';
      }else if(['IDCALSET001,', 'IDCALSET002,' ,'IDCALSET003,', 'IDCALSET004,', 'IDCALSET005,'].contains(settingField)){
        return '$settingField${formatTo0_000(double.parse(value.isEmpty ? '0' : value))}';
      }
      return '$settingField${formatTo0000_0(double.parse(value.isEmpty ? '0' : value))}';
    }else if(widgetType == 9){
      if(['SKIPDAYS', 'RUNDAYS'].contains(settingField)){
        return '$settingField${int.parse(value.isEmpty ? '0' : value)}';
      }
      return '$settingField${formatTo000(int.parse(value.isEmpty ? '0' : value))}';
    }else{
      if(settingField.contains(';')){
        List<String> sfList = settingField.split(';');
        int index = option.indexOf(value);
        if(settingField.contains('MODEONP') || titleText == 'Dosing'){
          return '${sfList[index]}$dependentValue';
        }
        return sfList[index];
      }
      return '$settingField$value';
    }
  }

  Map<String, dynamic> toJson(){
    return {
      "SN": sNo,
      "WT": widgetType,
      "VAL": value,
      "SF": settingField,
      "TT": titleText,
      "HF": hf,
      if(option.isNotEmpty)
        "OPTION" : option.join(';')
    };
  }

}

String formatTo0000_0(num value) {
  String formatted = value.toStringAsFixed(1);
  return formatted.padLeft(5, '0');
}
String formatTo000_0(num value) {
  String formatted = value.toStringAsFixed(1);
  return formatted.padLeft(4, '0');
}
String formatTo0_000(num value) {
  String formatted = value.toStringAsFixed(3);
  return formatted;
}

String formatTo000(int value) {
  // Always keep one decimal place
  String formatted = value.toString();

  // Ensure at least 3 characters total (e.g., "0000.0")
  return formatted.padLeft(3, '0');
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

  factory MultipleSettingItemModel.fromEntity({required MultipleSettingItemEntity entity}) {
    return MultipleSettingItemModel(
        listOfSingleSettingItemEntity: entity.listOfSingleSettingItemEntity.map((singleEntity){
          return SingleSettingItemModel.fromEntity(entity: singleEntity);
        }).toList()
    );
  }


  String mqttPayload({String? firstDependent}){
    if(listOfSingleSettingItemEntity.first.widgetType == 2){
      if(['FERTOBOF', 'REFRESHONOF', 'FERTONOF'].contains(listOfSingleSettingItemEntity.first.settingField)){
        List<String> channelPayloadList = List.generate(listOfSingleSettingItemEntity.length, (index){
          return '${index+1}${listOfSingleSettingItemEntity[index].value == 'ON' ? '1' : '0'}';
        });
        return '${listOfSingleSettingItemEntity.first.settingField},${channelPayloadList.join(',')}';
      }
      return '${listOfSingleSettingItemEntity.first.settingField},${listOfSingleSettingItemEntity.map((set) => set.value).join(',')}';
    }else if(listOfSingleSettingItemEntity.first.widgetType == 10){
      if(['PHSET', 'ECSET'].contains(listOfSingleSettingItemEntity.first.settingField)){
        return '${listOfSingleSettingItemEntity.first.settingField}'
            '${listOfSingleSettingItemEntity.first.titleText == 'F1' ? (firstDependent ?? '') : ''},'
            '${listOfSingleSettingItemEntity.map((set) => formatTo0_000(double.parse(set.value.isEmpty ? '0' : set.value))).join(',')}';
      }
      return '${listOfSingleSettingItemEntity.first.settingField}'
          '${listOfSingleSettingItemEntity.first.titleText == 'F1' ? (firstDependent ?? '') : ''},'
          '${listOfSingleSettingItemEntity.map((set) => formatTo0000_0(double.parse(set.value.isEmpty ? '0' : set.value))).join(',')}';
    }else if(listOfSingleSettingItemEntity.first.widgetType == 9){
      if(['#PROGSTART'].contains(listOfSingleSettingItemEntity.first.settingField)){
        String program = '${int.parse(listOfSingleSettingItemEntity[0].value.isEmpty ? '0' : listOfSingleSettingItemEntity[0].value)}'.padLeft(2, '0');
        String zone = '${int.parse(listOfSingleSettingItemEntity[1].value.isEmpty ? '000' : listOfSingleSettingItemEntity[1].value)}'.padLeft(3, '0');
        return '${listOfSingleSettingItemEntity.first.settingField}$program,$zone';
      }
      return '${listOfSingleSettingItemEntity.first.settingField},${listOfSingleSettingItemEntity.map((set) => formatTo000(int.parse(set.value.isEmpty ? '0' : set.value))).join(',')}';
    }else if(listOfSingleSettingItemEntity.first.widgetType == 3){
      return '${listOfSingleSettingItemEntity.first.settingField}'
          '${['REFTIMON'].contains(listOfSingleSettingItemEntity.first.settingField) ? '' : ','}'
          '${listOfSingleSettingItemEntity.map((set) => set.value.replaceAll(':', '')).join(',')}';
    }else{
      return '${listOfSingleSettingItemEntity.first.settingField},${listOfSingleSettingItemEntity.map((set) => set.value).join(',')}';
    }
  }

  Map<String, dynamic> toJson(){
    List<String> formSf = listOfSingleSettingItemEntity.map((single) => single.settingField).toList();
    String payloadSf = '';
    if(formSf.length == 1){
      payloadSf = formSf.first;
    }else if(formSf.length > 1 && (formSf[0] == formSf[1])){
      payloadSf = formSf.first;
    }else{
      payloadSf = formSf.join(';');
    }
    return {
      "SN": listOfSingleSettingItemEntity.first.sNo,
      "WT": listOfSingleSettingItemEntity.first.widgetType,
      "VAL": listOfSingleSettingItemEntity.map((single) => single.value).join(';'),
      "SF": payloadSf,
      "TT": listOfSingleSettingItemEntity.map((single) => single.titleText).join(';'),
      "HF": listOfSingleSettingItemEntity.map((single) => single.hf).join(';'),
      if(listOfSingleSettingItemEntity.first.option.isNotEmpty)
        "OPTION": listOfSingleSettingItemEntity.first.option.join(';')
    };
  }
}