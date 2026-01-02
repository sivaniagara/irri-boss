abstract class CommonSettingItemEntity {
  // int get widgetType;
  // String get settingField;
  // String get hf;
}


class SingleSettingItemEntity extends CommonSettingItemEntity{
  final int sNo;
  final int widgetType;
  final String value;
  final String settingField;
  final String titleText;
  final String hf;
  final List<String> optionSno;

  SingleSettingItemEntity({
    required this.sNo,
    required this.widgetType,
    required this.value,
    required this.settingField,
    required this.titleText,
    required this.hf,
    required this.optionSno,
  });

  SingleSettingItemEntity copyWith({String? updateValue}){
    return SingleSettingItemEntity(
        sNo: sNo,
        widgetType: widgetType,
        value: updateValue ?? value,
        settingField: settingField,
        titleText: titleText,
        hf: hf, optionSno: optionSno
    );
  }

}

class MultipleSettingItemEntity extends CommonSettingItemEntity{
  final List<SingleSettingItemEntity> listOfSingleSettingItemEntity;
  MultipleSettingItemEntity({required this.listOfSingleSettingItemEntity});

  // @override
  // // TODO: implement hf
  // String get hf => listOfSingleSettingItemEntity.first.hf;
  //
  // @override
  // // TODO: implement settingField
  // String get settingField => listOfSingleSettingItemEntity.first.settingField;
  //
  // @override
  // // TODO: implement widgetType
  // int get widgetType => listOfSingleSettingItemEntity.first.widgetType;
}
