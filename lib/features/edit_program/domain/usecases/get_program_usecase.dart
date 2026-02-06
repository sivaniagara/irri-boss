import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/edit_program_entity.dart';

import '../repositories/edit_program_repository.dart';

class GetProgramParams{
  final String userId;
  final String controllerId;
  final String subUserId;
  final int programId;

  GetProgramParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programId,
  });
}


class GetProgramUsecase extends UseCase<EditProgramEntity, GetProgramParams>{
  final EditProgramRepository repository;
  GetProgramUsecase({required this.repository});

  @override
  Future<Either<Failure, EditProgramEntity>> call(GetProgramParams params){
    return repository.getProgram(params);
  }

}