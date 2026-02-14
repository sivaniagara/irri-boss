import 'package:equatable/equatable.dart';
import '../../data/models/get_moisture_status_model.dart';

abstract class GetMoistureStatusState extends Equatable {
  const GetMoistureStatusState();

  @override
  List<Object> get props => [];
}

class GetMoistureStatusInitial extends GetMoistureStatusState {}

class GetMoistureStatusLoading extends GetMoistureStatusState {}

class GetMoistureStatusLoaded extends GetMoistureStatusState {
  final GetMoistureStatusModel nodeStatusModel;

  const GetMoistureStatusLoaded(this.nodeStatusModel);

  @override
  List<Object> get props => [nodeStatusModel];
}

class GetMoistureStatusError extends GetMoistureStatusState {
  final String message;

  const GetMoistureStatusError(this.message);

  @override
  List<Object> get props => [message];
}
