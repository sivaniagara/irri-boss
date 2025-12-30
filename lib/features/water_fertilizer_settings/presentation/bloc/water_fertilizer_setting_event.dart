part of 'water_fertilizer_setting_bloc.dart';

abstract class WaterFertilizerSettingEvent{}

class FetchProgramZoneSetEvent extends WaterFertilizerSettingEvent{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String programId;
  FetchProgramZoneSetEvent({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programId,
  });
}

class FetchZoneSetSettingEvent extends WaterFertilizerSettingEvent{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String programSettingNo;
  final String zoneSetId;
  final String programId;
  FetchZoneSetSettingEvent({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programSettingNo,
    required this.zoneSetId,
    required this.programId,
  });
}

class UpdateZoneSetSettingEvent extends WaterFertilizerSettingEvent{
  final int channelNo;
  final int irrigationDosingOrPrePost;
  final int method;
  final int mode;
  UpdateZoneSetSettingEvent({
    required this.channelNo,
    required this.irrigationDosingOrPrePost,
    required this.method,
    required this.mode,
  });
}

class UpdateTotalTime extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final String time; // "HH:mm"

  UpdateTotalTime({required this.zoneNo, required this.time});
}

class UpdateTotalLiters extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final String liters; // "HH:mm"
  UpdateTotalLiters({required this.zoneNo, required this.liters});
}

class UpdatePreTime extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final String time; // "HH:mm"

  UpdatePreTime({required this.zoneNo, required this.time});
}

class UpdatePostTime extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final String time; // "HH:mm"

  UpdatePostTime({required this.zoneNo, required this.time});
}




class UpdatePreLiters extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final String liters;

  UpdatePreLiters({required this.zoneNo, required this.liters});
}

class UpdatePostLiters extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final String liters;

  UpdatePostLiters({required this.zoneNo, required this.liters});
}


class UpdateChannelTime extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final int channelIndex;
  final String time;

  UpdateChannelTime({
    required this.zoneNo,
    required this.channelIndex,
    required this.time,
  });
}

class UpdateChannelLiters extends WaterFertilizerSettingEvent {
  final int zoneNo;
  final int channelIndex; // 0 to 5
  final String liters;

  UpdateChannelLiters({
    required this.zoneNo,
    required this.channelIndex,
    required this.liters,
  });
}
