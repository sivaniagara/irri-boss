part of 'template_irrigation_settings_bloc.dart';

abstract class TemplateIrrigationSettingsState{}

class TemplateIrrigationSettingsInitial extends TemplateIrrigationSettingsState{}
class TemplateIrrigationSettingsLoading extends TemplateIrrigationSettingsState{}
class TemplateIrrigationSettingsLoaded extends TemplateIrrigationSettingsState{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String settingId;
  final ControllerIrrigationSettingEntity controllerIrrigationSettingEntity;

  TemplateIrrigationSettingsLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.settingId,
    required this.controllerIrrigationSettingEntity,
  });

  TemplateIrrigationSettingsLoaded copyWith({required ControllerIrrigationSettingEntity updatedControllerIrrigationSettingEntity}){
    return TemplateIrrigationSettingsLoaded(
        userId: userId,
        controllerId: controllerId,
        subUserId: subUserId,
        settingId: settingId,
        controllerIrrigationSettingEntity: updatedControllerIrrigationSettingEntity
    );
  }
}
class TemplateIrrigationSettingsFailure extends TemplateIrrigationSettingsState{
  final String message;
  TemplateIrrigationSettingsFailure({required this.message});
}