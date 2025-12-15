import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/program_and_zone_entity.dart';
import '../repositories/program_repository.dart';

class ProgramParams{
  final String userId;
  final String controllerId;
  ProgramParams({required this.userId, required  this.controllerId});
}

class GetProgramsUseCase extends UseCase<List<ProgramAndZoneEntity>, ProgramParams>{
  final ProgramRepository programRepository;

  GetProgramsUseCase({required this.programRepository});

  @override
  Future<Either<Failure, List<ProgramAndZoneEntity>>> call(ProgramParams params) {
    return programRepository.getPrograms(params);
  }
}