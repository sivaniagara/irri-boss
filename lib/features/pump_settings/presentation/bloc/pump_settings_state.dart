import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/settings_menu_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

class PumpSettingsState extends Equatable {
  @override List<Object?> get props => [];
}

class GetPumpSettingsMenuInitial extends PumpSettingsState {}

class GetPumpSettingsMenuLoaded extends PumpSettingsState {
  final List<SettingsMenuEntity> settingMenuList;
  GetPumpSettingsMenuLoaded({required this.settingMenuList});

  @override List<Object?> get props => [settingMenuList];
}

class GetPumpSettingsMenuError extends PumpSettingsState {
  final String message;
  GetPumpSettingsMenuError({required this.message});

  @override List<Object?> get props => [message];
}

class UpdatingMenuStatus extends PumpSettingsState {}

class UpdateMenuStatusSuccess extends PumpSettingsState {
  final String message;
  UpdateMenuStatusSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UpdateMenuStatusFailure extends PumpSettingsState {
  final String message;
  UpdateMenuStatusFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class GetPumpSettingsInitial extends PumpSettingsState {}

class GetPumpSettingsLoaded extends PumpSettingsState {
  final MenuItemEntity settings;
  final int version;
  GetPumpSettingsLoaded({required this.settings, this.version = 0});

  @override List<Object?> get props => [settings, version];
}

class GetPumpSettingsError extends PumpSettingsState {
  final String message;
  GetPumpSettingsError({required this.message});

  @override List<Object?> get props => [message];
}

class UpdatePumpSettingValueStarted extends PumpSettingsState {
  final SettingsEntity settingsEntity;
  UpdatePumpSettingValueStarted({required this.settingsEntity});

  @override List<Object?> get props => [settingsEntity];
}

class SettingsSendStartedState extends PumpSettingsState {}

class SettingSendingState extends PumpSettingsState {
  final int sectionIndex;
  final int settingIndex;

  SettingSendingState(this.sectionIndex, this.settingIndex);
}

class SettingsSendSuccessState extends PumpSettingsState {
  final String message;
  SettingsSendSuccessState({required this.message});

  @override
  List<Object> get props => [message];
}

class SettingsFailureState extends PumpSettingsState {
  final String message;
  SettingsFailureState({required this.message});

  @override
  List<Object> get props => [message];
}