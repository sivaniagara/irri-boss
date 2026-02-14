import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/get_moisture_status_repository.dart';
import '../datasources/get_moisture_status_remote_datasource.dart';
import '../models/get_moisture_status_model.dart';

class GetMoistureStatusRepositoryImpl implements GetMoistureStatusRepository {
  final GetMoistureStatusRemoteDataSource remoteDataSource;

  GetMoistureStatusRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GetMoistureStatusModel>> getGetMoistureStatus({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final remoteData = await remoteDataSource.getGetMoistureStatusData(
        userId: userId,
        subuserId: subuserId,
        controllerId: controllerId,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(remoteData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
