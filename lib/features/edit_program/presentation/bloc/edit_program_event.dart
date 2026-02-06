part of 'edit_program_bloc.dart';

abstract class EditProgramEvent{}

class GetProgramEvent extends EditProgramEvent{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String deviceId;
  final int programId;
  GetProgramEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.programId,
  });
}

class SaveProgramEvent extends EditProgramEvent{
  final String userId;
  final String controllerId;
  final String deviceId;
  final EditProgramEntity editProgramEntity;
  SaveProgramEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.editProgramEntity,
  });
}

class UpdateTimerAdjustPercent extends EditProgramEvent{
  final double value;
  UpdateTimerAdjustPercent(this.value);
}

class UpdateFlowAdjustPercent extends EditProgramEvent{
  final double value;
  UpdateFlowAdjustPercent(this.value);
}

class UpdateMoistureAdjustPercent extends EditProgramEvent{
  final double value;
  UpdateMoistureAdjustPercent(this.value);
}

class UpdateFertilizerAdjustPercent extends EditProgramEvent{
  final double value;
  UpdateFertilizerAdjustPercent(this.value);
}

class AddZoneEvent extends EditProgramEvent{}

class DeleteZoneEvent extends EditProgramEvent{
  final int zoneIndex;
  DeleteZoneEvent({required this.zoneIndex});
}

class AddOrRemoveValveToZoneEvent extends EditProgramEvent{
  final int zoneIndex;
  final int nodeIndex;
  final AddRemoveEnum addRemoveEnum;
  AddOrRemoveValveToZoneEvent({
    required this.zoneIndex,
    required this.nodeIndex,
    required this.addRemoveEnum,
  });
}

class AddOrRemoveMoistureToZoneEvent extends EditProgramEvent{
  final int zoneIndex;
  final int nodeIndex;
  final AddRemoveEnum addRemoveEnum;
  AddOrRemoveMoistureToZoneEvent({
    required this.zoneIndex,
    required this.nodeIndex,
    required this.addRemoveEnum,
  });
}

class AddOrRemoveLevelToZoneEvent extends EditProgramEvent{
  final int zoneIndex;
  final int nodeIndex;
  final AddRemoveEnum addRemoveEnum;
  AddOrRemoveLevelToZoneEvent({
    required this.zoneIndex,
    required this.nodeIndex,
    required this.addRemoveEnum,
  });
}

class UpdateTotalTime extends EditProgramEvent {
  final int zoneIndex;
  final String time; // "HH:mm"

  UpdateTotalTime({required this.zoneIndex, required this.time});
}

class UpdateTotalLiters extends EditProgramEvent {
  final int zoneIndex;
  final String liters; // "HH:mm"
  UpdateTotalLiters({required this.zoneIndex, required this.liters});
}

class UpdatePreTime extends EditProgramEvent {
  final int zoneIndex;
  final String time; // "HH:mm"

  UpdatePreTime({required this.zoneIndex, required this.time});
}

class UpdatePostTime extends EditProgramEvent {
  final int zoneIndex;
  final String time; // "HH:mm"

  UpdatePostTime({required this.zoneIndex, required this.time});
}




class UpdatePreLiters extends EditProgramEvent {
  final int zoneIndex;
  final String liters;

  UpdatePreLiters({required this.zoneIndex, required this.liters});
}

class UpdatePostLiters extends EditProgramEvent {
  final int zoneIndex;
  final String liters;

  UpdatePostLiters({required this.zoneIndex, required this.liters});
}


class UpdateChannelTime extends EditProgramEvent {
  final int zoneIndex;
  final int channelIndex;
  final String time;

  UpdateChannelTime({
    required this.zoneIndex,
    required this.channelIndex,
    required this.time,
  });
}

class UpdateChannelLiters extends EditProgramEvent {
  final int zoneIndex;
  final int channelIndex; // 0 to 5
  final String liters;

  UpdateChannelLiters({
    required this.zoneIndex,
    required this.channelIndex,
    required this.liters,
  });
}
