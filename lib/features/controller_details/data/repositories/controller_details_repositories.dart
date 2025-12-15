import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_details/domain/usecase/update_controllerDetails_params.dart';
import '../../../../core/error/failures.dart';
import '../datasources/controller_datasource.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../../domain/repositories/controller_details_repo.dart';

class ControllerRepoImpl implements ControllerRepo {
  final ControllerRemoteDataSource remoteDataSource;

  ControllerRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, dynamic>> getControllerDetails(
      int userId,
      int controllerId,
      ) async {
    try {
      final result = await remoteDataSource.getControllerDetails(
        GetControllerDetailsParams(
          userId: userId,
          controllerId: controllerId,
        ),
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Controller Fetching Failure: $e'));
    }
  }

  // ⭐⭐⭐ NEW: UPDATE CONTROLLER USING PUT API ⭐⭐⭐
  @override
  Future<Either<Failure, dynamic>> updateControllerDetails(
      UpdateControllerDetailsParams params) async {
    try {
      final result = await remoteDataSource.updateController(params);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Controller Update Failure: $e'));
    }
  }

  /*@override
  Future<Either<Failure, dynamic>> updateControllerDetails(UpdateControllerDetailsParams params) {
    // TODO: implement updateControllerDetails
    throw UnimplementedError();
  }*/
}
