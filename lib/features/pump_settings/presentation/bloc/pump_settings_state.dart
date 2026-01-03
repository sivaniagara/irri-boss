import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/settings_menu_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

abstract class PumpSettingsState extends Equatable {
  const PumpSettingsState();
  @override List<Object?> get props => [];
}

class GetPumpSettingsMenuInitial extends PumpSettingsState {}

class GetPumpSettingsMenuLoaded extends PumpSettingsState {
  final List<SettingsMenuEntity> settingMenuList;
  const GetPumpSettingsMenuLoaded({required this.settingMenuList});

  @override List<Object?> get props => [settingMenuList];
}

class GetPumpSettingsMenuError extends PumpSettingsState {
  final String message;
  const GetPumpSettingsMenuError({required this.message});

  @override List<Object?> get props => [message];
}

class UpdatingMenuStatus extends PumpSettingsState {}

class UpdateMenuStatusSuccess extends PumpSettingsState {
  final String message;
  const UpdateMenuStatusSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UpdateMenuStatusFailure extends PumpSettingsState {
  final String message;
  const UpdateMenuStatusFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class GetPumpSettingsInitial extends PumpSettingsState {}

class GetPumpSettingsLoaded extends PumpSettingsState {
  final MenuItemEntity settings;
  final int version;
  const GetPumpSettingsLoaded({required this.settings, this.version = 0});

  @override List<Object?> get props => [settings, version];
}

class GetPumpSettingsError extends PumpSettingsState {
  final String message;
  const GetPumpSettingsError({required this.message});

  @override List<Object?> get props => [message];
}

class UpdatePumpSettingValueStarted extends PumpSettingsState {
  final SettingsEntity settingsEntity;
  const UpdatePumpSettingValueStarted({required this.settingsEntity});

  @override List<Object?> get props => [settingsEntity];
}

class SettingsSendStartedState extends PumpSettingsState {}

class SettingSendingState extends PumpSettingsState {
  final int sectionIndex;
  final int settingIndex;

  const SettingSendingState(this.sectionIndex, this.settingIndex);
}

class SettingsSendSuccessState extends PumpSettingsState {
  final String message;
  const SettingsSendSuccessState({required this.message});

  @override
  List<Object> get props => [message];
}

class SettingsFailureState extends PumpSettingsState {
  final String message;
  const SettingsFailureState({required this.message});

  @override
  List<Object> get props => [message];
}