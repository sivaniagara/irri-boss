import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/error/success.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../repositories/program_repository.dart';

class DeleteZoneParams{
  final String userId;
  final String controllerId;
  final String programId;
  final String zoneSerialNo;

  DeleteZoneParams({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.zoneSerialNo,
  });
}


class DeleteZoneUseCase extends UseCase<Unit, DeleteZoneParams>{
  final ProgramRepository programRepository;
  DeleteZoneUseCase({required this.programRepository});

  @override
  Future<Either<Failure, Unit>> call(DeleteZoneParams params)async{
    return programRepository.deleteZone(params);
  }
}