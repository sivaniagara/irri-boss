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

  TemplateIrrigationSettingsLoaded copyWith({ControllerIrrigationSettingEntity? updatedControllerIrrigationSettingEntity}){
    return TemplateIrrigationSettingsLoaded(
        userId: userId,
        controllerId: controllerId,
        subUserId: subUserId,
        settingId: settingId,
        controllerIrrigationSettingEntity: updatedControllerIrrigationSettingEntity ?? controllerIrrigationSettingEntity
    );
  }
}

class ValveFlowLoaded extends TemplateIrrigationSettingsState {
  final String userId;
  final String controllerId;
  final String subUserId;
  final ValveFlowEntity valveFlowEntity;

  ValveFlowLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.valveFlowEntity,
  });

  ValveFlowLoaded copyWith({ValveFlowEntity? updatedValveFlowEntity}) {
    return ValveFlowLoaded(
      userId: userId,
      controllerId: controllerId,
      subUserId: subUserId,
      valveFlowEntity: updatedValveFlowEntity ?? valveFlowEntity,
    );
  }
}

class TemplateIrrigationSettingsFailure extends TemplateIrrigationSettingsState{
  final String message;
  TemplateIrrigationSettingsFailure({required this.message});
}

class SettingUpdateSuccess extends TemplateIrrigationSettingsState {
  final String message;
  SettingUpdateSuccess({required this.message});
}
