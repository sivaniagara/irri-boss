part of 'template_irrigation_settings_bloc.dart';

abstract class TemplateIrrigationSettingsState{}

class TemplateIrrigationSettingsInitial extends TemplateIrrigationSettingsState{}
class TemplateIrrigationSettingsLoading extends TemplateIrrigationSettingsState{}
class TemplateIrrigationSettingsLoaded extends TemplateIrrigationSettingsState{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String settingId;
  final String message;
  final ControllerIrrigationSettingEntity controllerIrrigationSettingEntity;
  final UpdateTemplateSettingStatus updateTemplateSettingStatus;

  TemplateIrrigationSettingsLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.settingId,
    this.message = '',
    required this.controllerIrrigationSettingEntity,
    this.updateTemplateSettingStatus = UpdateTemplateSettingStatus.idle
  });

  TemplateIrrigationSettingsLoaded copyWith({
    required ControllerIrrigationSettingEntity updatedControllerIrrigationSettingEntity,
    UpdateTemplateSettingStatus? status,
    String? msg
  }){
    return TemplateIrrigationSettingsLoaded(
        userId: userId,
        controllerId: controllerId,
        subUserId: subUserId,
        settingId: settingId,
        message: msg ?? message,
        controllerIrrigationSettingEntity: updatedControllerIrrigationSettingEntity,
      updateTemplateSettingStatus: status ?? updateTemplateSettingStatus
    );
  }
}
class TemplateIrrigationSettingsFailure extends TemplateIrrigationSettingsState{
  final String message;
  TemplateIrrigationSettingsFailure({required this.message});
}