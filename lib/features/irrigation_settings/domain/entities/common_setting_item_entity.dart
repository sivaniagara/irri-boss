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
  final List<String> option;

  SingleSettingItemEntity({
    required this.sNo,
    required this.widgetType,
    required this.value,
    required this.settingField,
    required this.titleText,
    required this.hf,
    required this.option,
  });

  SingleSettingItemEntity copyWith({String? updateValue, String? updateHf}){
    print("updateHf : $updateHf");
    return SingleSettingItemEntity(
        sNo: sNo,
        widgetType: widgetType,
        value: updateValue ?? value,
        settingField: settingField,
        titleText: titleText,
        hf: updateHf ?? hf,
        option: option
    );
  }

}


class MultipleSettingItemEntity extends CommonSettingItemEntity{
  final List<SingleSettingItemEntity> listOfSingleSettingItemEntity;
  MultipleSettingItemEntity({required this.listOfSingleSettingItemEntity});

  MultipleSettingItemEntity copyWith({List<SingleSettingItemEntity>? updateListOfSingleSettingItemEntity}){
    return MultipleSettingItemEntity(
        listOfSingleSettingItemEntity: updateListOfSingleSettingItemEntity ?? listOfSingleSettingItemEntity
    );
  }
}
