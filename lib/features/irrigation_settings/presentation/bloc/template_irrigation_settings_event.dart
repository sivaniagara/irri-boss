part of 'template_irrigation_settings_bloc.dart';

abstract class TemplateIrrigationSettingsEvent{}

class FetchTemplateSettingEvent extends TemplateIrrigationSettingsEvent{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String settingNo;
  FetchTemplateSettingEvent({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.settingNo,
  });
}

class UpdateTemplateSettingEvent extends TemplateIrrigationSettingsEvent{
  final int groupIndex;
  final int settingIndex;
  UpdateTemplateSettingEvent({
    required this.groupIndex,
    required this.settingIndex,
  });
}


class UpdateSingleSettingRowEvent extends TemplateIrrigationSettingsEvent{
  final int groupIndex;
  final int index;
  final dynamic value;
  UpdateSingleSettingRowEvent({
    required this.groupIndex,
    required this.index,
    required this.value,
  });
}

class UpdateMultipleSettingRowEvent extends TemplateIrrigationSettingsEvent{
  final int groupIndex;
  final int multipleIndex;
  final int index;
  final dynamic value;
  UpdateMultipleSettingRowEvent({
    required this.groupIndex,
    required this.multipleIndex,
    required this.index,
    required this.value,
  });
}