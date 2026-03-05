part of 'edit_program_bloc.dart';

enum ZoneDeleteStatusEditProgram { initial, loading, success, failure }

extension ZoneDeleteStatusExtension on ZoneDeleteStatusEditProgram {
  String get message {
    switch (this) {
      case ZoneDeleteStatusEditProgram.initial:
        return '';
      case ZoneDeleteStatusEditProgram.loading:
        return 'Deleting zone...';
      case ZoneDeleteStatusEditProgram.success:
        return 'Zone deleted successfully';
      case ZoneDeleteStatusEditProgram.failure:
        return 'Failed to delete zone';
    }
  }
}
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
  final ZoneDeleteStatusEditProgram zoneDeleteStatusEditProgram;

  EditProgramLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.deviceId,
    this.saveProgramStatus = SaveProgramStatus.idle,
    this.zoneDeleteStatusEditProgram = ZoneDeleteStatusEditProgram.initial,
    required this.editProgramEntity,
  });

  EditProgramLoaded copyWith({
    EditProgramEntity? editProgramEntity,
    SaveProgramStatus? saveProgramStatus,
    ZoneDeleteStatusEditProgram? zoneDeleteStatusEditProgram,
  }){
    return EditProgramLoaded(
        userId: userId,
        controllerId: controllerId,
        subUserId: subUserId,
        saveProgramStatus: saveProgramStatus ?? this.saveProgramStatus,
        editProgramEntity: editProgramEntity ?? this.editProgramEntity,
        zoneDeleteStatusEditProgram: zoneDeleteStatusEditProgram ?? this.zoneDeleteStatusEditProgram,
        deviceId: deviceId
    );
  }
}

class EditProgramFailure extends EditProgramState{}