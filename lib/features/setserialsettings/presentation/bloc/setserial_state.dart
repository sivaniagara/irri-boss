import 'package:equatable/equatable.dart';

import '../../data/models/setserial_details_model.dart';

abstract class SetSerialState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetSerialInitial extends SetSerialState {}

class SetSerialLoading extends SetSerialState {}

/// ---------- LOAD SERIAL (LIST) ----------
class SerialDataLoaded extends SetSerialState {
  final List<SetSerialNodeList> nodeList;

  SerialDataLoaded(this.nodeList);

  @override
  List<Object?> get props => [nodeList];
}
//
class LoadSerialError extends SetSerialState {
  final String message;

  LoadSerialError(this.message);

  @override
  List<Object?> get props => [message];
}

/// ---------- SEND SERIAL ----------
class SendSerialSuccess extends SetSerialState {
  final String message;
  SendSerialSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SendSerialError extends SetSerialState {
  final String message;
  SendSerialError(this.message);

  @override
  List<Object?> get props => [message];
}

/// ---------- RESET SERIAL ----------
class ResetSerialSuccess extends SetSerialState {
  final String message;
  ResetSerialSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetSerialError extends SetSerialState {
  final String message;
  ResetSerialError(this.message);

  @override
  List<Object?> get props => [message];
}

/// ---------- VIEW SERIAL ----------
class ViewSerialSuccess extends SetSerialState {
  final String message;
  ViewSerialSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ViewSerialError extends SetSerialState {
  final String message;
  ViewSerialError(this.message);

  @override
  List<Object?> get props => [message];
}
