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
  FetchZoneSetSettingEvent({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programSettingNo,
    required this.zoneSetId,
  });
}