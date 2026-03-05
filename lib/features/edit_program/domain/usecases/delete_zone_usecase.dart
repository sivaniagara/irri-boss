

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/edit_program_repository.dart';

class DeleteZoneParamsEditProgram{
  final String userId;
  final String controllerId;
  final String programId;
  final String zoneSerialNo;

  DeleteZoneParamsEditProgram({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.zoneSerialNo,
  });
}


class DeleteZoneEditProgramUseCase extends UseCase<Unit, DeleteZoneParamsEditProgram>{
  final EditProgramRepository repository;
  DeleteZoneEditProgramUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(DeleteZoneParamsEditProgram params)async{
    return repository.deleteZone(params);
  }
}