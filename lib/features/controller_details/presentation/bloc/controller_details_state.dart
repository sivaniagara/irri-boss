import 'package:equatable/equatable.dart';
import '../../domain/entities/controller_details_entities.dart';
import '../../data/models/controller_details_model.dart';

abstract class ControllerDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ControllerDetailsInitial extends ControllerDetailsState {}

class ControllerDetailsLoading extends ControllerDetailsState {}

class ControllerDetailsLoaded extends ControllerDetailsState {
  final ControllerDetailsEntities data;
  final List<GroupDetails> groupDetails;

  ControllerDetailsLoaded(this.data, this.groupDetails);

  @override
  List<Object?> get props => [data, groupDetails];
}

class ControllerDetailsError extends ControllerDetailsState {
  final String message;

  ControllerDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateControllerSuccess extends ControllerDetailsState {
  final Map<String, dynamic> message;
  UpdateControllerSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
