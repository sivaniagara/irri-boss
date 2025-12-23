import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/success.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/domain/usecases/delete_zone_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/program_repository.dart';
import '../../domain/usecases/get_programs_usecase.dart';
import '../data_source/program_remote_source.dart';
import '../models/program_and_model.dart';

class ProgramRepositoryImpl implements ProgramRepository {
  final ProgramRemoteSource programRemoteSource;

  ProgramRepositoryImpl({required this.programRemoteSource});

  @override
  Future<Either<Failure, List<ProgramAndZoneModel>>> getPrograms(ProgramParams params) async {
    try {
      final response = await programRemoteSource.getPrograms({'userId' : params.userId, 'controllerId' : params.controllerId});
      final List<dynamic> list = response['data'];
      return Right(
          list
          .where((e) => e is Map && e.containsKey('programId'))
          .map((e) => ProgramAndZoneModel.fromJson(e))
          .toList()
      );
    } catch (e) {
      return Left(ServerFailure('getPrograms Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteZone(DeleteZoneParams params) async{
    try {
      final response = await programRemoteSource.deleteZone({'userId' : params.userId, 'controllerId' : params.controllerId, 'programId' : params.programId, 'zoneSerialNo' : params.zoneSerialNo});
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    } catch (e) {
      return Left(ServerFailure('getPrograms Fetching Failure: $e'));
    }
  }
}
