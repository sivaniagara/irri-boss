part of 'water_fertilizer_setting_bloc.dart';


abstract class WaterFertilizerSettingState{}

class WaterFertilizerSettingInitial extends WaterFertilizerSettingState{}
class WaterFertilizerSettingLoading extends WaterFertilizerSettingState{}

class WaterFertilizerSettingLoaded extends WaterFertilizerSettingState{
  final String userId;
  final String controllerId;
  final String subUserId;
  String? zoneSetId;
  String? programSettingNo;
  final ProgramZoneSetEntity programZoneSetEntity;
  final ZoneSetUpdateStatusEnum zoneSetUpdateStatusEnum;
  WaterFertilizerSettingLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    this.zoneSetId = '',
    this.programSettingNo = '',
    this.zoneSetUpdateStatusEnum = ZoneSetUpdateStatusEnum.idle,
    required this.programZoneSetEntity,
  });

  WaterFertilizerSettingLoaded copyWith({
    String? updatedZoneSetId,
    String? updatedProgramSettingNo,
    ProgramZoneSetEntity? updatedProgramZoneSetEntity,
    ZoneSetUpdateStatusEnum? updatedZoneSetUpdateStatusEnum
  }) {
    return WaterFertilizerSettingLoaded(
      userId: userId,
      controllerId: controllerId,
      subUserId: subUserId,
      zoneSetId: updatedZoneSetId ?? zoneSetId,
      programSettingNo: updatedProgramSettingNo ?? programSettingNo,
      programZoneSetEntity:
      updatedProgramZoneSetEntity ?? programZoneSetEntity,
      zoneSetUpdateStatusEnum: updatedZoneSetUpdateStatusEnum ?? zoneSetUpdateStatusEnum
    );
  }

}

class WaterFertilizerSettingFailure extends WaterFertilizerSettingState{}


