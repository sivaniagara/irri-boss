import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_details/domain/usecase/update_controllerDetails_params.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/controller_details_entities.dart';
import '../../data/models/controller_details_model.dart';
import '../../domain/repositories/controller_details_repo.dart';
import '../../domain/usecase/update_controllerDetails_params.dart';

abstract class ControllerDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}
class UpdateControllerUsecase {
  final ControllerRepo controllerRepo;

   UpdateControllerUsecase({required this.controllerRepo});

  Future<Either<Failure, dynamic>> call(UpdateControllerDetailsParams params) async {
    return await controllerRepo.updateControllerDetails(params);
    // return await controllerRepo.UpdateControllerDetailsParams(params);
  }
}

class ControllerDetailsInitial extends ControllerDetailsState {}

class ControllerDetailsLoading extends ControllerDetailsState {}

class ControllerDetailsLoaded extends ControllerDetailsState {
  final ControllerDetailsEntities data;
  final List<GroupDetails> groupDetails;   // <-- ADD THIS

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
class SwitchToggleLoading extends ControllerDetailsState {}

class SwitchToggleSuccess extends ControllerDetailsState {
  final String switchName;
  final bool newValue;

  SwitchToggleSuccess({
    required this.switchName,
    required this.newValue,
  });

  @override
  List<Object?> get props => [switchName, newValue];
}

class SwitchToggleFailed extends ControllerDetailsState {
  final String message;

  SwitchToggleFailed(this.message);

  @override
  List<Object?> get props => [message];
}
class UpdateControllerSuccess extends ControllerDetailsState {
   final Map<String, dynamic> message;
  UpdateControllerSuccess(this.message);
}