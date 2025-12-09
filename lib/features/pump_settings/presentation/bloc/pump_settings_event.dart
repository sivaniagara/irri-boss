import 'package:equatable/equatable.dart';

import '../../domain/entities/template_json_entity.dart';

class PumpSettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPumpSettingsMenuEvent extends PumpSettingsEvent {
  final int userId, controllerId, subUserId;
  GetPumpSettingsMenuEvent({required this.userId, required this.subUserId, required this.controllerId});

  @override
  List<Object?> get props => [];
}

class GetPumpSettingsEvent extends PumpSettingsEvent {
  final int userId, controllerId, subUserId, menuId;
  GetPumpSettingsEvent({required this.userId, required this.subUserId, required this.controllerId, required this.menuId});

  @override
  List<Object?> get props => [];
}

class UpdateSettingValue extends PumpSettingsEvent {
  final SettingsEntity settings;
  final String newValue;

  UpdateSettingValue({required this.settings, required this.newValue});

  @override
  List<Object> get props => [settings, newValue];
}

class SettingsSendEvent extends PumpSettingsEvent {
  final String value;
  SettingsSendEvent({required this.value});

  @override
  List<Object?> get props => [value];
}