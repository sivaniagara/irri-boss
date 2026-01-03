import '../../domain/entities/standalone_entity.dart';

abstract class StandaloneState {}

class StandaloneInitial extends StandaloneState {}

class StandaloneLoading extends StandaloneState {}

class StandaloneLoaded extends StandaloneState {
  final StandaloneEntity data;
  StandaloneLoaded(this.data);
}

class StandaloneSuccess extends StandaloneState {
  final String message;
  final StandaloneEntity data;
  StandaloneSuccess(this.message, this.data);
}

class StandaloneError extends StandaloneState {
  final String message;
  StandaloneError(this.message);
}
