part of 'edit_program_bloc.dart';

abstract class EditProgramState{}

class EditProgramInitial extends EditProgramState{}
class EditProgramLoading extends EditProgramState{}

class EditProgramLoaded extends EditProgramState{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String deviceId;
  final SaveProgramStatus saveProgramStatus;
  final EditProgramEntity editProgramEntity;

  EditProgramLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.deviceId,
    this.saveProgramStatus = SaveProgramStatus.idle,
    required this.editProgramEntity,
  });

  EditProgramLoaded copyWith({EditProgramEntity? updatedEditProgramEntity, SaveProgramStatus? updatedSaveProgramStatus}){
    return EditProgramLoaded(
        userId: userId,
        controllerId: controllerId,
        subUserId: subUserId,
        saveProgramStatus: updatedSaveProgramStatus ?? saveProgramStatus,
        editProgramEntity: updatedEditProgramEntity ?? editProgramEntity,
        deviceId: deviceId
    );
  }
}

class EditProgramFailure extends EditProgramState{}