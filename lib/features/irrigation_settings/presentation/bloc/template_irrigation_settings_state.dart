part of 'template_irrigation_settings_bloc.dart';

abstract class TemplateIrrigationSettingsState{}

class TemplateIrrigationSettingsInitial extends TemplateIrrigationSettingsState{}
class TemplateIrrigationSettingsLoading extends TemplateIrrigationSettingsState{}
class TemplateIrrigationSettingsLoaded extends TemplateIrrigationSettingsState{
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final String settingId;
  final String message;
  final ControllerIrrigationSettingEntity controllerIrrigationSettingEntity;
  final ControllerIrrigationSettingEntity? updatedControllerIrrigationSettingEntity;
  final UpdateTemplateSettingStatus updateTemplateSettingStatus;

  TemplateIrrigationSettingsLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.settingId,
    this.message = '',
    required this.controllerIrrigationSettingEntity,
    this.updatedControllerIrrigationSettingEntity,
    this.updateTemplateSettingStatus = UpdateTemplateSettingStatus.idle
  });

  TemplateIrrigationSettingsLoaded copyWith({
    ControllerIrrigationSettingEntity? controllerIrrigationSettingEntity,
    ControllerIrrigationSettingEntity? updatedControllerIrrigationSettingEntity,
    UpdateTemplateSettingStatus? status,
    String? msg
  }){
    return TemplateIrrigationSettingsLoaded(
        userId: userId,
        controllerId: controllerId,
        deviceId: deviceId,
        subUserId: subUserId,
        settingId: settingId,
        message: msg ?? message,
        controllerIrrigationSettingEntity: controllerIrrigationSettingEntity ?? this.controllerIrrigationSettingEntity,
        updatedControllerIrrigationSettingEntity: updatedControllerIrrigationSettingEntity ?? this.updatedControllerIrrigationSettingEntity,
        updateTemplateSettingStatus: status ?? updateTemplateSettingStatus
    );
  }
}
class TemplateIrrigationSettingsFailure extends TemplateIrrigationSettingsState{
  final String message;
  TemplateIrrigationSettingsFailure({required this.message});
}