import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/edit_program_entity.dart';
import '../repositories/edit_program_repository.dart';

class SaveProgramParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final EditProgramEntity editProgramEntity;
  SaveProgramParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.editProgramEntity,
  });
}


class SaveProgramUsecase extends UseCase<Unit, SaveProgramParams>{
  final EditProgramRepository repository;
  SaveProgramUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SaveProgramParams params){
    return repository.saveProgram(params);
  }

}