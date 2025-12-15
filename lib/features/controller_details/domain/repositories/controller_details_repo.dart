
import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_details/domain/usecase/update_controllerDetails_params.dart';

import '../../../../core/error/failures.dart';


abstract class ControllerRepo {
  Future<Either<Failure, dynamic>> getControllerDetails(
      int userId,
      int controllerId,
      );
  Future<Either<Failure, dynamic>> updateControllerDetails(
      UpdateControllerDetailsParams params,
      );
}