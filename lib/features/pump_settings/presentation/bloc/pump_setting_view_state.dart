import 'package:equatable/equatable.dart';

abstract class PumpSettingViewState extends Equatable {
  const PumpSettingViewState();
  @override List<Object?> get props => [];
}

class PumpSettingsViewInitial extends PumpSettingViewState {}

class PumpSettingsViewReceived extends PumpSettingViewState {
  final String message;
  const PumpSettingsViewReceived({required this.message});

  @override List<Object?> get props => [message];
}