import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/controller_details_repo.dart';
import 'controller_details_params.dart';

class GetControllerDetailsUsecase
    extends UseCase<dynamic, GetControllerDetailsParams> {
  final ControllerRepo controllerRepo;

  GetControllerDetailsUsecase({required this.controllerRepo});

  @override
  Future<Either<Failure, dynamic>> call(GetControllerDetailsParams params) {
    return controllerRepo.getControllerDetails(
      params.userId,
      params.controllerId,
    );
  }
}
