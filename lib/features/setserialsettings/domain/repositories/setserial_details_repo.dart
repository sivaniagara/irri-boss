import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/setserial_datasource.dart';
import '../../data/models/setserial_details_model.dart';
import '../../data/repositories/setserial_details_repositories.dart';


class SetSerialRepositoryImpl implements SetSerialRepository {
  final SetSerialDataSource remoteDataSource;

  SetSerialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, dynamic>> getSetSerialDetails(
      int userId,
      int controllerId,
      ) async {
    try {
      final result = await remoteDataSource.loadSerial(
          userId: userId,
          controllerId: controllerId,

      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Controller Fetching Failure: $e'));
    }
  }

  @override
  Future<List<SetSerialNodeList>> loadSerial({
    required int userId,
    required int controllerId,
  }) async {
    return await remoteDataSource.loadSerial(
      userId: userId,
      controllerId: controllerId,
    );
  }

  @override
  Future<String> sendSerial({
    required int userId,
    required int controllerId,
    required List<Map<String, dynamic>> sendList,
    required String sentSms,
  }) async {
    return await remoteDataSource.sendSerial(
      userId: userId,
      controllerId: controllerId,
      sendList: sendList,
      sentSms: sentSms,
    );
  }

  @override
  Future<String> resetSerial({
    required int userId,
    required int controllerId,
    required List<int> nodeIds,
    required String sentSms,
  }) async {
    return await remoteDataSource.resetSerial(
      userId: userId,
      controllerId: controllerId,
      nodeIds: nodeIds,
      sentSms: sentSms,
    );
  }

  @override
  Future<String> viewSerial({
    required int userId,
    required int controllerId,
    required String sentSms,
  }) async {
    return await remoteDataSource.viewSerial(
      userId: userId,
      controllerId: controllerId,
      sentSms: sentSms,
    );
  }

  @override
  // TODO: implement dataSource
  SetSerialDataSource get dataSource => throw UnimplementedError();


 }

